'use client';

import { useEffect, useState } from 'react';

import Link from 'next/link';

import VehicleCard from '@/components/VehicleCard';
import apiClient from '@/lib/api';
import { Vehicle } from '@/types';

export default function UsedVehiclesPage() {
  const [vehicles, setVehicles] = useState<Vehicle[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let cancelled = false;

    const loadVehicles = async () => {
      try {
        const response = await apiClient.get<Vehicle[]>('/vehicles/');
        if (!cancelled) {
          setVehicles(response.data);
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
    <div className="container mx-auto px-4 py-10 space-y-8">
      <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <div>
          <p className="text-xs uppercase tracking-[0.3em] text-gray-500">AutoUsed Market</p>
          <h1 className="text-3xl font-bold text-charcoal">Used & Pre-owned Vehicles</h1>
          <p className="text-sm text-gray-500">Inventory insights powered by your fleet data.</p>
        </div>
        <Link href="/services" className="btn-secondary text-sm">
          Request Inspection
        </Link>
      </div>

      {loading ? (
        <div className="text-center py-20 text-gray-500">Loading used listings…</div>
      ) : vehicles.length ? (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {vehicles.map(vehicle => (
            <VehicleCard
              key={vehicle.id}
              vehicle={vehicle}
              meta={[
                `${vehicle.year ?? 'Year N/A'}`,
                vehicle.mileage ? `${vehicle.mileage.toLocaleString()} km` : 'Mileage N/A'
              ]}
            />
          ))}
        </div>
      ) : (
        <div className="rounded-2xl border border-dashed border-gray-300 bg-white/70 p-8 text-center text-gray-500">
          No used vehicles are tracked yet. Add a vehicle to start logging history.
        </div>
      )}
    </div>
  );
}
