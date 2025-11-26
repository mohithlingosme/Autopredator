from datetime import timedelta
from unittest.mock import patch

from django.contrib.auth import get_user_model
from django.core.management import call_command
from django.urls import reverse
from django.utils import timezone
from rest_framework.test import APITestCase

from core.models import (
    FeatureUsageLog,
    MaintenanceLog,
    Notification,
    Vehicle,
    VehicleCountSnapshot,
)

class AuthTests(APITestCase):
    def test_register_login_and_me(self):
        register_url = reverse('register')
        data = {'username': 'devuser', 'email': 'dev@example.com', 'password': 'StrongPass1'}
        response = self.client.post(register_url, data)
        self.assertEqual(response.status_code, 201)

        token_url = reverse('token_obtain_pair')
        token_response = self.client.post(token_url, {'username': 'devuser', 'password': 'StrongPass1'})
        self.assertIn('access', token_response.data)
        access = token_response.data['access']

        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {access}')
        me_url = reverse('me')
        me_response = self.client.get(me_url)
        self.assertEqual(me_response.status_code, 200)
        self.assertEqual(me_response.data['username'], 'devuser')


class VehicleTests(APITestCase):
    def setUp(self):
        register_url = reverse('register')
        self.client.post(register_url, {'username': 'fleet', 'email': 'fleet@example.com', 'password': 'FleetPass123'})
        token_response = self.client.post(reverse('token_obtain_pair'), {'username': 'fleet', 'password': 'FleetPass123'})
        self.token = token_response.data['access']
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {self.token}')
        owner = get_user_model().objects.get(username='fleet')
        self.vehicle = Vehicle.objects.create(
            owner=owner,
            make='Mahindra',
            model='Bolero',
            year=2022,
            vin='MH12TEST123456',
            fuel_type='Diesel',
            mileage=43000,
            vehicle_type='truck'
        )
        today = timezone.now().date()
        MaintenanceLog.objects.create(
            vehicle=self.vehicle,
            description='Oil change',
            cost=500,
            date=today - timedelta(days=60),
            next_due_date=today + timedelta(days=30)
        )
        MaintenanceLog.objects.create(
            vehicle=self.vehicle,
            description='Brake pads',
            cost=700,
            date=today - timedelta(days=30),
            next_due_date=today + timedelta(days=90)
        )

    def test_vehicle_crud(self):
        create_url = reverse('vehicle-list')
        payload = {
            'make': 'Mahindra',
            'model': 'Thar',
            'year': 2023,
            'vin': 'MH12TESTVIN',
            'fuel_type': 'Petrol',
        }
        response = self.client.post(create_url, payload)
        self.assertEqual(response.status_code, 201)
        vehicle_id = response.data['id']

        detail_url = reverse('vehicle-detail', kwargs={'pk': vehicle_id})
        detail = self.client.get(detail_url)
        self.assertEqual(detail.data['vin'], 'MH12TESTVIN')

        update_response = self.client.patch(detail_url, {'model': 'Thar Plus'})
        self.assertEqual(update_response.data['model'], 'Thar Plus')

        delete_response = self.client.delete(detail_url)
        self.assertEqual(delete_response.status_code, 204)

    def test_cost_summary_endpoint(self):
        url = reverse('vehicle_cost_summary', kwargs={'vehicle_id': self.vehicle.id})
        response = self.client.get(url)
        self.assertEqual(response.status_code, 200)
        self.assertAlmostEqual(response.data['total_spent'], 1200, places=2)
        self.assertIn('next_service_estimate', response.data)

    def test_dashboard_analytics(self):
        response = self.client.get(reverse('analytics_cost'))
        self.assertEqual(response.status_code, 200)
        self.assertIn('summary', response.data)
        self.assertEqual(response.data['summary']['vehicle_count'], 1)
        self.assertGreaterEqual(response.data['summary']['total_maintenance_cost'], 1200)
        self.assertTrue(
            VehicleCountSnapshot.objects.filter(user=self.vehicle.owner, count=1).exists()
        )

    def test_predict_endpoint_logs_usage(self):
        response = self.client.post(
            reverse('predict'),
            {
                'vehicle_id': self.vehicle.id,
                'mileage': 45000,
                'vehicle_type': 'truck',
                'last_service_days': 45,
            },
        )
        self.assertEqual(response.status_code, 200)
        self.assertIn('next_service_date', response.data)
        self.assertTrue(FeatureUsageLog.objects.filter(feature_name='maintenance_prediction').exists())


class NotificationCommandTests(APITestCase):
    def test_notify_due_creates_notifications(self):
        register_url = reverse('register')
        self.client.post(register_url, {'username': 'notify', 'email': 'notify@example.com', 'password': 'Notify123!'})
        token_response = self.client.post(reverse('token_obtain_pair'), {'username': 'notify', 'password': 'Notify123!'})
        token = token_response.data['access']
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {token}')
        owner = get_user_model().objects.get(username='notify')
        vehicle = Vehicle.objects.create(
            owner=owner,
            make='Tesla',
            model='Model S',
            year=2023,
            vin='TSLA1234567890',
            fuel_type='Electric',
            mileage=12000,
            vehicle_type='sedan'
        )
        today = timezone.now().date()
        MaintenanceLog.objects.create(
            vehicle=vehicle,
            description='Coolant check',
            cost=300,
            date=today - timedelta(days=60),
            next_due_date=today + timedelta(days=5)
        )
        with patch('core.management.commands.notify_due.send_mail') as mock_send:
            call_command('notify_due')
            self.assertGreaterEqual(Notification.objects.filter(user=owner).count(), 1)
            mock_send.assert_called()
