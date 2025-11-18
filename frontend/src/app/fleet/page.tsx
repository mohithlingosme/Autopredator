'use client';

import { useEffect, useState } from 'react';

import FleetManagerPanel from '@/components/FleetManagerPanel';
import apiClient from '@/lib/api';
import { Vehicle } from '@/types';

interface FleetAnalyticsPoint {
  label: string;
  value: number;
}

interface AnalyticsResponse {
  summary: {
    vehicle_count: number;
    maintenance_due: number;
  };
}

export default function FleetManagerPage() {
  const [fleetVehicles, setFleetVehicles] = useState<Vehicle[]>([]);
  const [analytics, setAnalytics] = useState<FleetAnalyticsPoint[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;

    const loadFleet = async () => {
      try {
        const [vehiclesRes, analyticsRes] = await Promise.all([
          apiClient.get<Vehicle[]>('/vehicles/'),
          apiClient.get<AnalyticsResponse>('/analytics/cost/')
        ]);

        if (cancelled) return;

        setFleetVehicles(vehiclesRes.data);
        setAnalytics([
          { label: 'Fleet size', value: analyticsRes.data.summary.vehicle_count },
          { label: 'Maintenance due', value: analyticsRes.data.summary.maintenance_due }
        ]);
      } catch {
        if (!cancelled) {
          setError('Unable to load fleet data at the moment.');
        }
      } finally {
        if (!cancelled) {
          setLoading(false);
        }
      }
    };

    loadFleet();
    return () => {
      cancelled = true;
    };
  }, []);

  const viewModels = fleetVehicles.map(vehicle => ({
    id: vehicle.id,
    name: `${vehicle.make} ${vehicle.model}`,
    status: vehicle.status ?? 'active',
    mileage: vehicle.mileage ?? 0,
    vehicle_type: vehicle.vehicle_type,
    next_service_date: vehicle.next_service_date ?? undefined
  }));

  if (loading) {
    return (
      <section className="min-h-screen bg-gray-50 py-12">
        <div className="container mx-auto px-4">
          <div className="rounded-3xl border border-dashed border-gray-300 bg-white/80 p-8 text-center text-gray-500">
            Loading fleet overview...
          </div>
        </div>
      </section>
    );
  }

  if (error) {
    return (
      <section className="min-h-screen bg-gray-50 py-12">
        <div className="container mx-auto px-4">
          <div className="rounded-3xl border border-red-200 bg-white/80 p-8 text-center text-red-600">{error}</div>
        </div>
      </section>
    );
  }

  return (
    <section className="min-h-screen bg-gray-50 py-12">
      <div className="container mx-auto px-4">
        <FleetManagerPanel fleetVehicles={viewModels} analytics={analytics} />
      </div>
    </section>
  );
}
