'use client';

import Link from 'next/link';
import { useEffect, useState } from 'react';

import VehicleCard from '@/components/VehicleCard';
import apiClient from '@/lib/api';
import { Vehicle } from '@/types';

export default function VehiclesPage() {
  const [vehicles, setVehicles] = useState<Vehicle[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;

    const loadVehicles = async () => {
      try {
        const response = await apiClient.get<Vehicle[]>('/vehicles/');
        if (!cancelled) {
          setVehicles(response.data);
        }
      } catch {
        if (!cancelled) {
          setError('Unable to load your fleet at the moment.');
        }
      } finally {
        if (!cancelled) {
          setLoading(false);
        }
      }
    };

    loadVehicles();
    return () => {
      cancelled = true;
    };
  }, []);

  return (
    <section className="min-h-screen bg-gray-50 py-12">
      <div className="container mx-auto px-4 space-y-8">
        <div className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
          <div>
            <p className="text-xs uppercase tracking-[0.4em] text-gray-400">Vehicle catalog</p>
            <h1 className="text-3xl font-semibold text-charcoal">Manage your fleet</h1>
          </div>
          <Link href="/vehicle/add" className="btn-primary px-5 py-3 text-sm font-semibold">
            Add Vehicle
          </Link>
        </div>
        {loading ? (
          <div className="rounded-2xl border border-dashed border-gray-300 bg-white/70 p-8 text-center text-gray-500">
            Loading vehicles…
          </div>
        ) : error ? (
          <div className="rounded-2xl border border-red-300 bg-white/70 p-8 text-center text-red-600">{error}</div>
        ) : vehicles.length ? (
          <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
            {vehicles.map(vehicle => (
              <VehicleCard key={vehicle.id} vehicle={vehicle} verified={vehicle.is_featured} />
            ))}
          </div>
        ) : (
          <div className="rounded-2xl border border-dashed border-gray-300 bg-white/70 p-8 text-center text-gray-500">
            No vehicles to show yet. Add one using the button above.
          </div>
        )}
      </div>
    </section>
  );
}
