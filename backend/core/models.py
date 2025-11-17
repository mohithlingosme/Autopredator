from datetime import date

from django.contrib.auth import get_user_model
from django.db import models
from django.db.models import Sum

from .validators import validate_upload_file

User = get_user_model()


class Vehicle(models.Model):
    owner = models.ForeignKey(User, on_delete=models.CASCADE, related_name='vehicles')
    make = models.CharField(max_length=100)
    model = models.CharField(max_length=100)
    year = models.PositiveIntegerField()
    vin = models.CharField(max_length=100, unique=True)
    fuel_type = models.CharField(max_length=50)
    mileage = models.PositiveIntegerField(default=0)
    vehicle_type = models.CharField(max_length=50, default='unknown')
    registration_doc = models.FileField(
        upload_to='docs/',
        null=True,
        blank=True,
        validators=[validate_upload_file]
    )
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.make} {self.model} ({self.vin[-6:]})"

    @property
    def total_maintenance_cost(self) -> float:
        return self.maintenance_logs.aggregate(total=Sum('cost'))['total'] or 0.0

    @property
    def average_monthly_service_cost(self) -> float:
        logs = self.maintenance_logs.order_by('date')
        if not logs.exists():
            return 0.0
        first_log = logs.first().date
        months = max(1, ((date.today() - first_log).days // 30) + 1)
        return round(self.total_maintenance_cost / months, 2)


class MaintenanceLog(models.Model):
    vehicle = models.ForeignKey(Vehicle, on_delete=models.CASCADE, related_name='maintenance_logs')
    description = models.TextField()
    cost = models.FloatField()
    date = models.DateField()
    next_due_date = models.DateField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.vehicle} @ {self.date}"


class Fleet(models.Model):
    name = models.CharField(max_length=120)
    manager = models.ForeignKey(User, on_delete=models.CASCADE, related_name='fleets')
    vehicles = models.ManyToManyField(Vehicle, related_name='fleets', blank=True)

    def __str__(self):
        return f"{self.name} ({self.manager.username})"


class Product(models.Model):
    name = models.CharField(max_length=100)
    category = models.CharField(max_length=50)
    description = models.TextField()
    price = models.FloatField()
    seller = models.ForeignKey(User, on_delete=models.CASCADE, related_name='products')
    image = models.ImageField(upload_to='products/', null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.name} ({self.category})"


class Notification(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='notifications')
    message = models.TextField()
    read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.email} - {self.message[:30]}"


class PaymentTransaction(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='payments')
    amount = models.FloatField()
    currency = models.CharField(max_length=8, default='INR')
    status = models.CharField(max_length=64, default='pending')
    stripe_session_id = models.CharField(max_length=255, blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.email} - {self.status} ({self.amount} {self.currency})"
