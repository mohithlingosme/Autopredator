'use client';

import { useEffect, useMemo, useState } from 'react';

import VehicleCard from '@/components/VehicleCard';
import apiClient from '@/lib/api';
import { Vehicle } from '@/types';

export default function ComparePage() {
  const [vehicles, setVehicles] = useState<Vehicle[]>([]);
  const [selectedIds, setSelectedIds] = useState<Array<number | undefined>>(Array(4).fill(undefined));
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

  const slotVehicles = selectedIds.map(id => vehicles.find(vehicle => vehicle.id === id));

  const rows = useMemo(
    () => [
      {
        label: 'Mileage',
        getValue: (vehicle: Vehicle) => `${vehicle.mileage?.toLocaleString() ?? '—'} km`
      },
      {
        label: 'Fuel type',
        getValue: (vehicle: Vehicle) => vehicle.fuel_type ?? '—'
      },
      {
        label: 'Next service',
        getValue: (vehicle: Vehicle) => vehicle.next_service_date ?? 'TBD'
      },
      {
        label: 'Registration year',
        getValue: (vehicle: Vehicle) => vehicle.year ?? '—'
      }
    ],
    []
  );

  const handleSelect = (slotIndex: number, id?: number) => {
    setSelectedIds(prev => {
      const next = [...prev];
      next[slotIndex] = id;
      return next;
    });
  };

  return (
    <div className="container mx-auto px-4 py-10 space-y-10">
      <div className="flex items-center justify-between">
        <div>
          <p className="text-xs uppercase tracking-[0.3em] text-gray-500">Compare</p>
          <h1 className="text-3xl font-bold text-charcoal">Compare Vehicles</h1>
          <p className="text-sm text-gray-500">Select up to 4 vehicles from your fleet to benchmark.</p>
        </div>
      </div>

      {loading ? (
        <div className="card p-8 text-center text-gray-500">Loading your fleet...</div>
      ) : (
        <>
          <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
            {slotVehicles.map((vehicle, slotIndex) => (
              <div key={slotIndex} className="card p-4 flex flex-col gap-4">
                <select
                  className="border rounded-md px-3 py-2"
                  value={vehicle?.id ?? ''}
                  onChange={event => {
                    const value = event.target.value;
                    handleSelect(slotIndex, value ? Number(value) : undefined);
                  }}
                >
                  <option value="">Add Vehicle +</option>
                  {vehicles.map(option => (
                    <option key={option.id} value={option.id}>
                      {option.make} {option.model}
                    </option>
                  ))}
                </select>
                {vehicle ? (
                  <VehicleCard vehicle={vehicle} showActions={false} />
                ) : (
                  <div className="h-40 border border-dashed rounded-lg flex items-center justify-center text-gray-400 text-sm">
                    Slot {slotIndex + 1}
                  </div>
                )}
              </div>
            ))}
          </div>
          {slotVehicles.filter(Boolean).length > 1 && (
            <div className="card overflow-x-auto">
              <table className="w-full">
                <thead>
                  <tr className="border-b">
                    <th className="text-left p-4 font-semibold">Specification</th>
                    {slotVehicles
                      .filter(Boolean)
                      .map(vehicle => (
                        <th key={vehicle?.id} className="p-4 font-semibold text-center">
                          {vehicle?.make} {vehicle?.model}
                        </th>
                      ))}
                  </tr>
                </thead>
                <tbody>
                  {rows.map(row => (
                    <tr key={row.label} className="border-b">
                      <td className="p-4 font-medium">{row.label}</td>
                      {slotVehicles.filter(Boolean).map(vehicle => (
                        <td key={`${row.label}-${vehicle?.id}`} className="p-4 text-center text-sm">
                          {vehicle ? row.getValue(vehicle) : '—'}
                        </td>
                      ))}
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </>
      )}
    </div>
  );
}
