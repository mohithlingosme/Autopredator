import csv
from pathlib import Path

from django.conf import settings
from django.core.management.base import BaseCommand

from core.models import MaintenanceLog


class Command(BaseCommand):
    help = 'Exports maintenance history records as CSV for AI training.'

    def handle(self, *args, **options):
        dataset_dir = settings.BASE_DIR / 'data'
        dataset_dir.mkdir(parents=True, exist_ok=True)
        output_path = dataset_dir / 'maintenance_dataset.csv'

        fieldnames = ['mileage', 'vehicle_type', 'last_service_date', 'next_due_date', 'cost']
        with output_path.open('w', newline='', encoding='utf-8') as csvfile:
            writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
            writer.writeheader()

            for log in MaintenanceLog.objects.select_related('vehicle').order_by('-date'):
                writer.writerow(
                    {
                        'mileage': log.vehicle.mileage,
                        'vehicle_type': log.vehicle.vehicle_type,
                        'last_service_date': log.date.isoformat(),
                        'next_due_date': log.next_due_date.isoformat(),
                        'cost': round(log.cost, 2),
                    }
                )

        self.stdout.write(f'Maintenance dataset exported to {output_path}')
