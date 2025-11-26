from datetime import date

from django.contrib.auth import get_user_model
from rest_framework import serializers

from .models import (
    Fleet,
    MaintenanceLog,
    Notification,
    PaymentTransaction,
    Product,
    Vehicle,
)

User = get_user_model()


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'username', 'email')


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=8)
    name = serializers.CharField(write_only=True, required=False)
    account_type = serializers.CharField(write_only=True, required=False)

    class Meta:
        model = User
        fields = ('username', 'email', 'password', 'name', 'account_type')

    def create(self, validated_data):
        validated_data.pop('account_type', None)
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data['email'],
            password=validated_data['password'],
        )
        user.first_name = validated_data.get('name', '')
        user.save()
        return user


class VehicleSerializer(serializers.ModelSerializer):
    owner = serializers.ReadOnlyField(source='owner.id')
    status = serializers.SerializerMethodField()
    next_service_date = serializers.SerializerMethodField()
    last_service_date = serializers.SerializerMethodField()
    total_maintenance_cost = serializers.SerializerMethodField()
    avg_monthly_service_cost = serializers.SerializerMethodField()

    class Meta:
        model = Vehicle
        fields = (
            'id',
            'owner',
            'make',
            'model',
            'year',
            'vin',
            'fuel_type',
            'vehicle_type',
            'mileage',
            'registration_doc',
            'created_at',
            'status',
            'next_service_date',
            'last_service_date',
            'total_maintenance_cost',
            'avg_monthly_service_cost',
        )

    def get_status(self, obj):
        latest = obj.maintenance_logs.order_by('-next_due_date').first()
        if latest and latest.next_due_date:
            if latest.next_due_date <= date.today():
                return 'due'
            return 'active'
        return 'new'

    def get_next_service_date(self, obj):
        next_due = obj.maintenance_logs.filter(next_due_date__gte=date.today()).order_by('next_due_date').first()
        return next_due.next_due_date if next_due else None

    def get_last_service_date(self, obj):
        last = obj.maintenance_logs.order_by('-date').first()
        return last.date if last else None

    def get_total_maintenance_cost(self, obj):
        return obj.total_maintenance_cost

    def get_avg_monthly_service_cost(self, obj):
        return obj.average_monthly_service_cost


class MaintenanceLogSerializer(serializers.ModelSerializer):
    class Meta:
        model = MaintenanceLog
        fields = '__all__'
        read_only_fields = ('created_at',)


class FleetSerializer(serializers.ModelSerializer):
    manager = serializers.ReadOnlyField(source='manager.id')
    vehicles = serializers.PrimaryKeyRelatedField(queryset=Vehicle.objects.all(), many=True, required=False)

    class Meta:
        model = Fleet
        fields = '__all__'


class ProductSerializer(serializers.ModelSerializer):
    seller = serializers.ReadOnlyField(source='seller.id')

    class Meta:
        model = Product
        fields = '__all__'


class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = '__all__'
        read_only_fields = ('created_at',)


class PaymentTransactionSerializer(serializers.ModelSerializer):
    class Meta:
        model = PaymentTransaction
        fields = '__all__'


class MaintenanceReminderSerializer(serializers.Serializer):
    vehicle = serializers.CharField()
    due_date = serializers.DateField()
    type = serializers.CharField()
    status = serializers.CharField()
