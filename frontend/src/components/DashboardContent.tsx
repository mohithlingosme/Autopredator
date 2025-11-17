'use client';

import Link from 'next/link';
import { useMemo, useState } from 'react';
import {
  Area,
  AreaChart,
  CartesianGrid,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis
} from 'recharts';

import VehicleCard from './VehicleCard';
import { Vehicle } from '@/types';

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

interface DashboardContentProps {
  vehicles: Vehicle[];
  maintenanceReminders: MaintenanceReminder[];
  costAnalytics: CostPoint[];
}

const statusFilters = [
  { value: 'all', label: 'All status' },
  { value: 'active', label: 'Active' },
  { value: 'due', label: 'Due soon' }
];

export default function DashboardContent({ vehicles, maintenanceReminders, costAnalytics }: DashboardContentProps) {
  const [statusFilter, setStatusFilter] = useState(statusFilters[0].value);
  const [typeFilter, setTypeFilter] = useState('all');

  const availableTypes = useMemo(() => {
    const types = Array.from(new Set(vehicles.map(vehicle => vehicle.body_type || vehicle.type || '').filter(Boolean)));
    return ['all', ...types];
  }, [vehicles]);

  const filteredVehicles = useMemo(() => {
    return vehicles.filter(vehicle => {
      const matchesStatus =
        statusFilter === 'all' ||
        (statusFilter === 'active' && vehicle.status !== 'due') ||
        (statusFilter === 'due' && vehicle.status === 'due');
      const matchesType = typeFilter === 'all' || (vehicle.body_type || vehicle.type) === typeFilter;
      return matchesStatus && matchesType;
    });
  }, [vehicles, statusFilter, typeFilter]);

  const upcoming = maintenanceReminders.slice(0, 3);

  return (
    <div className="space-y-10">
      <header className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
        <div>
          <p className="text-xs uppercase tracking-[0.5em] text-gray-500">Fleet overview</p>
          <h1 className="text-3xl font-semibold text-charcoal">Dashboard</h1>
        </div>
        <div className="flex flex-wrap gap-3">
          <Link href="/vehicle/add" className="btn-primary px-5 py-3">
            Add Vehicle
          </Link>
          <Link href="/fleet" className="btn-secondary px-5 py-3">
            View fleet manager tools
          </Link>
        </div>
      </header>

      <section className="grid gap-4 md:grid-cols-[2fr,1fr]">
        <div className="space-y-4">
          <div className="flex flex-wrap gap-3">
            {statusFilters.map(filter => (
              <button
                key={filter.value}
                type="button"
                onClick={() => setStatusFilter(filter.value)}
                className={`px-4 py-2 rounded-full border transition ${
                  statusFilter === filter.value
                    ? 'border-neon-green bg-neon-green/30 text-charcoal'
                    : 'border-gray-200 bg-white text-gray-600'
                }`}
              >
                {filter.label}
              </button>
            ))}
            <select
              value={typeFilter}
              onChange={event => setTypeFilter(event.target.value)}
              className="ml-auto rounded-full border border-gray-200 px-4 py-2"
            >
              {availableTypes.map(type => (
                <option key={type} value={type}>
                  {type === 'all' ? 'All vehicle types' : type}
                </option>
              ))}
            </select>
          </div>
          <div className="grid gap-6 md:grid-cols-2">
            {filteredVehicles.length ? (
              filteredVehicles.slice(0, 4).map(vehicle => (
                <VehicleCard key={vehicle.id} vehicle={vehicle} verified={vehicle.is_featured} />
              ))
            ) : (
              <div className="col-span-full rounded-2xl border border-dashed border-gray-300 py-12 text-center text-gray-500">
                No vehicles match the selected filters.
              </div>
            )}
          </div>
        </div>

        <div className="space-y-6">
          <div className="rounded-2xl border border-gray-200 p-5 bg-white shadow-sm">
            <p className="text-sm uppercase tracking-[0.4em] text-gray-400">Maintenance</p>
            <h2 className="text-xl font-semibold text-charcoal mt-2">Upcoming reminders</h2>
            <div className="space-y-3 mt-4">
              {upcoming.length ? (
                upcoming.map(reminder => (
                  <div key={reminder.id} className="rounded-xl border border-gray-100 p-3">
                    <p className="text-sm font-semibold text-charcoal">{reminder.vehicleName}</p>
                    <p className="text-xs uppercase tracking-[0.4em] text-gray-400">{reminder.type}</p>
                    <p className="text-sm text-gray-600">Due: {reminder.dueDate}</p>
                    <span
                      className={`inline-flex items-center rounded-full px-3 py-1 text-xs font-semibold ${
                        reminder.status === 'critical'
                          ? 'bg-red-100 text-red-700'
                          : reminder.status === 'due'
                          ? 'bg-yellow-100 text-yellow-700'
                          : 'bg-green-100 text-green-700'
                      }`}
                    >
                      {reminder.status}
                    </span>
                  </div>
                ))
              ) : (
                <p className="text-sm text-gray-500">No maintenance reminders right now.</p>
              )}
            </div>
          </div>

          <div className="rounded-2xl border border-gray-200 p-5 bg-white shadow-sm">
            <div className="flex items-center justify-between mb-4">
              <div>
                <p className="text-sm uppercase tracking-[0.4em] text-gray-400">Analytics</p>
                <h2 className="text-xl font-semibold text-charcoal">Cost trends</h2>
              </div>
              <span className="text-sm text-gray-500">{costAnalytics.length ? 'Monthly' : '–'}</span>
            </div>
            <div style={{ width: '100%', height: 210 }}>
              {costAnalytics.length ? (
                <ResponsiveContainer width="100%" height="100%">
                  <AreaChart data={costAnalytics}>
                    <defs>
                      <linearGradient id="planned" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="5%" stopColor="#2C2C2C" stopOpacity={0.2} />
                        <stop offset="95%" stopColor="#2C2C2C" stopOpacity={0} />
                      </linearGradient>
                      <linearGradient id="actual" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="5%" stopColor="#39ff14" stopOpacity={0.3} />
                        <stop offset="95%" stopColor="#39ff14" stopOpacity={0} />
                      </linearGradient>
                    </defs>
                    <CartesianGrid strokeDasharray="3 3" stroke="#e5e5e5" />
                    <XAxis dataKey="label" tick={{ fill: '#4B5563' }} />
                    <YAxis tick={{ fill: '#4B5563' }} />
                    <Tooltip
                      contentStyle={{ borderRadius: 16, borderColor: '#e5e5e5' }}
                      formatter={(value: number) => [`Rs ${value.toLocaleString()}`, '₹']}
                    />
                    <Area type="monotone" dataKey="planned" stroke="#2C2C2C" fill="url(#planned)" strokeWidth={2} />
                    <Area type="monotone" dataKey="actual" stroke="#39ff14" fill="url(#actual)" strokeWidth={2} />
                  </AreaChart>
                </ResponsiveContainer>
              ) : (
                <p className="text-center text-sm text-gray-500 mt-8">No cost analytics available yet.</p>
              )}
            </div>
          </div>
        </div>
      </section>
    </div>
  );
}
