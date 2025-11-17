'use client';

import { useEffect, useMemo, useState, useTransition } from 'react';
import VehicleCard from '@/components/VehicleCard';
import FilterSidebar, { FilterSection } from '@/components/FilterSidebar';
import { API_BASE_URL } from '@/lib/utils';
import { Vehicle } from '@/types';

const sections: FilterSection[] = [
  {
    id: 'brand',
    title: 'Brand',
    type: 'select',
    options: ['Toyota', 'Honda', 'Hyundai', 'Mahindra', 'Kia', 'Tata', 'Ford', 'Renault', 'Maruti'].map(brand => ({
      label: brand,
      value: brand.toLowerCase()
    }))
  },
  {
    id: 'fuel',
    title: 'Fuel Type',
    type: 'select',
    options: ['Petrol', 'Diesel', 'Electric', 'Hybrid'].map(type => ({
      label: type,
      value: type.toLowerCase()
    }))
  },
  {
    id: 'body',
    title: 'Body Type',
    type: 'select',
    options: ['Sedan', 'SUV', 'Hatchback', 'MPV'].map(type => ({
      label: type,
      value: type.toLowerCase()
    }))
  },
  {
    id: 'transmission',
    title: 'Transmission',
    type: 'select',
    options: ['Manual', 'Automatic', 'CVT'].map(type => ({
      label: type,
      value: type.toLowerCase()
    }))
  },
  {
    id: 'seating',
    title: 'Seating Capacity',
    type: 'select',
    options: [
      { label: '5 Seater', value: '5' },
      { label: '7 Seater', value: '7' },
      { label: '8+ Seater', value: '8' }
    ]
  }
];

export default function NewVehiclesPage() {
  const [filters, setFilters] = useState<Record<string, string[]>>({});
  const [sort, setSort] = useState('popularity');
  const [vehicles, setVehicles] = useState<Vehicle[]>([]);
  const [loading, setLoading] = useState(true);
  const [, startTransition] = useTransition();

  useEffect(() => {
    const controller = new AbortController();
    const params = new URLSearchParams({ type: 'new', sort });
    Object.entries(filters).forEach(([key, value]) => {
      if (value?.[0]) {
        params.append(key, value[0]);
      }
    });

    startTransition(() => setLoading(true));
    fetch(`${API_BASE_URL}/api/vehicles?${params.toString()}`, { signal: controller.signal })
      .then(response => response.json())
      .then(data => setVehicles(data))
      .finally(() => setLoading(false));

    return () => controller.abort();
  }, [filters, sort]);

  const totalResults = vehicles.length;

  const handleFilterChange = (sectionId: string, values: string[]) => {
    if (sectionId === 'reset') {
      setFilters({});
      return;
    }
    setFilters(prev => ({ ...prev, [sectionId]: values }));
  };

  const filterFooter = useMemo(
    () => (
      <div className="space-y-3 text-sm text-gray-600">
        <p>Need help deciding?</p>
        <button type="button" className="btn-primary w-full">
          Ask Advisor
        </button>
      </div>
    ),
    []
  );

  return (
    <div className="container mx-auto px-4 py-10">
      <div className="flex flex-col lg:flex-row gap-8">
        <div className="lg:w-1/4">
          <FilterSidebar sections={sections} values={filters} onChange={handleFilterChange} footer={filterFooter} />
        </div>

        <div className="lg:w-3/4 space-y-6">
          <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
            <div>
              <p className="text-xs uppercase tracking-[0.3em] text-gray-500">Page 2</p>
              <h1 className="text-3xl font-bold text-charcoal">New Vehicles</h1>
              <p className="text-gray-500 text-sm">{totalResults} results</p>
            </div>
            <div className="flex items-center gap-3">
              <span className="text-sm text-gray-500">Sort By</span>
              <select className="border rounded-md px-3 py-2" value={sort} onChange={event => setSort(event.target.value)}>
                <option value="popularity">Popularity</option>
                <option value="price-low">Price: Low to High</option>
                <option value="price-high">Price: High to Low</option>
                <option value="efficiency">Efficiency</option>
                <option value="rating">Rating</option>
              </select>
            </div>
          </div>

          {loading ? (
            <div className="text-center py-20 text-gray-500">Loading vehicles...</div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
              {vehicles.map(vehicle => (
                <VehicleCard key={vehicle.id} vehicle={vehicle} />
              ))}
            </div>
          )}

          <div className="flex justify-center">
            <div className="flex items-center gap-2">
              {[1, 2, 3].map(page => (
                <button key={page} type="button" className={`px-3 py-2 rounded-md ${page === 1 ? 'bg-blue text-white' : 'border'}`}>
                  {page}
                </button>
              ))}
              <button type="button" className="px-3 py-2 border rounded-md">
                Next -{'>'}
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
