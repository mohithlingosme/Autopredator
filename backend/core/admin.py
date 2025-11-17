from django.contrib import admin

from .models import (
    Fleet,
    MaintenanceLog,
    Notification,
    PaymentTransaction,
    Product,
    Vehicle,
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
