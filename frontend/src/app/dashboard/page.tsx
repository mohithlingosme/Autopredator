'use client';

import { useEffect, useState } from 'react';

import DashboardContent from '@/components/DashboardContent';
import apiClient from '@/lib/api';
import { Vehicle } from '@/types';

interface MaintenanceReminderApi {
  vehicle: string;
  due_date: string;
  type: string;
  status: 'due' | 'active' | 'critical';
}

interface MaintenanceReminder {
  id: number;
  vehicleName: string;
  dueDate: string;
  type: string;
  status: 'due' | 'active' | 'critical';
}

interface CostPoint {
  label: string;
  planned: number;
  actual: number;
}

export default function DashboardPage() {
  const [vehicles, setVehicles] = useState<Vehicle[]>([]);
  const [reminders, setReminders] = useState<MaintenanceReminder[]>([]);
  const [costAnalytics, setCostAnalytics] = useState<CostPoint[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;

    const loadDashboard = async () => {
      try {
        const [vehiclesRes, remindersRes, analyticsRes] = await Promise.all([
          apiClient.get<Vehicle[]>('/vehicles/'),
          apiClient.get<MaintenanceReminderApi[]>('/reminders/'),
          apiClient.get<{ cost_trend: CostPoint[] }>('/analytics/cost/')
        ]);

        if (!cancelled) {
          setVehicles(vehiclesRes.data);
          setReminders(
            remindersRes.data.map((reminder, index) => ({
              id: index,
              vehicleName: reminder.vehicle,
              dueDate: reminder.due_date,
              type: reminder.type,
              status: reminder.status
            }))
          );
          setCostAnalytics(analyticsRes.data.cost_trend ?? []);
        }
      } catch (err) {
        if (!cancelled) {
          setError('Unable to load dashboard data right now.');
        }
      } finally {
        if (!cancelled) {
          setLoading(false);
        }
      }
    };

    loadDashboard();
    return () => {
      cancelled = true;
    };
  }, []);

  return (
    <section className="container mx-auto px-4 py-10">
      {loading ? (
        <div className="min-h-[400px] rounded-3xl border border-dashed border-gray-300 bg-white/80 flex items-center justify-center text-gray-500">
          Loading dashboard...
        </div>
      ) : error ? (
        <div className="min-h-[400px] rounded-3xl border border-red-200 bg-white/80 flex items-center justify-center text-red-600">
          {error}
        </div>
      ) : (
        <DashboardContent vehicles={vehicles} maintenanceReminders={reminders} costAnalytics={costAnalytics} />
      )}
    </section>
  );
}
