'use client';

import { useEffect, useState } from 'react';

import apiClient from '@/lib/api';
import VehicleDetailView from './VehicleDetailView';
import { Vehicle } from '@/types';

interface MaintenanceApiRecord {
  id: number;
  description: string;
  cost: number;
  date: string;
  next_due_date?: string;
}

interface CostSummaryApi {
  total_spent: number;
  average_monthly: number;
  next_service_estimate: string;
}

interface VehicleDetailFetcherProps {
  vehicleId: string;
}

export default function VehicleDetailFetcher({ vehicleId }: VehicleDetailFetcherProps) {
  const [vehicle, setVehicle] = useState<Vehicle | null>(null);
  const [maintenanceLogs, setMaintenanceLogs] = useState<MaintenanceApiRecord[]>([]);
  const [costSummary, setCostSummary] = useState<CostSummaryApi | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let cancelled = false;

    const load = async () => {
      try {
        const [vehicleRes, logsRes, summaryRes] = await Promise.all([
          apiClient.get<Vehicle>(`/vehicles/${vehicleId}/`),
          apiClient.get<MaintenanceApiRecord[]>('/maintenance/', { params: { vehicle: vehicleId } }),
          apiClient.get<CostSummaryApi>(`/vehicles/${vehicleId}/cost-summary/`)
        ]);

        if (cancelled) {
          return;
        }

        setVehicle(vehicleRes.data);
        setMaintenanceLogs(logsRes.data);
        setCostSummary(summaryRes.data);
      } catch (err) {
        setError('Unable to load the vehicle data right now.');
      } finally {
        if (!cancelled) {
          setLoading(false);
        }
      }
    };

    load();
    return () => {
      cancelled = true;
    };
  }, [vehicleId]);

  if (loading) {
    return (
      <div className="min-h-[420px] flex items-center justify-center">
        <p className="text-sm text-gray-500">Loading vehicle data…</p>
      </div>
    );
  }

  if (error || !vehicle || !costSummary) {
    return (
      <div className="min-h-[420px] flex items-center justify-center">
        <p className="text-sm text-red-600">{error || 'Unable to render the vehicle right now.'}</p>
      </div>
    );
  }

  return (
    <VehicleDetailView
      vehicle={vehicle}
      maintenanceLogs={maintenanceLogs}
      costSummary={{
        totalSpent: costSummary.total_spent,
        averageMonthly: costSummary.average_monthly,
        nextServiceEstimate: costSummary.next_service_estimate
      }}
    />
  );
}
