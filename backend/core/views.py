import os
from datetime import date, timedelta

import stripe
from django.conf import settings
from django.db.models import Avg, Sum
from django.db.models.functions import TruncMonth
from django.shortcuts import get_object_or_404
from django_filters.rest_framework import DjangoFilterBackend
from joblib import load
from rest_framework import filters, status, viewsets
from rest_framework.decorators import action
from rest_framework.generics import CreateAPIView, RetrieveAPIView
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.parsers import FormParser, MultiPartParser
from rest_framework.response import Response
from rest_framework.views import APIView
from .models import (
    Fleet,
    MaintenanceLog,
    Notification,
    PaymentTransaction,
    Product,
    Vehicle,
)
from .serializers import (
    FleetSerializer,
    MaintenanceLogSerializer,
    MaintenanceReminderSerializer,
    NotificationSerializer,
    PaymentTransactionSerializer,
    ProductSerializer,
    RegisterSerializer,
    UserSerializer,
    VehicleSerializer,
)


class RegisterView(CreateAPIView):
    serializer_class = RegisterSerializer
    permission_classes = [AllowAny]

    def perform_create(self, serializer):
        serializer.save()


class MeView(RetrieveAPIView):
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]

    def get_object(self):
        return self.request.user


class VehicleViewSet(viewsets.ModelViewSet):
    serializer_class = VehicleSerializer
    filter_backends = (DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter)
    filterset_fields = ('vehicle_type', 'vin')
    search_fields = ('make', 'model', 'vin')
    ordering_fields = ('created_at', 'year', 'mileage')
    parser_classes = (MultiPartParser, FormParser)

    def get_queryset(self):
        return Vehicle.objects.filter(owner=self.request.user).order_by('-created_at')

    def perform_create(self, serializer):
        serializer.save(owner=self.request.user)


class MaintenanceLogViewSet(viewsets.ModelViewSet):
    serializer_class = MaintenanceLogSerializer

    def get_queryset(self):
        queryset = MaintenanceLog.objects.filter(vehicle__owner=self.request.user).select_related('vehicle').order_by('-date')
        vehicle_id = self.request.query_params.get('vehicle')
        if vehicle_id:
            queryset = queryset.filter(vehicle_id=vehicle_id)
        return queryset


class FleetViewSet(viewsets.ModelViewSet):
    serializer_class = FleetSerializer

    def get_queryset(self):
        return Fleet.objects.filter(manager=self.request.user).prefetch_related('vehicles')

    def perform_create(self, serializer):
        serializer.save(manager=self.request.user)

    @action(detail=True, methods=['post'])
    def assign_vehicle(self, request, pk=None):
        fleet = self.get_object()
        vehicle_id = request.data.get('vehicle_id')
        if not vehicle_id:
            return Response({'detail': 'vehicle_id is required'}, status=status.HTTP_400_BAD_REQUEST)
        vehicle = get_object_or_404(Vehicle, id=vehicle_id, owner=request.user)
        fleet.vehicles.add(vehicle)
        return Response({'detail': f'{vehicle} assigned to {fleet}'})


class ProductViewSet(viewsets.ModelViewSet):
    serializer_class = ProductSerializer
    queryset = Product.objects.all()

    def get_permissions(self):
        if self.action in ('list', 'retrieve'):
            return [AllowAny()]
        return [IsAuthenticated()]

    def perform_create(self, serializer):
        serializer.save(seller=self.request.user)


class NotificationViewSet(viewsets.ModelViewSet):
    serializer_class = NotificationSerializer

    def get_queryset(self):
        return Notification.objects.filter(user=self.request.user).order_by('-created_at')

    @action(detail=False, methods=['post'])
    def mark_read(self, request):
        ids = request.data.get('ids', [])
        notifications = self.get_queryset().filter(id__in=ids)
        notifications.update(read=True)
        return Response({'updated': notifications.count()})


class MaintenanceReminderView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        today = date.today()
        reminders = MaintenanceLog.objects.filter(
            vehicle__owner=request.user,
            next_due_date__gte=today
        ).order_by('next_due_date')[:5]

        serializer = MaintenanceReminderSerializer(
            [
                {
                    'vehicle': str(reminder.vehicle),
                    'due_date': reminder.next_due_date,
                    'type': 'Service',
                    'status': 'due' if reminder.next_due_date <= today + timedelta(days=30) else 'active',
                }
                for reminder in reminders
            ],
            many=True
        )
        return Response(serializer.data)


