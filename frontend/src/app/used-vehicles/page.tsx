'use client';

import { useEffect, useState, useTransition } from 'react';
import Link from 'next/link';
import VehicleCard from '@/components/VehicleCard';
import FilterSidebar, { FilterSection } from '@/components/FilterSidebar';
import { API_BASE_URL } from '@/lib/utils';
import { Vehicle } from '@/types';

interface UsedVehicleResponse {
  listing: {
    id: number;
    km_driven: number;
    year: number;
    city: string;
    verified: boolean;
    owner_type: string;
    condition: string;
    asking_price: number;
  };
  vehicle: Vehicle;
}

const sections: FilterSection[] = [
  {
    id: 'year',
    title: 'Year',
    type: 'select',
    options: [
      { label: '2024+', value: '2024' },
      { label: '2022+', value: '2022' },
      { label: '2020+', value: '2020' }
    ]
  },
  {
    id: 'km_driven',
    title: 'KM Driven',
    type: 'select',
    options: [
      { label: '< 20,000 km', value: '20000' },
      { label: '< 40,000 km', value: '40000' },
      { label: '< 60,000 km', value: '60000' }
    ]
  },
  {
    id: 'city',
    title: 'City',
    type: 'select',
    options: ['Delhi', 'Mumbai', 'Bengaluru', 'Chennai', 'Pune'].map(city => ({
      label: city,
      value: city.toLowerCase()
    }))
  },
  {
    id: 'owner_type',
    title: 'Owner Type',
    type: 'select',
    options: [
      { label: 'First Owner', value: 'first' },
      { label: 'Second Owner', value: 'second' }
    ]
  }
];

const toggleSections: FilterSection[] = [
  {
    id: 'verified',
    title: 'Verified Listings',
    type: 'toggle',
    options: [{ label: 'Verified Only', value: 'true' }]
  },
  {
    id: 'listing_type',
    title: 'Seller Type',
    type: 'toggle',
    options: [
      { label: 'Dealer', value: 'dealer' },
      { label: 'Individual', value: 'individual' }
    ]
  }
];

export default function UsedVehiclesPage() {
  const [filters, setFilters] = useState<Record<string, string[]>>({});
  const [results, setResults] = useState<UsedVehicleResponse[]>([]);
  const [loading, setLoading] = useState(true);
  const [, startTransition] = useTransition();

  useEffect(() => {
    const controller = new AbortController();
    const params = new URLSearchParams();
    Object.entries(filters).forEach(([key, value]) => {
      if (value?.length) {
        params.append(key, value[0]);
      }
    });

    startTransition(() => setLoading(true));
    fetch(`${API_BASE_URL}/api/vehicles/used?${params.toString()}`, { signal: controller.signal })
      .then(response => response.json())
      .then(data => setResults(data))
      .finally(() => setLoading(false));

    return () => controller.abort();
  }, [filters]);

  const handleFilterChange = (sectionId: string, values: string[]) => {
    if (sectionId === 'reset') {
      setFilters({});
      return;
    }
    setFilters(prev => ({ ...prev, [sectionId]: values }));
  };

  return (
    <div className="container mx-auto px-4 py-10">
      <div className="flex flex-col lg:flex-row gap-8">
        <div className="lg:w-1/4 space-y-6">
          <FilterSidebar sections={[...sections, ...toggleSections]} values={filters} onChange={handleFilterChange} />
          <div className="card p-5 text-center">
            <h3 className="text-lg font-semibold mb-2">Sell Your Vehicle</h3>
            <p className="text-gray-600 text-sm mb-4">List and reach 1M+ Autopredator buyers.</p>
            <button type="button" className="btn-primary w-full">
              Start Listing
            </button>
          </div>
        </div>

        <div className="lg:w-3/4 space-y-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-xs uppercase tracking-[0.3em] text-gray-500">Page 3</p>
              <h1 className="text-3xl font-bold text-charcoal">AutoUsed Marketplace</h1>
              <p className="text-sm text-gray-500">{results.length} curated listings</p>
            </div>
            <Link href="/services" className="text-blue text-sm">
              Need Inspection? -{'>'}
            </Link>
          </div>

          {loading ? (
            <div className="text-center py-20 text-gray-500">Loading used vehicles...</div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {results.map(item =>
                item.vehicle ? (
                  <VehicleCard
                    key={`${item.vehicle.id}-${item.listing.id}`}
                    vehicle={{ ...item.vehicle, price_min: item.listing.asking_price }}
                    verified={item.listing.verified}
                    meta={[
                      `${item.listing.year}`,
                      `${item.listing.km_driven.toLocaleString()} km`,
                      item.listing.city,
                      item.listing.condition
                    ]}
                  />
                ) : null
              )}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
