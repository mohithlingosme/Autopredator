'use client';

import { useState } from 'react';
import {
  Line,
  LineChart,
  Pie,
  PieChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis
} from 'recharts';
import SpecTable from '@/components/SpecTable';
import FinanceCalculator from '@/components/FinanceCalculator';
import { ServiceHistoryRecord, Vehicle, VehicleListing } from '@/types';

interface VehicleDetailTabsProps {
  vehicle: Vehicle;
  listings: VehicleListing[];
  serviceHistory: ServiceHistoryRecord[];
}

const ownershipCostData = [
  { name: 'Fuel', value: 35 },
  { name: 'Insurance', value: 20 },
  { name: 'Maintenance', value: 25 },
  { name: 'Depreciation', value: 20 }
];

const financeTrend = [
  { name: 'Year 1', amount: 2.1 },
  { name: 'Year 2', amount: 2.3 },
  { name: 'Year 3', amount: 2.45 },
  { name: 'Year 4', amount: 2.7 },
  { name: 'Year 5', amount: 2.95 }
];

export default function VehicleDetailTabs({ vehicle, listings, serviceHistory }: VehicleDetailTabsProps) {
  const [activeTab, setActiveTab] = useState('overview');
  const featureList = (vehicle.features?.highlights as string[]) || ['ADAS', 'Panoramic Sunroof', '360 Camera'];

  const renderTabContent = () => {
    switch (activeTab) {
      case 'specs':
        return (
          <SpecTable
            rows={[
              { label: 'Engine', value: String(vehicle.specs?.engine ?? '2.0L Turbo') },
              { label: 'Power', value: String(vehicle.specs?.power ?? '200 bhp') },
              { label: 'Torque', value: String(vehicle.specs?.torque ?? '320 Nm') },
              { label: 'Fuel Type', value: vehicle.fuel_type || 'Petrol' },
              { label: 'Transmission', value: vehicle.transmission || 'Automatic' },
              { label: 'Mileage', value: String(vehicle.specs?.mileage ?? '18 kmpl') },
              { label: 'Dimensions', value: String(vehicle.dimensions?.length ?? '4600mm') },
              { label: 'Seating', value: `${vehicle.seating_capacity || 5}` }
            ]}
          />
        );
      case 'features':
        return (
          <div className="grid grid-cols-2 md:grid-cols-3 gap-3">
            {featureList.map(feature => (
              <div key={feature} className="border rounded-lg px-3 py-2 text-sm">
                {feature}
              </div>
            ))}
          </div>
        );
      case 'finance':
        return (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <FinanceCalculator price={vehicle.price_min || 1000000} />
            <div className="card p-4">
              <p className="text-sm text-gray-500 mb-2">EMI Breakdown</p>
              <ResponsiveContainer width="100%" height={220}>
                <LineChart data={financeTrend}>
                  <XAxis dataKey="name" />
                  <YAxis />
                  <Tooltip />
                  <Line type="monotone" dataKey="amount" stroke="#007bff" strokeWidth={2} />
                </LineChart>
              </ResponsiveContainer>
            </div>
          </div>
        );
      case 'reviews':
        return (
          <div className="space-y-4">
            {[1, 2].map(index => (
              <div key={index} className="border rounded-lg p-4">
                <p className="font-semibold">Owner #{index}</p>
                <p className="text-sm text-gray-500 mb-2">Rating: 4/5</p>
                <p className="text-gray-600">Smooth ride quality and excellent cabin insulation. Maintenance is affordable.</p>
              </div>
            ))}
          </div>
        );
      case 'legal':
        return (
          <div className="space-y-4 text-sm text-gray-600">
            <p>RTO Tax: Rs {Math.round((vehicle.price_min || 1000000) * 0.12).toLocaleString('en-IN')}</p>
            <p>Emission Class: BS6 Phase-II compliant</p>
            <p>Recall Info: No recalls reported in the last 24 months.</p>
          </div>
        );
      case 'service':
        return serviceHistory.length ? (
          <div className="space-y-4">
            {serviceHistory.map(history => (
              <div key={history.listingId} className="border rounded-lg p-4">
                <p className="font-semibold mb-2">Listing #{history.listingId}</p>
                <ul className="space-y-2 text-sm text-gray-600">
                  {history.records.map(record => (
                    <li key={record.id} className="flex justify-between">
                      <span>
                        {record.service_date} - {record.description}
                      </span>
                      <span>Rs {record.cost.toLocaleString('en-IN')}</span>
                    </li>
                  ))}
                </ul>
              </div>
            ))}
          </div>
        ) : (
          <p className="text-sm text-gray-500">No service history available.</p>
        );
      case 'documents':
        const documents = listings.flatMap(listing => listing.documents);
        return documents.length ? (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {documents.map(document => (
              <div key={`${document.title}-${document.status}`} className="border rounded-lg p-4">
                <p className="font-semibold">{document.title}</p>
                <p className="text-sm text-gray-500 capitalize">Status: {document.status}</p>
              </div>
            ))}
          </div>
        ) : (
          <p className="text-sm text-gray-500">No documents attached.</p>
        );
      default:
        return (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div className="card p-4">
              <p className="text-sm text-gray-500">Ownership Cost</p>
              <ResponsiveContainer width="100%" height={220}>
                <PieChart>
                  <Pie data={ownershipCostData} dataKey="value" nameKey="name" fill="#007bff" label />
                  <Tooltip />
                </PieChart>
              </ResponsiveContainer>
            </div>
            <div className="space-y-3 text-sm text-gray-600">
              <p>
                <span className="font-semibold text-gray-800">Safety Rating:</span> {vehicle.safety_rating || 4.5} / 5
              </p>
              <p>
                <span className="font-semibold text-gray-800">Best For:</span> Long drives, premium comfort seekers and
                city enthusiasts.
              </p>
              <p>
                <span className="font-semibold text-gray-800">Ownership Cost Graph:</span> Visualizes 5-year predicted
                expenditure.
              </p>
            </div>
          </div>
        );
    }
  };

  return (
    <div>
      <div className="flex flex-wrap border-b mb-6">
        {['overview', 'specs', 'features', 'finance', 'reviews', 'legal', 'service', 'documents'].map(tabId => (
          <button
            key={tabId}
            type="button"
            className={`px-4 py-3 text-sm font-semibold border-b-2 ${
              activeTab === tabId ? 'border-blue text-blue' : 'border-transparent text-gray-500'
            }`}
            onClick={() => setActiveTab(tabId)}
          >
            {tabId.charAt(0).toUpperCase() + tabId.slice(1)}
          </button>
        ))}
      </div>
      {renderTabContent()}
    </div>
  );
}
