'use client';

import { useEffect, useMemo, useState } from 'react';
import {
  Bar,
  BarChart,
  Line,
  LineChart,
  RadialBar,
  RadialBarChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis
} from 'recharts';

import apiClient from '@/lib/api';
import { Vehicle } from '@/types';

interface CostPoint {
  label: string;
  planned: number;
  actual: number;
}

export default function InsightsPage() {
  const [costTrend, setCostTrend] = useState<CostPoint[]>([]);
  const [vehicles, setVehicles] = useState<Vehicle[]>([]);
  const [confidence, setConfidence] = useState(0.8);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let cancelled = false;

    const loadInsights = async () => {
      try {
        const [analyticsRes, vehiclesRes] = await Promise.all([
          apiClient.get('/analytics/cost/'),
          apiClient.get<Vehicle[]>('/vehicles/')
        ]);

        if (cancelled) {
          return;
        }

        if (analyticsRes.data.cost_trend) {
          setCostTrend(analyticsRes.data.cost_trend);
        }

        const summary = analyticsRes.data.summary;
        if (summary) {
          const vehicleCount = Math.max(summary.vehicle_count || 1, 1);
          const dueShare = (summary.maintenance_due || 0) / vehicleCount;
          setConfidence(Math.max(0.4, Math.min(0.95, 1 - dueShare)));
        }

        setVehicles(vehiclesRes.data);
      } finally {
        if (!cancelled) {
          setLoading(false);
        }
      }
    };

    loadInsights();
    return () => {
      cancelled = true;
    };
  }, []);

  const depreciation = useMemo(() => {
    if (!vehicles.length) {
      return [
        { segment: 'Sedan', vehicle: 900, segmentAvg: 1000 },
        { segment: 'SUV', vehicle: 1200, segmentAvg: 1350 },
        { segment: 'Truck', vehicle: 1500, segmentAvg: 1600 }
      ];
    }
    return vehicles.slice(0, 3).map(vehicle => ({
      segment: vehicle.vehicle_type ?? 'Fleet',
      vehicle: Math.round((vehicle.avg_monthly_service_cost || 0) * 12),
      segmentAvg: Math.round((vehicle.avg_monthly_service_cost || 0) * 12 * 1.1)
    }));
  }, [vehicles]);

  const recommendations = useMemo(() => {
    return [...vehicles]
      .sort((a, b) => (a.avg_monthly_service_cost || 9999) - (b.avg_monthly_service_cost || 9999))
      .slice(0, 3);
  }, [vehicles]);

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <p className="text-sm text-gray-500">Gathering insights…</p>
      </div>
    );
  }

  return (
    <div className="container mx-auto px-4 py-10 space-y-10">
      <div>
        <p className="text-xs uppercase tracking-[0.3em] text-gray-500">Insights</p>
        <h1 className="text-4xl font-bold text-charcoal">Autopredator Analytics</h1>
        <p className="text-gray-600">Predictive dashboards for maintenance, ownership cost, and depreciation.</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="card p-4">
          <p className="text-sm text-gray-500">Ownership Cost Curve</p>
          <ResponsiveContainer width="100%" height={220}>
            <LineChart data={costTrend}>
              <XAxis dataKey="label" />
              <YAxis />
              <Tooltip />
              <Line type="monotone" dataKey="actual" stroke="#39ff14" strokeWidth={2} />
            </LineChart>
          </ResponsiveContainer>
        </div>

        <div className="card p-4">
          <p className="text-sm text-gray-500">Depreciation vs Segment</p>
          <ResponsiveContainer width="100%" height={220}>
            <BarChart data={depreciation}>
              <XAxis dataKey="segment" />
              <YAxis />
              <Tooltip />
              <Bar dataKey="vehicle" fill="#2c2c2c" />
              <Bar dataKey="segmentAvg" fill="#007bff" />
            </BarChart>
          </ResponsiveContainer>
        </div>

        <div className="card p-4 flex flex-col items-center justify-center">
          <p className="text-sm text-gray-500 mb-4">Maintenance Confidence</p>
          <ResponsiveContainer width="100%" height={220}>
            <RadialBarChart
              innerRadius="70%"
              outerRadius="100%"
              data={[{ name: 'Confidence', value: confidence * 100 }]}
              startAngle={90}
              endAngle={-270}
            >
              <RadialBar minAngle={15} dataKey="value" cornerRadius={10} fill="#39ff14" />
              <Tooltip />
            </RadialBarChart>
          </ResponsiveContainer>
          <p className="text-3xl font-semibold text-charcoal mt-2">{Math.round(confidence * 100)}%</p>
        </div>
      </div>

      <div>
        <h2 className="text-2xl font-bold mb-4">Suggested Vehicles</h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {recommendations.map(vehicle => (
            <div key={vehicle.id} className="card p-5 space-y-3">
              <div className="text-xs uppercase tracking-[0.3em] text-gray-400">{vehicle.vehicle_type}</div>
              <h3 className="text-xl font-semibold">{`${vehicle.make} ${vehicle.model}`}</h3>
              <p className="text-gray-600 text-sm">
                Service estimate: Rs {(vehicle.avg_monthly_service_cost || 0).toFixed(0)} / month
              </p>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
