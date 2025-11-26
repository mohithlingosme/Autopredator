'use client';

import { Vehicle } from '@/types';

export interface PredictionResult {
  next_service_date: string | null;
  confidence: number;
  message: string;
  vehicle_id?: number;
  source: string;
}

interface PredictionCardProps {
  prediction: PredictionResult | null;
  vehicle: Vehicle | null;
}

export default function PredictionCard({ prediction, vehicle }: PredictionCardProps) {
  if (!prediction) {
    return (
      <div className="rounded-3xl border border-dashed border-gray-300 bg-white/80 p-6 text-center text-gray-600">
        Predictive maintenance insights will appear once you add vehicles to your fleet.
      </div>
    );
  }

  const nextService = prediction.next_service_date
    ? new Date(prediction.next_service_date).toLocaleDateString()
    : 'TBD';

  return (
    <div className="rounded-3xl border border-gray-200 bg-white p-6 shadow-sm space-y-3">
      <div className="flex items-center justify-between">
        <div>
          <p className="text-xs uppercase tracking-[0.4em] text-gray-400">AI prediction</p>
          <h2 className="text-2xl font-semibold text-charcoal">
            {vehicle ? `${vehicle.make} ${vehicle.model}` : 'Fleet prediction'}
          </h2>
        </div>
        <span className="rounded-full bg-blue/10 px-3 py-1 text-xs font-semibold text-blue">
          {prediction.source === 'ml' ? 'ML' : 'Heuristics'}
        </span>
      </div>
      <p className="text-gray-600">{prediction.message}</p>
      <div className="flex items-center justify-between text-sm text-gray-500">
        <span>Next service</span>
        <strong className="text-charcoal">{nextService}</strong>
      </div>
      <div className="flex items-center justify-between text-sm text-gray-500">
        <span>Confidence</span>
        <strong className="text-charcoal">{Math.round(prediction.confidence * 100)}%</strong>
      </div>
    </div>
  );
}
