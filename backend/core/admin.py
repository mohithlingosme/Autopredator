from django.contrib import admin

from .models import (
    ApiUsageLog,
    FeatureUsageLog,
    Fleet,
    MaintenanceLog,
    Notification,
    PaymentTransaction,
    Product,
    Vehicle,
    VehicleCountSnapshot,
)


@admin.register(Vehicle)
class VehicleAdmin(admin.ModelAdmin):
    list_display = ('make', 'model', 'year', 'owner', 'vin')
    search_fields = ('vin', 'make', 'model')


@admin.register(MaintenanceLog)
class MaintenanceAdmin(admin.ModelAdmin):
    list_display = ('vehicle', 'description', 'date', 'next_due_date')
    list_filter = ('vehicle',)


@admin.register(Fleet)
class FleetAdmin(admin.ModelAdmin):
    list_display = ('name', 'manager')


@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    list_display = ('name', 'category', 'price', 'seller')


@admin.register(Notification)
class NotificationAdmin(admin.ModelAdmin):
    list_display = ('user', 'message', 'read', 'created_at')
    list_filter = ('read',)


@admin.register(PaymentTransaction)
class PaymentTransactionAdmin(admin.ModelAdmin):
    list_display = ('user', 'amount', 'currency', 'status', 'created_at')


@admin.register(ApiUsageLog)
class ApiUsageLogAdmin(admin.ModelAdmin):
    list_display = ('path', 'method', 'status_code', 'user', 'created_at')
    list_filter = ('method', 'status_code')


@admin.register(FeatureUsageLog)
class FeatureUsageLogAdmin(admin.ModelAdmin):
    list_display = ('feature_name', 'user', 'created_at')
    search_fields = ('feature_name', 'user__email')


@admin.register(VehicleCountSnapshot)
class VehicleCountSnapshotAdmin(admin.ModelAdmin):
    list_display = ('user', 'count', 'recorded_at')
