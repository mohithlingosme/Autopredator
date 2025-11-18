'use client';

import { useEffect, useMemo, useState } from 'react';

import DashboardContent from '@/components/DashboardContent';
import FleetManagerPanel from '@/components/FleetManagerPanel';
import PredictionCard, { PredictionResult } from '@/components/PredictionCard';
import apiClient from '@/lib/api';
import { FleetRecord, Product, Vehicle } from '@/types';

interface MaintenanceReminderApi {
  vehicle: string;
  due_date: string;
  type: string;
  status: 'due' | 'active' | 'critical';
}

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

export default function DashboardPage() {
  const [vehicles, setVehicles] = useState<Vehicle[]>([]);
  const [reminders, setReminders] = useState<MaintenanceReminder[]>([]);
  const [costAnalytics, setCostAnalytics] = useState<CostPoint[]>([]);
  const [products, setProducts] = useState<Product[]>([]);
  const [fleets, setFleets] = useState<FleetRecord[]>([]);
  const [prediction, setPrediction] = useState<PredictionResult | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;

    const fetchData = async () => {
      try {
        const [vehiclesRes, remindersRes, analyticsRes, fleetsRes, productsRes] = await Promise.all([
          apiClient.get<Vehicle[]>('/vehicles/'),
          apiClient.get<MaintenanceReminderApi[]>('/reminders/'),
          apiClient.get<{ cost_trend: CostPoint[] }>('/analytics/cost/'),
          apiClient.get<FleetRecord[]>('/fleets/'),
          apiClient.get<Product[]>('/products/')
        ]);

        if (cancelled) {
          return;
        }

        setVehicles(vehiclesRes.data);
        setReminders(
          remindersRes.data.map((reminder, index) => ({
            id: index,
            vehicleName: reminder.vehicle,
            dueDate: reminder.due_date,
            type: reminder.type,
            status: reminder.status
          }))
        );
        setCostAnalytics(analyticsRes.data.cost_trend || []);
        setFleets(fleetsRes.data);
        setProducts(productsRes.data);

        const [vehicle] = vehiclesRes.data;
        if (vehicle) {
          const lastServiceDays = vehicle.last_service_date
            ? Math.max(
                1,
                Math.floor(
                  (Date.now() - new Date(vehicle.last_service_date).getTime()) / (1000 * 60 * 60 * 24)
                )
              )
            : 30;

          const predictionRes = await apiClient.post<PredictionResult>('/predict/', {
            vehicle_id: vehicle.id,
            mileage: vehicle.mileage ?? 0,
            vehicle_type: vehicle.vehicle_type ?? 'fleet',
            last_service_days: lastServiceDays
          });

          if (!cancelled) {
            setPrediction(predictionRes.data);
          }
        }
      } catch {
        if (!cancelled) {
          setError('Unable to load dashboard data right now.');
        }
      } finally {
        if (!cancelled) {
          setLoading(false);
        }
      }
    };

    fetchData();
    return () => {
      cancelled = true;
    };
  }, []);

  const fleetVehicles = useMemo(() => {
    return vehicles.map(vehicle => ({
      id: vehicle.id,
      name: `${vehicle.make} ${vehicle.model}`,
      status: vehicle.status ?? 'new',
      mileage: vehicle.mileage ?? 0,
      vehicle_type: vehicle.vehicle_type,
      next_service_date: vehicle.next_service_date
    }));
  }, [vehicles]);

  const fleetAnalytics = useMemo(
    () => [
      { label: 'Vehicles', value: vehicles.length },
      { label: 'Products', value: products.length },
      { label: 'Fleets', value: fleets.length }
    ],
    [vehicles.length, products.length, fleets.length]
  );

  if (loading) {
    return (
      <section className="container mx-auto px-4 py-10">
        <div className="rounded-3xl border border-dashed border-gray-300 bg-white/80 p-12 text-center text-gray-500">
          Loading dashboard…
        </div>
      </section>
    );
  }

  if (error) {
    return (
      <section className="container mx-auto px-4 py-10">
        <div className="rounded-3xl border border-red-200 bg-white/80 p-12 text-center text-red-600">{error}</div>
      </section>
    );
  }

  return (
    <section className="container mx-auto px-4 py-10 space-y-10">
      <DashboardContent vehicles={vehicles} maintenanceReminders={reminders} costAnalytics={costAnalytics} />

      <FleetManagerPanel fleetVehicles={fleetVehicles} analytics={fleetAnalytics} />

      <div className="grid gap-6 lg:grid-cols-[2fr,1fr]">
        <PredictionCard prediction={prediction} vehicle={vehicles[0] ?? null} />
        <div className="rounded-3xl border border-gray-200 bg-white p-6 space-y-4 shadow-sm">
          <h2 className="text-xl font-semibold text-charcoal">Marketplace Picks</h2>
          <div className="space-y-3">
            {products.slice(0, 3).map(product => (
              <article key={product.id} className="border border-gray-100 rounded-2xl p-4">
                <h3 className="text-lg font-semibold text-charcoal">{product.name}</h3>
                <p className="text-sm text-gray-600">{product.category}</p>
                <p className="text-sm text-gray-500 line-clamp-2">{product.description}</p>
                <p className="text-sm font-semibold text-blue">Rs {product.price.toLocaleString()}</p>
              </article>
            ))}
            {!products.length && <p className="text-sm text-gray-500">No marketplace items yet.</p>}
          </div>
        </div>
      </div>
    </section>
  );
}
