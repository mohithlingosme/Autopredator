'use client';

import { AxiosError } from 'axios';
import { useRouter } from 'next/navigation';
import { useState } from 'react';

import apiClient from '@/lib/api';
import { Vehicle } from '@/types';

interface MaintenanceRecord {
  id: number;
  description: string;
  cost: number;
  date: string;
  next_due_date?: string;
}

interface CostSummary {
  totalSpent: number;
  averageMonthly: number;
  nextServiceEstimate: string;
}

interface VehicleDetailViewProps {
  vehicle: Vehicle;
  maintenanceLogs: MaintenanceRecord[];
  costSummary: CostSummary;
}

export default function VehicleDetailView({ vehicle, maintenanceLogs, costSummary }: VehicleDetailViewProps) {
  const router = useRouter();
  const [feedback, setFeedback] = useState<string | null>(null);
  const [loading, setLoading] = useState<'idle' | 'scheduling' | 'deleting'>('idle');

  const handleSchedule = async () => {
    setLoading('scheduling');
    setFeedback(null);

    try {
      const response = await apiClient.post('/predict/', {
        vehicle_id: vehicle.id,
        usage: 5000,
        window: 1200
      });
      setFeedback(
        `Predicted next service on ${response.data.next_service_date} (${response.data.message}).`
      );
    } catch (err) {
      const message =
        err instanceof AxiosError && err.response?.data?.detail
          ? err.response.data.detail
          : 'Unable to predict the next service right now.';
      setFeedback(message);
    } finally {
      setLoading('idle');
    }
  };

  const handleDelete = async () => {
    const confirmed = window.confirm('Delete this vehicle from the fleet? This cannot be undone.');
    if (!confirmed) {
      return;
    }

    setLoading('deleting');
    setFeedback(null);
    try {
      await apiClient.delete(`/vehicles/${vehicle.id}/`);
      setFeedback('Vehicle deleted. Redirecting to dashboard …');
      router.push('/dashboard');
    } catch {
      setFeedback('Unable to delete vehicle right now.');
    } finally {
      setLoading('idle');
    }
  };

  return (
    <div className="space-y-8">
      <section className="rounded-3xl border border-gray-200 bg-white p-8 shadow-md">
        <div className="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
          <div>
            <p className="text-xs uppercase tracking-[0.4em] text-gray-400">Vehicle detail</p>
            <h1 className="text-3xl font-semibold text-charcoal mt-1">
              {vehicle.make} {vehicle.model}
            </h1>
            <p className="text-sm text-gray-500">
              {vehicle.vin ?? 'VIN not available'} - {vehicle.fuel_type ?? 'Fuel type unknown'}
            </p>
          </div>
          <div className="flex gap-3">
            <button
              type="button"
              className="btn-secondary px-5 py-3"
              onClick={handleSchedule}
              disabled={loading !== 'idle'}
            >
              {loading === 'scheduling' ? 'Scheduling…' : 'Schedule maintenance'}
            </button>
            <button
              type="button"
              className="btn-secondary border-red-500 text-red-600 px-5 py-3"
              onClick={handleDelete}
              disabled={loading !== 'idle'}
            >
              {loading === 'deleting' ? 'Deleting…' : 'Delete vehicle'}
            </button>
          </div>
        </div>
        <div className="mt-6 grid gap-4 md:grid-cols-3">
          <div>
            <p className="text-xs uppercase tracking-[0.4em] text-gray-400">Make / Model</p>
            <p className="text-lg font-semibold text-charcoal">{vehicle.make}</p>
            <p className="text-sm text-gray-500">{vehicle.model}</p>
          </div>
          <div>
            <p className="text-xs uppercase tracking-[0.4em] text-gray-400">Status</p>
            <p className="text-lg font-semibold text-charcoal">{vehicle.status ? vehicle.status.toUpperCase() : 'Unknown'}</p>
          </div>
          <div>
            <p className="text-xs uppercase tracking-[0.4em] text-gray-400">Year</p>
            <p className="text-lg font-semibold text-charcoal">{vehicle.year ?? 'Unknown'}</p>
          </div>
        </div>
        {feedback && <p className="mt-4 text-sm text-blue">{feedback}</p>}
      </section>

      <section className="grid gap-4 md:grid-cols-2">
        <div className="rounded-2xl border border-gray-200 bg-white p-5">
          <div className="flex items-center justify-between mb-4">
            <div>
              <p className="text-xs uppercase tracking-[0.4em] text-gray-400">Maintenance logs</p>
              <h2 className="text-xl font-semibold text-charcoal">History</h2>
            </div>
          </div>
          <div className="space-y-3">
            {maintenanceLogs.length ? (
              maintenanceLogs.map(record => (
                <div key={record.id} className="rounded-2xl border border-gray-100 p-4 bg-gray-50">
                  <p className="text-sm text-gray-500">{record.date}</p>
                  <p className="text-lg font-semibold text-charcoal">{record.description}</p>
                  <p className="text-sm text-gray-500">Rs {record.cost.toLocaleString()}</p>
                  {record.next_due_date && (
                    <p className="text-xs uppercase tracking-[0.4em] text-blue-500">
                      Next due {record.next_due_date}
                    </p>
                  )}
                </div>
              ))
            ) : (
              <p className="text-sm text-gray-500">No maintenance logs available.</p>
            )}
          </div>
        </div>

        <div className="rounded-2xl border border-gray-200 bg-white p-5">
          <div className="flex items-center justify-between mb-4">
            <div>
              <p className="text-xs uppercase tracking-[0.4em] text-gray-400">Cost summary</p>
              <h2 className="text-xl font-semibold text-charcoal">Ownership expenses</h2>
            </div>
          </div>
          <div className="space-y-3">
            <div className="flex items-center justify-between rounded-2xl border border-gray-100 p-3">
              <div>
                <p className="text-sm text-gray-500">Total spent</p>
                <p className="text-lg font-semibold text-charcoal">Rs {costSummary.totalSpent.toLocaleString()}</p>
              </div>
            </div>
            <div className="flex items-center justify-between rounded-2xl border border-gray-100 p-3">
              <div>
                <p className="text-sm text-gray-500">Avg / month</p>
                <p className="text-lg font-semibold text-charcoal">Rs {costSummary.averageMonthly.toLocaleString()}</p>
              </div>
            </div>
            <div className="flex items-center justify-between rounded-2xl border border-gray-100 p-3">
              <div>
                <p className="text-sm text-gray-500">Next service estimate</p>
                <p className="text-lg font-semibold text-charcoal">{costSummary.nextServiceEstimate}</p>
              </div>
            </div>
          </div>
        </div>
      </section>
    </div>
  );
}