class PredictMaintenanceView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        usage = float(request.data.get('usage', 0))
        vehicle_id = request.data.get('vehicle_id')
        window = float(request.data.get('window', 1000))
        next_service = None
        message = 'Maintain regularly'
        source = 'heuristic'

        model_path = settings.BASE_DIR / 'model.pkl'
        if model_path.exists():
            try:
                model = load(model_path)
                prediction = model.predict([[usage, window]])
                estimated_days = int(round(float(prediction[0])))
                next_service = date.today() + timedelta(days=estimated_days)
                source = 'ml'
                message = 'Predicted by ML model'
            except Exception:
                next_service = None

        if not next_service:
            next_service = date.today() + timedelta(days=int(30 if usage < window else 15))
            message = 'Heuristic estimation'
        if usage >= window:
            message = 'Schedule service soon'

        return Response(
            {
                'next_service_date': next_service,
                'confidence': 0.8,
                'message': message,
                'vehicle_id': vehicle_id,
                'source': source,
            }
        )


class VehicleCostSummaryView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, vehicle_id):
        vehicle = get_object_or_404(Vehicle, id=vehicle_id, owner=request.user)
        logs = MaintenanceLog.objects.filter(vehicle=vehicle)
        total_spent = vehicle.total_maintenance_cost
        average_monthly = 0.0
        if logs.exists():
            first_log = logs.order_by('date').first()
            months = max(1, ((date.today() - first_log.date).days // 30) + 1)
            average_monthly = total_spent / months
        next_due = logs.filter(next_due_date__gte=date.today()).order_by('next_due_date').first()
        next_service = next_due.next_due_date.isoformat() if next_due else None

        return Response(
            {
                'total_spent': round(total_spent, 2),
                'average_monthly': round(average_monthly, 2),
                'next_service_estimate': next_service or 'TBD',
            }
        )


class DashboardAnalyticsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        vehicles = Vehicle.objects.filter(owner=request.user)
        logs = MaintenanceLog.objects.filter(vehicle__in=vehicles)
        due_threshold = date.today() + timedelta(days=30)

        monthly = (
            logs.annotate(month=TruncMonth('date'))
            .values('month')
            .annotate(total_cost=Sum('cost'))
            .order_by('month')
        )
        cost_trend = []
        for entry in monthly:
            month = entry['month']
            if not month:
                continue
            actual = round(entry['total_cost'] or 0, 2)
            cost_trend.append(
                {
                    'label': month.strftime('%b %Y'),
                    'planned': int(actual * 1.1),
                    'actual': actual,
                }
            )

        if not cost_trend:
            cost_trend = [
                {'label': date.today().strftime('%b %Y'), 'planned': 0, 'actual': 0}
            ]

        total_cost = logs.aggregate(total=Sum('cost'))['total'] or 0
        avg_cost = logs.aggregate(avg=Avg('cost'))['avg'] or 0
        most_expensive_vehicle = (
            vehicles.annotate(total_spent=Sum('maintenance_logs__cost'))
            .order_by('-total_spent')
            .first()
        )

        return Response(
            {
                'cost_trend': cost_trend[-6:],
                'summary': {
                    'vehicle_count': vehicles.count(),
                    'maintenance_due': logs.filter(next_due_date__lte=due_threshold).count(),
                    'total_maintenance_cost': round(total_cost, 2),
                    'avg_service_cost': round(avg_cost, 2),
                    'most_expensive_vehicle': {
                        'id': most_expensive_vehicle.id if most_expensive_vehicle else None,
                        'name': str(most_expensive_vehicle) if most_expensive_vehicle else None,
                        'total_spent': round(
                            most_expensive_vehicle.total_spent if most_expensive_vehicle else 0, 2
                        ),
                    },
                },
            }
        )


class CreateCheckoutSessionView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        stripe.api_key = os.environ.get('STRIPE_SECRET_KEY') or getattr(settings, 'STRIPE_SECRET_KEY', '')
        amount = int(request.data.get('amount', 1000))
        currency = request.data.get('currency', 'INR')
        session_urls = {
            'success_url': request.data.get('success_url', 'https://example.com/success'),
            'cancel_url': request.data.get('cancel_url', 'https://example.com/cancel'),
        }

        if not stripe.api_key:
            return Response({'detail': 'Stripe secret key not configured'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        checkout_session = stripe.checkout.Session.create(
            payment_method_types=['card'],
            line_items=[{
                'price_data': {
                    'currency': currency.lower(),
                    'product_data': {'name': request.data.get('description', 'Autopredator Payment')},
                    'unit_amount': amount,
                },
                'quantity': 1,
            }],
            mode='payment',
            success_url=session_urls['success_url'],
            cancel_url=session_urls['cancel_url'],
        )

        transaction = PaymentTransaction.objects.create(
            user=request.user,
            amount=amount / 100,
            currency=currency.upper(),
            status='pending',
            stripe_session_id=checkout_session.id,
        )

        serializer = PaymentTransactionSerializer(transaction)
        return Response({'session_url': checkout_session.url, 'transaction': serializer.data})
