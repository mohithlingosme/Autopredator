'use client';

import { useEffect, useState } from 'react';
import { Line, LineChart, Bar, BarChart, ResponsiveContainer, XAxis, YAxis, Tooltip, RadialBarChart, RadialBar } from 'recharts';
import { API_BASE_URL } from '@/lib/utils';
import { Vehicle } from '@/types';

interface InsightResponse {
  ownershipCost: { year: string; cost: number }[];
  depreciation: { segment: string; vehicle: number; segmentAvg: number }[];
  maintenanceConfidence: number;
}

export default function InsightsPage() {
  const [dashboard, setDashboard] = useState<InsightResponse>({
    ownershipCost: [],
    depreciation: [],
    maintenanceConfidence: 0.8
  });
  const [recommendations, setRecommendations] = useState<Vehicle[]>([]);

  useEffect(() => {
    fetch(`${API_BASE_URL}/api/ai/dashboard`)
      .then(response => response.json())
      .then(data => setDashboard(data));
    fetch(`${API_BASE_URL}/api/ai/recommendations`)
      .then(response => response.json())
      .then(data => setRecommendations(data));
  }, []);

  return (
    <div className="container mx-auto px-4 py-10 space-y-10">
      <div>
        <p className="text-xs uppercase tracking-[0.3em] text-gray-500">Page 10</p>
        <h1 className="text-4xl font-bold text-charcoal">Autopredator Insights</h1>
        <p className="text-gray-600">Predictive analytics to plan ownership cost, depreciation and maintenance.</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="card p-4">
          <p className="text-sm text-gray-500">Ownership Cost Over 5 Years</p>
          <ResponsiveContainer width="100%" height={220}>
            <LineChart data={dashboard.ownershipCost}>
              <XAxis dataKey="year" />
              <YAxis />
              <Tooltip />
              <Line type="monotone" dataKey="cost" stroke="#007bff" strokeWidth={2} />
            </LineChart>
          </ResponsiveContainer>
        </div>

        <div className="card p-4">
          <p className="text-sm text-gray-500">Depreciation vs Segment Average</p>
          <ResponsiveContainer width="100%" height={220}>
            <BarChart data={dashboard.depreciation}>
              <XAxis dataKey="segment" />
              <YAxis />
              <Tooltip />
              <Bar dataKey="vehicle" fill="#39ff14" />
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
              data={[{ name: 'Confidence', value: dashboard.maintenanceConfidence * 100 }]}
              startAngle={90}
              endAngle={-270}
            >
              <RadialBar minAngle={15} dataKey="value" cornerRadius={10} fill="#39ff14" />
              <Tooltip />
            </RadialBarChart>
          </ResponsiveContainer>
          <p className="text-3xl font-semibold text-charcoal mt-2">{Math.round(dashboard.maintenanceConfidence * 100)}%</p>
        </div>
      </div>

      <div>
        <h2 className="text-2xl font-bold mb-4">Suggested Vehicles to Reduce Long-Term Costs</h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {recommendations.map(vehicle => (
            <div key={vehicle.id} className="card p-5">
              <p className="text-sm uppercase tracking-[0.3em] text-gray-500">{vehicle.segment}</p>
              <h3 className="text-xl font-semibold">{vehicle.name}</h3>
              <p className="text-gray-600 text-sm">{vehicle.fuel_type}</p>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
