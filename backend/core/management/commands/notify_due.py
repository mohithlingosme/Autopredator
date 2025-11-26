from datetime import date, timedelta

from django.conf import settings
from django.core.mail import send_mail
from django.core.management.base import BaseCommand

from core.models import Notification, Vehicle


class Command(BaseCommand):
    help = 'Sends reminder emails for upcoming vehicle services and document expirations.'

    def handle(self, *args, **options):
        today = date.today()
        due_threshold = today + timedelta(days=7)
        sent = 0

        for vehicle in Vehicle.objects.select_related('owner').all():
            if not vehicle.owner.email:
                continue

            reminders = []
            next_log = (
                vehicle.maintenance_logs.filter(next_due_date__gte=today)
                .order_by('next_due_date')
                .first()
            )
            if next_log and next_log.next_due_date <= due_threshold:
                reminders.append(
                    f"{vehicle} is due for service on {next_log.next_due_date.isoformat()}."
                )

            if vehicle.created_at:
                expiry = vehicle.created_at.date() + timedelta(days=365)
                if expiry <= due_threshold:
                    reminders.append(
                        f"Registration document for {vehicle} expires on {expiry.isoformat()}."
                    )

            for reminder in reminders:
                send_mail(
                    'Reminder: Service Due',
                    reminder,
                    settings.DEFAULT_FROM_EMAIL,
                    [vehicle.owner.email],
                    fail_silently=True,
                )
                Notification.objects.create(user=vehicle.owner, message=reminder)
                sent += 1

        self.stdout.write(self.style.SUCCESS(f'Sent {sent} reminders.'))
