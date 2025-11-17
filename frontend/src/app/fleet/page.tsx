'use client';

import { useEffect, useState } from 'react';

import FleetManagerPanel from '@/components/FleetManagerPanel';
import apiClient from '@/lib/api';
import { Vehicle } from '@/types';

interface FleetVehicleView {
  id: number;
  name: string;
  driver: string;
  status: 'active' | 'available' | 'due' | 'offline';
  fuelUsage: string;
  location?: string;
  distanceToday?: number;
  costPerKm?: number;
}

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
  const [fleetVehicles, setFleetVehicles] = useState<FleetVehicleView[]>([]);
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

        const vehiclesView = vehiclesRes.data.map(vehicle => ({
          id: vehicle.id,
          name: `${vehicle.make} ${vehicle.model}`,
          driver: 'Team assigned',
          status: (vehicle.status ?? 'active') as 'active' | 'available' | 'due' | 'offline',
          fuelUsage: vehicle.fuel_type ? `${vehicle.fuel_type} ready` : 'Fuel data not tracked',
          location: 'Region HQ',
          distanceToday: 0,
          costPerKm: 0
        }));

        const summaryAnalytics: FleetAnalyticsPoint[] = [
          { label: 'Fleet size', value: analyticsRes.data.summary.vehicle_count },
          { label: 'Maintenance due', value: analyticsRes.data.summary.maintenance_due }
        ];

        setFleetVehicles(vehiclesView);
        setAnalytics(summaryAnalytics);
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
        <FleetManagerPanel fleetVehicles={fleetVehicles} analytics={analytics} />
      </div>
    </section>
  );
}
