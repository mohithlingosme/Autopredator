import React, { useState } from 'react';
import { SlidersHorizontal, MapPin, Plus } from 'lucide-react';
import { Button } from './ui/button';
import { UsedVehicleCard } from './UsedVehicleCard';
import { usedVehicles } from '../data/usedVehicles';
import { Checkbox } from './ui/checkbox';
import { Label } from './ui/label';
import { Slider } from './ui/slider';
import { Input } from './ui/input';
import { Card } from './ui/card';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from './ui/select';

interface UsedVehicleListingPageProps {
  onNavigate: (page: string, vehicleId?: string) => void;
}

export function UsedVehicleListingPage({ onNavigate }: UsedVehicleListingPageProps) {
  const [showFilters, setShowFilters] = useState(true);
  const [priceRange, setPriceRange] = useState([0, 3000000]);
  const [kmRange, setKmRange] = useState([0, 100000]);
  const [selectedBrands, setSelectedBrands] = useState<string[]>([]);
  const [selectedOwnerTypes, setSelectedOwnerTypes] = useState<string[]>([]);
  const [selectedCity, setSelectedCity] = useState('all');
  const [verifiedOnly, setVerifiedOnly] = useState(false);
  const [sortBy, setSortBy] = useState('recent');

  const brands = ['Hyundai', 'Maruti Suzuki', 'Tata', 'Honda', 'Mahindra', 'Toyota', 'Kia'];
  const ownerTypes = ['1st Owner', '2nd Owner', '3rd Owner'];
  const cities = ['All Cities', 'Delhi NCR', 'Mumbai', 'Bangalore', 'Pune', 'Chennai', 'Hyderabad', 'Ahmedabad', 'Jaipur'];

  const toggleBrand = (brand: string) => {
    setSelectedBrands(prev =>
      prev.includes(brand) ? prev.filter(b => b !== brand) : [...prev, brand]
    );
  };

  const toggleOwnerType = (ownerType: string) => {
    setSelectedOwnerTypes(prev =>
      prev.includes(ownerType) ? prev.filter(o => o !== ownerType) : [...prev, ownerType]
    );
  };

  const filteredVehicles = usedVehicles.filter(vehicle => {
    if (selectedBrands.length > 0 && !selectedBrands.includes(vehicle.brand)) return false;
    if (selectedOwnerTypes.length > 0 && !selectedOwnerTypes.includes(vehicle.ownerType)) return false;
    if (vehicle.price < priceRange[0] || vehicle.price > priceRange[1]) return false;
    if (vehicle.kmDriven < kmRange[0] || vehicle.kmDriven > kmRange[1]) return false;
    if (verifiedOnly && !vehicle.verified) return false;
    if (selectedCity !== 'all' && vehicle.location !== selectedCity) return false;
    return true;
  });

  return (
    <div>
      {/* Page Header */}
      <div className="bg-gradient-to-r from-[#2C2C2C] to-[#007BFF] text-white py-6">
        <div className="max-w-7xl mx-auto px-6">
          <h1 className="mb-4">Used Vehicle Marketplace</h1>
          <div className="flex gap-4">
            <Input
              type="text"
              placeholder="Search by brand, model..."
              className="max-w-md bg-white text-gray-900"
            />
            <Select value={selectedCity} onValueChange={setSelectedCity}>
              <SelectTrigger className="w-48 bg-white text-gray-900">
                <MapPin className="w-4 h-4 mr-2" />
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Cities</SelectItem>
                {cities.slice(1).map(city => (
                  <SelectItem key={city} value={city}>{city}</SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-6 py-8">
        {/* Quick Stats */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
          <Card className="p-4 text-center">
            <div className="text-[#007BFF] mb-1">{filteredVehicles.length}</div>
            <div className="text-sm text-gray-600">Available</div>
          </Card>
          <Card className="p-4 text-center">
            <div className="text-[#39FF14] mb-1">{filteredVehicles.filter(v => v.verified).length}</div>
            <div className="text-sm text-gray-600">Verified</div>
          </Card>
          <Card className="p-4 text-center">
            <div className="text-[#007BFF] mb-1">{filteredVehicles.filter(v => v.sellerType === 'certified').length}</div>
            <div className="text-sm text-gray-600">Certified</div>
          </Card>
          <Card className="p-4 text-center">
            <div className="text-[#2C2C2C] mb-1">24/7</div>
            <div className="text-sm text-gray-600">Support</div>
          </Card>
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
                    setSelectedOwnerTypes([]);
                    setPriceRange([0, 3000000]);
                    setKmRange([0, 100000]);
                    setVerifiedOnly(false);
                  }}
                >
                  Clear All
                </Button>
              </div>

              {/* Verified Only */}
              <div className="pb-6 border-b">
                <div className="flex items-center gap-2">
                  <Checkbox
                    id="verified"
                    checked={verifiedOnly}
                    onCheckedChange={(checked) => setVerifiedOnly(checked as boolean)}
                  />
                  <Label htmlFor="verified" className="cursor-pointer">
                    Show Verified Only
                  </Label>
                </div>
              </div>

              {/* Price Range */}
              <div className="pb-6 border-b">
                <Label className="mb-4 block">Price Range</Label>
                <Slider
                  value={priceRange}
                  onValueChange={setPriceRange}
                  max={3000000}
                  step={50000}
                  className="mb-4"
                />
                <div className="flex justify-between text-sm text-gray-600">
                  <span>₹{(priceRange[0] / 100000).toFixed(1)}L</span>
                  <span>₹{(priceRange[1] / 100000).toFixed(1)}L</span>
                </div>
              </div>

              {/* KM Driven */}
              <div className="pb-6 border-b">
                <Label className="mb-4 block">KM Driven</Label>
                <Slider
                  value={kmRange}
                  onValueChange={setKmRange}
                  max={100000}
                  step={5000}
                  className="mb-4"
                />
                <div className="flex justify-between text-sm text-gray-600">
                  <span>{(kmRange[0] / 1000).toFixed(0)}K</span>
                  <span>{(kmRange[1] / 1000).toFixed(0)}K km</span>
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

              {/* Owner Type */}
              <div className="pb-6 border-b">
                <Label className="mb-4 block">Owner Type</Label>
                <div className="space-y-3">
                  {ownerTypes.map((ownerType) => (
                    <div key={ownerType} className="flex items-center gap-2">
                      <Checkbox
                        id={`owner-${ownerType}`}
                        checked={selectedOwnerTypes.includes(ownerType)}
                        onCheckedChange={() => toggleOwnerType(ownerType)}
                      />
                      <Label htmlFor={`owner-${ownerType}`} className="cursor-pointer">
                        {ownerType}
                      </Label>
                    </div>
                  ))}
                </div>
              </div>

              {/* Sell Your Vehicle CTA */}
              <Card className="p-4 bg-gradient-to-br from-[#007BFF] to-[#2C2C2C] text-white">
                <h4 className="mb-2">Sell Your Vehicle</h4>
                <p className="text-sm mb-4 text-gray-200">
                  Get the best price with our AI-powered valuation
                </p>
                <Button variant="secondary" className="w-full">
                  Get Quote
                </Button>
              </Card>
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

              <div className="flex items-center gap-2">
                <Button variant="outline" size="sm">Certified</Button>
                <Button variant="outline" size="sm">Dealer</Button>
                <Button variant="outline" size="sm">Individual</Button>
              </div>

              <div className="flex items-center gap-4">
                <span className="text-sm text-gray-600">Sort By:</span>
                <Select value={sortBy} onValueChange={setSortBy}>
                  <SelectTrigger className="w-48">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="recent">Most Recent</SelectItem>
                    <SelectItem value="price-low">Price: Low to High</SelectItem>
                    <SelectItem value="price-high">Price: High to Low</SelectItem>
                    <SelectItem value="km-low">KM: Low to High</SelectItem>
                    <SelectItem value="year-new">Year: Newest First</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            </div>

            {/* Vehicle Grid */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-8">
              {filteredVehicles.map((vehicle) => (
                <UsedVehicleCard
                  key={vehicle.id}
                  vehicle={vehicle}
                  onView={(id) => onNavigate('used-detail', id)}
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
                    setSelectedOwnerTypes([]);
                    setPriceRange([0, 3000000]);
                    setKmRange([0, 100000]);
                    setVerifiedOnly(false);
                  }}
                >
                  Clear Filters
                </Button>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
