import React, { useState } from 'react';
import { SlidersHorizontal, ChevronDown, ChevronUp } from 'lucide-react';
import { Button } from './ui/button';
import { VehicleCard } from './VehicleCard';
import { vehicles } from '../data/vehicles';
import { Checkbox } from './ui/checkbox';
import { Label } from './ui/label';
import { Slider } from './ui/slider';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from './ui/select';

interface ListingPageProps {
  onNavigate: (page: string, vehicleId?: string) => void;
}

export function ListingPage({ onNavigate }: ListingPageProps) {
  const [showFilters, setShowFilters] = useState(true);
  const [priceRange, setPriceRange] = useState([0, 3000000]);
  const [selectedBrands, setSelectedBrands] = useState<string[]>([]);
  const [selectedFuelTypes, setSelectedFuelTypes] = useState<string[]>([]);
  const [sortBy, setSortBy] = useState('popularity');

  const brands = ['Hyundai', 'Maruti Suzuki', 'Tata', 'Honda', 'Mahindra', 'Toyota', 'Kia', 'Royal Enfield'];
  const fuelTypes = ['Petrol', 'Diesel', 'Electric', 'Hybrid'];
  const bodyTypes = ['Hatchback', 'Sedan', 'SUV', 'MPV', 'Adventure Bike'];

  const toggleBrand = (brand: string) => {
    setSelectedBrands(prev =>
      prev.includes(brand) ? prev.filter(b => b !== brand) : [...prev, brand]
    );
  };

  const toggleFuelType = (fuelType: string) => {
    setSelectedFuelTypes(prev =>
      prev.includes(fuelType) ? prev.filter(f => f !== fuelType) : [...prev, fuelType]
    );
  };

  const filteredVehicles = vehicles.filter(vehicle => {
    if (selectedBrands.length > 0 && !selectedBrands.includes(vehicle.brand)) return false;
    if (selectedFuelTypes.length > 0 && !selectedFuelTypes.includes(vehicle.fuelType)) return false;
    if (vehicle.priceMin < priceRange[0] || vehicle.priceMax > priceRange[1]) return false;
    return true;
  });

  return (
    <div className="max-w-7xl mx-auto px-6 py-8">
      {/* Header */}
      <div className="mb-6">
        <h1 className="mb-2">Vehicle Listings</h1>
        <p className="text-gray-600">{filteredVehicles.length} vehicles found</p>
      </div>

      <div className="flex gap-8">
        {/* Filters Sidebar */}
        <aside className={`w-64 flex-shrink-0 ${showFilters ? 'block' : 'hidden'} lg:block`}>
          <div className="sticky top-24 space-y-6">
            <div className="flex items-center justify-between mb-4">
              <h3>Filters</h3>
              <Button
                variant="ghost"
                size="sm"
                onClick={() => {
                  setSelectedBrands([]);
                  setSelectedFuelTypes([]);
                  setPriceRange([0, 3000000]);
                }}
              >
                Clear All
              </Button>
            </div>

            {/* Price Range */}
            <div className="pb-6 border-b">
              <Label className="mb-4 block">Price Range</Label>
              <Slider
                value={priceRange}
                onValueChange={setPriceRange}
                max={3000000}
                step={100000}
                className="mb-4"
              />
              <div className="flex justify-between text-sm text-gray-600">
                <span>₹{(priceRange[0] / 100000).toFixed(1)}L</span>
                <span>₹{(priceRange[1] / 100000).toFixed(1)}L</span>
              </div>
            </div>

            {/* Brand Filter */}
            <div className="pb-6 border-b">
              <Label className="mb-4 block">Brand</Label>
              <div className="space-y-3 max-h-48 overflow-y-auto">
                {brands.map((brand) => (
                  <div key={brand} className="flex items-center gap-2">
                    <Checkbox
                      id={`brand-${brand}`}
                      checked={selectedBrands.includes(brand)}
                      onCheckedChange={() => toggleBrand(brand)}
                    />
                    <Label htmlFor={`brand-${brand}`} className="cursor-pointer">
                      {brand}
                    </Label>
                  </div>
                ))}
              </div>
            </div>

            {/* Fuel Type Filter */}
            <div className="pb-6 border-b">
              <Label className="mb-4 block">Fuel Type</Label>
              <div className="space-y-3">
                {fuelTypes.map((fuelType) => (
                  <div key={fuelType} className="flex items-center gap-2">
                    <Checkbox
                      id={`fuel-${fuelType}`}
                      checked={selectedFuelTypes.includes(fuelType)}
                      onCheckedChange={() => toggleFuelType(fuelType)}
                    />
                    <Label htmlFor={`fuel-${fuelType}`} className="cursor-pointer">
                      {fuelType}
                    </Label>
                  </div>
                ))}
              </div>
            </div>

            {/* Body Type */}
            <div className="pb-6 border-b">
              <Label className="mb-4 block">Body Type</Label>
              <div className="space-y-3">
                {bodyTypes.map((bodyType) => (
                  <div key={bodyType} className="flex items-center gap-2">
                    <Checkbox id={`body-${bodyType}`} />
                    <Label htmlFor={`body-${bodyType}`} className="cursor-pointer">
                      {bodyType}
                    </Label>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </aside>

        {/* Main Content */}
        <div className="flex-1">
          {/* Top Bar */}
          <div className="flex items-center justify-between mb-6 pb-4 border-b">
            <Button
              variant="outline"
              className="lg:hidden gap-2"
              onClick={() => setShowFilters(!showFilters)}
            >
              <SlidersHorizontal className="w-4 h-4" />
              {showFilters ? 'Hide' : 'Show'} Filters
            </Button>

            <div className="flex items-center gap-4">
              <span className="text-sm text-gray-600">Sort By:</span>
              <Select value={sortBy} onValueChange={setSortBy}>
                <SelectTrigger className="w-48">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="popularity">Popularity</SelectItem>
                  <SelectItem value="price-low">Price: Low to High</SelectItem>
                  <SelectItem value="price-high">Price: High to Low</SelectItem>
                  <SelectItem value="rating">Rating</SelectItem>
                  <SelectItem value="mileage">Fuel Efficiency</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>

          {/* Vehicle Grid */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-8">
            {filteredVehicles.map((vehicle) => (
              <VehicleCard
                key={vehicle.id}
                vehicle={vehicle}
                onView={(id) => onNavigate('detail', id)}
                onCompare={(id) => {
                  console.log('Compare:', id);
                  onNavigate('compare');
                }}
                onFavorite={(id) => console.log('Favorite:', id)}
              />
            ))}
          </div>

          {/* Pagination */}
          {filteredVehicles.length > 0 && (
            <div className="flex items-center justify-center gap-2">
              <Button variant="outline" size="sm">Previous</Button>
              <Button variant="default" size="sm">1</Button>
              <Button variant="outline" size="sm">2</Button>
              <Button variant="outline" size="sm">3</Button>
              <Button variant="outline" size="sm">Next</Button>
            </div>
          )}

          {filteredVehicles.length === 0 && (
            <div className="text-center py-12">
              <p className="text-gray-600">No vehicles found matching your filters.</p>
              <Button
                variant="outline"
                className="mt-4"
                onClick={() => {
                  setSelectedBrands([]);
                  setSelectedFuelTypes([]);
                  setPriceRange([0, 3000000]);
                }}
              >
                Clear Filters
              </Button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
