'use client';

import { useEffect, useMemo, useState } from 'react';

import VehicleCard from '@/components/VehicleCard';
import FilterSidebar, { FilterSection } from '@/components/FilterSidebar';
import apiClient from '@/lib/api';
import { Vehicle } from '@/types';

const sections: FilterSection[] = [
  {
    id: 'year',
    title: 'Registration year',
    type: 'select',
    options: [
      { label: '2024+', value: '2024' },
      { label: '2022+', value: '2022' },
      { label: '2020+', value: '2020' }
    ]
  },
  {
    id: 'fuel',
    title: 'Fuel type',
    type: 'select',
    options: ['Petrol', 'Diesel', 'Electric', 'Hybrid'].map(type => ({
      label: type,
      value: type.toLowerCase()
    }))
  },
  {
    id: 'type',
    title: 'Vehicle type',
    type: 'select',
    options: ['Sedan', 'SUV', 'Truck', 'Van'].map(type => ({
      label: type,
      value: type.toLowerCase()
    }))
  }
];

export default function NewVehiclesPage() {
  const [vehicles, setVehicles] = useState<Vehicle[]>([]);
  const [filters, setFilters] = useState<Record<string, string[]>>({});
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let cancelled = false;

    const loadVehicles = async () => {
      try {
        const response = await apiClient.get<Vehicle[]>('/vehicles/');
        if (!cancelled) {
          setVehicles(response.data);
        }
      } finally {
        if (!cancelled) {
          setLoading(false);
        }
      }
    };

    loadVehicles();
    return () => {
      cancelled = true;
    };
  }, []);

  const filteredVehicles = useMemo(() => {
    return vehicles.filter(vehicle => {
      const yearFilter = filters.year?.[0];
      const fuelFilter = filters.fuel?.[0];
      const typeFilter = filters.type?.[0];

      if (yearFilter && vehicle.year && vehicle.year < Number(yearFilter)) {
        return false;
      }
      if (fuelFilter && vehicle.fuel_type && vehicle.fuel_type.toLowerCase() !== fuelFilter) {
        return false;
      }
      if (typeFilter && vehicle.vehicle_type && vehicle.vehicle_type.toLowerCase() !== typeFilter) {
        return false;
      }
      return true;
    });
  }, [vehicles, filters]);

  const handleFilterChange = (sectionId: string, values: string[]) => {
    if (sectionId === 'reset') {
      setFilters({});
      return;
    }
    setFilters(prev => ({ ...prev, [sectionId]: values }));
  };

  const popular = filteredVehicles.slice(0, 6);

  return (
    <div className="container mx-auto px-4 py-10">
      <div className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
        <div>
          <p className="text-xs uppercase tracking-[0.3em] text-gray-500">New fleet+</p>
          <h1 className="text-3xl font-bold text-charcoal">New Vehicles</h1>
          <p className="text-sm text-gray-500">Track and plan your next acquisitions.</p>
        </div>
      </div>

      <div className="flex flex-col lg:flex-row gap-8 mt-8">
        <div className="lg:w-1/4">
          <FilterSidebar sections={sections} values={filters} onChange={handleFilterChange} />
        </div>

        <div className="lg:w-3/4 space-y-6">
          {loading ? (
            <div className="text-center py-14 text-gray-500">Loading new vehicle suggestions...</div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
              {(popular.length ? popular : vehicles.slice(0, 6)).map(vehicle => (
                <VehicleCard key={vehicle.id} vehicle={vehicle} />
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
