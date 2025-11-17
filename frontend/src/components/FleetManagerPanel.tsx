'use client';

import { useMemo } from 'react';

interface FleetVehicle {
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

interface FleetManagerPanelProps {
  fleetVehicles: FleetVehicle[];
  analytics: FleetAnalyticsPoint[];
}

export default function FleetManagerPanel({ fleetVehicles, analytics }: FleetManagerPanelProps) {
  const summary = useMemo(() => {
    const totalFuel = fleetVehicles.reduce((sum, vehicle) => sum + Number(vehicle.costPerKm ?? 0), 0);
    return {
      vehicleCount: fleetVehicles.length,
      avgUsage: fleetVehicles.length ? totalFuel / fleetVehicles.length : 0
    };
  }, [fleetVehicles]);

  const handleExportCsv = () => {
    const headers = ['Name', 'Driver', 'Status', 'Fuel usage', 'Location'];
    const rows = fleetVehicles.map(vehicle => [
      vehicle.name,
      vehicle.driver,
      vehicle.status,
      vehicle.fuelUsage,
      vehicle.location || 'N/A'
    ]);
    const csvContent = [headers, ...rows].map(row => row.join(',')).join('\n');
    const blob = new Blob([csvContent], { type: 'text/csv' });
    const url = URL.createObjectURL(blob);
    const anchor = document.createElement('a');
    anchor.href = url;
    anchor.download = `fleet-report-${Date.now()}.csv`;
    anchor.click();
    URL.revokeObjectURL(url);
  };

  return (
    <div className="space-y-8">
      <header className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
        <div>
          <p className="text-xs uppercase tracking-[0.4em] text-gray-400">Fleet manager</p>
          <h1 className="text-3xl font-semibold text-charcoal">Business control center</h1>
        </div>
        <button
          type="button"
          onClick={handleExportCsv}
          className="btn-primary rounded-full px-5 py-3 text-sm font-semibold"
        >
          Export CSV
        </button>
      </header>

      <section className="grid gap-4 md:grid-cols-3">
        <div className="rounded-2xl border border-gray-200 bg-white p-5">
          <p className="text-xs uppercase tracking-[0.3em] text-gray-400">Active vehicles</p>
          <p className="text-3xl font-semibold text-charcoal mt-2">{summary.vehicleCount}</p>
        </div>
        <div className="rounded-2xl border border-gray-200 bg-white p-5">
          <p className="text-xs uppercase tracking-[0.3em] text-gray-400">Avg cost per km</p>
          <p className="text-3xl font-semibold text-charcoal mt-2">
            Rs {summary.avgUsage.toFixed(2)}
          </p>
        </div>
        <div className="rounded-2xl border border-gray-200 bg-white p-5">
          <p className="text-xs uppercase tracking-[0.3em] text-gray-400">Last 24h usage</p>
          <p className="text-3xl font-semibold text-charcoal mt-2">
            {fleetVehicles.reduce((sum, vehicle) => sum + (vehicle.distanceToday ?? 0), 0)} km
          </p>
        </div>
      </section>

      <section className="rounded-3xl border border-gray-200 bg-white p-6 shadow-sm">
        <div className="overflow-x-auto">
          <table className="min-w-full text-left text-sm">
            <thead className="text-gray-500 uppercase text-xs tracking-[0.3em] border-b">
              <tr>
                <th className="py-3 pr-3">Vehicle</th>
                <th className="py-3 pr-3">Driver</th>
                <th className="py-3 pr-3">Status</th>
                <th className="py-3 pr-3">Fuel usage</th>
                <th className="py-3 pr-3">Location</th>
                <th className="py-3 pr-3">Today</th>
              </tr>
            </thead>
            <tbody>
              {fleetVehicles.map(vehicle => (
                <tr key={vehicle.id} className="border-b last:border-b-0">
                  <td className="py-3 pr-3 font-semibold text-charcoal">{vehicle.name}</td>
                  <td className="py-3 pr-3 text-gray-600">{vehicle.driver}</td>
                  <td className="py-3 pr-3 capitalize">
                    <span
                      className={`inline-flex items-center rounded-full px-3 py-1 text-xs font-semibold ${
                        vehicle.status === 'due'
                          ? 'bg-yellow-100 text-yellow-700'
                          : vehicle.status === 'active'
                          ? 'bg-green-100 text-green-700'
                          : 'bg-gray-100 text-gray-600'
                      }`}
                    >
                      {vehicle.status}
                    </span>
                  </td>
                  <td className="py-3 pr-3 text-gray-600">{vehicle.fuelUsage}</td>
                  <td className="py-3 pr-3 text-gray-600">{vehicle.location || 'GPS off'}</td>
                  <td className="py-3 pr-3 text-gray-600">{vehicle.distanceToday ?? 0} km</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>

      <section className="rounded-3xl border border-gray-200 bg-white p-6 space-y-4">
        <h2 className="text-xl font-semibold text-charcoal">Insights</h2>
        <div className="grid gap-4 md:grid-cols-3">
          {analytics.map(point => (
            <div key={point.label} className="rounded-2xl border border-gray-100 p-4 bg-gray-50">
              <p className="text-xs uppercase tracking-[0.3em] text-gray-400">{point.label}</p>
              <p className="text-2xl font-semibold text-charcoal mt-2">{point.value}</p>
            </div>
          ))}
        </div>
      </section>
    </div>
  );
}
