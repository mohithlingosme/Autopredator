'use client';

import { useMemo, useState } from 'react';

export default function InsuranceEstimator() {
  const [vehicleValue, setVehicleValue] = useState(1000000);
  const [coverage, setCoverage] = useState('comprehensive');
  const [city, setCity] = useState('delhi');

  const premium = useMemo(() => {
    const base = vehicleValue * 0.018;
    const coverageMultiplier = coverage === 'comprehensive' ? 1.2 : coverage === 'zero-dep' ? 1.35 : 1;
    const cityMultiplier = city === 'mumbai' ? 1.1 : city === 'bengaluru' ? 1.05 : 1;
    return Math.round(base * coverageMultiplier * cityMultiplier);
  }, [vehicleValue, coverage, city]);

  return (
    <div className="card p-5">
      <h3 className="text-lg font-semibold mb-4">Estimate Insurance Premium</h3>
      <div className="space-y-4">
        <div>
          <label className="text-sm text-gray-600">Vehicle Value (Rs)</label>
          <input
            type="number"
            className="w-full border rounded-md px-3 py-2 mt-1"
            value={vehicleValue}
            onChange={event => setVehicleValue(Number(event.target.value))}
          />
        </div>
        <div>
          <label className="text-sm text-gray-600">Coverage</label>
          <select className="w-full border rounded-md px-3 py-2 mt-1" value={coverage} onChange={event => setCoverage(event.target.value)}>
            <option value="third-party">Third Party</option>
            <option value="comprehensive">Comprehensive</option>
            <option value="zero-dep">Zero Depreciation</option>
          </select>
        </div>
        <div>
          <label className="text-sm text-gray-600">City</label>
          <select className="w-full border rounded-md px-3 py-2 mt-1" value={city} onChange={event => setCity(event.target.value)}>
            <option value="delhi">Delhi</option>
            <option value="mumbai">Mumbai</option>
            <option value="bengaluru">Bengaluru</option>
            <option value="pune">Pune</option>
          </select>
        </div>
        <div className="bg-blue/10 border border-blue/25 rounded-lg p-4">
          <p className="text-sm text-gray-600">Estimated Annual Premium</p>
          <p className="text-2xl font-bold text-blue mt-1">Rs {premium.toLocaleString('en-IN')}</p>
          <p className="text-xs text-gray-500 mt-1">*Includes GST and service charges</p>
        </div>
      </div>
    </div>
  );
}
