'use client';

import { useEffect, useMemo, useState } from 'react';
import VehicleCard from '@/components/VehicleCard';
import { API_BASE_URL } from '@/lib/utils';
import { Vehicle } from '@/types';

export default function ComparePage() {
  const [vehicles, setVehicles] = useState<Vehicle[]>([]);
  const [selectedIds, setSelectedIds] = useState<Array<number | undefined>>(Array(4).fill(undefined));

  useEffect(() => {
    fetch(`${API_BASE_URL}/api/vehicles?limit=20`)
      .then(response => response.json())
      .then(data => setVehicles(data));
  }, []);

  const slotVehicles = selectedIds.map(id => vehicles.find(vehicle => vehicle.id === id));
  const selectedVehicles = slotVehicles.filter(Boolean) as Vehicle[];

  const comparisonRows = useMemo(() => {
    return [
      {
        label: 'Price',
        getValue: (vehicle: Vehicle) => vehicle.price_min || 0,
        format: (vehicle: Vehicle) => `${vehicle.currency === 'INR' ? 'Rs ' : ''}${Math.round((vehicle.price_min || 0) / 100000)}L`,
        lowerIsBetter: true
      },
      {
        label: 'Fuel Type',
        getValue: (vehicle: Vehicle) => vehicle.fuel_type || '',
        format: (vehicle: Vehicle) => vehicle.fuel_type || '—'
      },
      {
        label: 'Transmission',
        getValue: (vehicle: Vehicle) => vehicle.transmission || '',
        format: (vehicle: Vehicle) => vehicle.transmission || '—'
      },
      {
        label: 'Seating Capacity',
        getValue: (vehicle: Vehicle) => vehicle.seating_capacity || 0,
        format: (vehicle: Vehicle) => `${vehicle.seating_capacity || '—'}`,
        lowerIsBetter: false
      },
      {
        label: 'Safety Rating',
        getValue: (vehicle: Vehicle) => vehicle.safety_rating || 0,
        format: (vehicle: Vehicle) => `${vehicle.safety_rating || '—'} ★`,
        lowerIsBetter: false
      }
    ];
  }, []);

  const getCellClass = (row: (typeof comparisonRows)[number], value: number) => {
    const values = selectedVehicles.map(vehicle => row.getValue(vehicle)).filter(val => typeof val === 'number') as number[];
    if (!values.length || typeof value !== 'number') return '';
    const best = row.lowerIsBetter ? Math.min(...values) : Math.max(...values);
    const worst = row.lowerIsBetter ? Math.max(...values) : Math.min(...values);
    if (value === best) return 'bg-green-50 text-green-800 font-semibold';
    if (value === worst) return 'bg-red-50 text-red-800';
    return '';
  };

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
          <p className="text-xs uppercase tracking-[0.3em] text-gray-500">Page 6</p>
          <h1 className="text-3xl font-bold text-charcoal">Compare Vehicles</h1>
          <p className="text-sm text-gray-500">Select up to 4 vehicles to compare side-by-side.</p>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        {slotVehicles.map((vehicle, slotIndex) => {
          return (
            <div key={slotIndex} className="card p-4 flex flex-col gap-4">
              <select
                className="border rounded-md px-3 py-2"
                value={vehicle?.id || ''}
                onChange={event => {
                  const value = event.target.value;
                  handleSelect(slotIndex, value ? Number(value) : undefined);
                }}
              >
                <option value="">Add Vehicle +</option>
                {vehicles.map(option => (
                  <option key={option.id} value={option.id}>
                    {option.name}
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
          );
        })}
      </div>

      {selectedVehicles.length > 1 && (
        <>
          <div className="card overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b">
                  <th className="text-left p-4 font-semibold">Specification</th>
                  {selectedVehicles.map(vehicle => (
                    <th key={vehicle.id} className="p-4 font-semibold text-center">
                      {vehicle.name}
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {comparisonRows.map(row => (
                  <tr key={row.label} className="border-b">
                    <td className="p-4 font-medium">{row.label}</td>
                    {selectedVehicles.map(vehicle => {
                      const raw = row.getValue(vehicle);
                      const value = typeof raw === 'number' ? raw : NaN;
                      return (
                        <td key={vehicle.id} className={`p-4 text-center ${getCellClass(row, value)}`}>
                          {row.format(vehicle)}
                        </td>
                      );
                    })}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          <div className="card bg-neon-green/20 border border-neon-green/30 p-6 space-y-4">
            <h2 className="text-xl font-semibold text-charcoal">AI Verdict</h2>
            <p className="text-gray-700">
              Best for City Use: <span className="font-semibold">{selectedVehicles[selectedVehicles.length - 1].name}</span>
            </p>
            <p className="text-gray-700">
              Best Long-Term Value: <span className="font-semibold">{selectedVehicles[0].name}</span>
            </p>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-sm">
              <div className="bg-white rounded-lg p-4 shadow-sm">
                <p className="font-semibold">Performance Leader</p>
                <p className="text-gray-600">Based on horsepower & torque mix.</p>
              </div>
              <div className="bg-white rounded-lg p-4 shadow-sm">
                <p className="font-semibold">Efficiency Winner</p>
                <p className="text-gray-600">Lowest cost per km.</p>
              </div>
              <div className="bg-white rounded-lg p-4 shadow-sm">
                <p className="font-semibold">Safety Pick</p>
                <p className="text-gray-600">Top crash ratings & ADAS.</p>
              </div>
            </div>
          </div>
        </>
      )}
    </div>
  );
}
