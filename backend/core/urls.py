from django.urls import include, path
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

from .views import (
    CreateCheckoutSessionView,
    DashboardAnalyticsView,
    FleetViewSet,
    MaintenanceLogViewSet,
    MaintenanceReminderView,
    MeView,
    NotificationViewSet,
    PredictMaintenanceView,
    ProductViewSet,
    RegisterView,
    VehicleCostSummaryView,
    VehicleViewSet,
)

router = DefaultRouter()
router.register('vehicles', VehicleViewSet, basename='vehicle')
router.register('maintenance', MaintenanceLogViewSet, basename='maintenance')
router.register('fleets', FleetViewSet, basename='fleet')
router.register('products', ProductViewSet, basename='product')
router.register('notifications', NotificationViewSet, basename='notification')

urlpatterns = [
    path('auth/register/', RegisterView.as_view(), name='register'),
    path('auth/me/', MeView.as_view(), name='me'),
    path('auth/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('auth/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('reminders/', MaintenanceReminderView.as_view(), name='reminders'),
    path('analytics/cost/', DashboardAnalyticsView.as_view(), name='analytics_cost'),
    path('predict/', PredictMaintenanceView.as_view(), name='predict'),
    path('vehicles/<int:vehicle_id>/cost-summary/', VehicleCostSummaryView.as_view(), name='vehicle_cost_summary'),
    path('payment/create-checkout-session/', CreateCheckoutSessionView.as_view(), name='create_checkout'),
    path('', include(router.urls)),
]
