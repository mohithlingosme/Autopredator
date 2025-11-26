import React, { useState } from 'react';
import { X, Plus, Star, Fuel, Settings, Users, Zap, Shield, TrendingUp } from 'lucide-react';
import { Button } from './ui/button';
import { Card } from './ui/card';
import { Badge } from './ui/badge';
import { vehicles } from '../data/vehicles';
import { ImageWithFallback } from './figma/ImageWithFallback';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from './ui/select';

interface ComparisonPageProps {
  onNavigate: (page: string, vehicleId?: string) => void;
}

export function ComparisonPage({ onNavigate }: ComparisonPageProps) {
  const [selectedVehicles, setSelectedVehicles] = useState<string[]>([vehicles[0].id, vehicles[3].id]);

  const addVehicle = (vehicleId: string) => {
    if (selectedVehicles.length < 4 && !selectedVehicles.includes(vehicleId)) {
      setSelectedVehicles([...selectedVehicles, vehicleId]);
    }
  };

  const removeVehicle = (vehicleId: string) => {
    setSelectedVehicles(selectedVehicles.filter(id => id !== vehicleId));
  };

  const compareVehicles = selectedVehicles.map(id => vehicles.find(v => v.id === id)!);
  const availableVehicles = vehicles.filter(v => !selectedVehicles.includes(v.id));

  const getBestValue = (values: number[], reverse = false) => {
    const best = reverse ? Math.min(...values) : Math.max(...values);
    return values.map(v => v === best);
  };

  const prices = compareVehicles.map(v => v.priceMin);
  const ratings = compareVehicles.map(v => v.rating);
  const mileages = compareVehicles.map(v => parseFloat(v.mileage));

  const isBestPrice = getBestValue(prices, true);
  const isBestRating = getBestValue(ratings);
  const isBestMileage = getBestValue(mileages);

  const comparisonRows = [
    { 
      category: 'Price', 
      icon: TrendingUp, 
      items: compareVehicles.map(v => v.priceRange),
      bestIndexes: isBestPrice
    },
    { 
      category: 'Rating', 
      icon: Star, 
      items: compareVehicles.map(v => (
        <div className="flex items-center gap-1">
          <Star className="w-4 h-4 fill-yellow-400 text-yellow-400" />
          {v.rating.toFixed(1)} ({v.reviews})
        </div>
      )),
      bestIndexes: isBestRating
    },
    { 
      category: 'Mileage', 
      icon: Fuel, 
      items: compareVehicles.map(v => v.mileage),
      bestIndexes: isBestMileage
    },
    { 
      category: 'Engine', 
      icon: Zap, 
      items: compareVehicles.map(v => v.engine),
      bestIndexes: []
    },
    { 
      category: 'Power', 
      icon: Zap, 
      items: compareVehicles.map(v => v.power),
      bestIndexes: []
    },
    { 
      category: 'Torque', 
      icon: Zap, 
      items: compareVehicles.map(v => v.torque),
      bestIndexes: []
    },
    { 
      category: 'Fuel Type', 
      icon: Fuel, 
      items: compareVehicles.map(v => v.fuelType),
      bestIndexes: []
    },
    { 
      category: 'Transmission', 
      icon: Settings, 
      items: compareVehicles.map(v => v.transmission),
      bestIndexes: []
    },
    { 
      category: 'Seating', 
      icon: Users, 
      items: compareVehicles.map(v => `${v.seating} Seats`),
      bestIndexes: []
    },
    { 
      category: 'Body Type', 
      icon: Shield, 
      items: compareVehicles.map(v => v.bodyType),
      bestIndexes: []
    }
  ];

  return (
    <div className="max-w-7xl mx-auto px-6 py-8">
      {/* Header */}
      <div className="mb-8">
        <h1 className="mb-2">Compare Vehicles</h1>
        <p className="text-gray-600">
          Compare up to 4 vehicles side by side. Add vehicles to see detailed comparisons.
        </p>
      </div>

      {/* Vehicle Selection Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
        {compareVehicles.map((vehicle, index) => (
          <Card key={vehicle.id} className="overflow-hidden">
            <div className="relative">
              <ImageWithFallback
                src={vehicle.image}
                alt={vehicle.name}
                className="w-full h-40 object-cover"
              />
              <button
                onClick={() => removeVehicle(vehicle.id)}
                className="absolute top-2 right-2 p-1.5 bg-white rounded-full shadow-md hover:bg-gray-100"
              >
                <X className="w-4 h-4" />
              </button>
              {vehicle.fuelType === 'Electric' && (
                <Badge className="absolute top-2 left-2 bg-green-600">EV</Badge>
              )}
            </div>
            <div className="p-4">
              <h3 className="line-clamp-2 mb-1">{vehicle.name}</h3>
              <p className="text-gray-600">{vehicle.priceRange}</p>
              <Button
                variant="outline"
                size="sm"
                className="w-full mt-3"
                onClick={() => onNavigate('detail', vehicle.id)}
              >
                View Details
              </Button>
            </div>
          </Card>
        ))}

        {/* Add Vehicle Card */}
        {selectedVehicles.length < 4 && (
          <Card className="flex items-center justify-center p-6 border-2 border-dashed cursor-pointer hover:border-blue-400 hover:bg-gray-50">
            <Select onValueChange={addVehicle}>
              <SelectTrigger className="w-full">
                <div className="flex items-center justify-center gap-2 text-gray-600">
                  <Plus className="w-5 h-5" />
                  <span>Add Vehicle</span>
                </div>
              </SelectTrigger>
              <SelectContent>
                {availableVehicles.map((vehicle) => (
                  <SelectItem key={vehicle.id} value={vehicle.id}>
                    {vehicle.name}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </Card>
        )}
      </div>

      {/* Comparison Table */}
      {compareVehicles.length > 0 && (
        <Card className="overflow-hidden mb-8">
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-gray-50 border-b">
                <tr>
                  <th className="text-left p-4 min-w-[200px]">Feature</th>
                  {compareVehicles.map((vehicle) => (
                    <th key={vehicle.id} className="text-left p-4 min-w-[200px]">
                      {vehicle.brand}
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {comparisonRows.map((row, rowIndex) => (
                  <tr key={rowIndex} className="border-b hover:bg-gray-50">
                    <td className="p-4">
                      <div className="flex items-center gap-2">
                        <row.icon className="w-4 h-4 text-gray-500" />
                        <span>{row.category}</span>
                      </div>
                    </td>
                    {row.items.map((item, colIndex) => (
                      <td 
                        key={colIndex} 
                        className={`p-4 ${
                          row.bestIndexes[colIndex] ? 'bg-green-50 border-l-4 border-green-500' : ''
                        }`}
                      >
                        <div className="flex items-center gap-2">
                          {item}
                          {row.bestIndexes[colIndex] && (
                            <Badge className="bg-green-600 text-xs">Best</Badge>
                          )}
                        </div>
                      </td>
                    ))}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </Card>
      )}

      {/* AI Verdict */}
      {compareVehicles.length > 1 && (
        <Card className="p-6 bg-gradient-to-br from-purple-50 to-blue-50">
          <div className="flex items-start gap-4">
            <div className="w-12 h-12 bg-purple-100 rounded-full flex items-center justify-center flex-shrink-0">
              <TrendingUp className="w-6 h-6 text-purple-600" />
            </div>
            <div>
              <h3 className="mb-3">AI Verdict</h3>
              <div className="space-y-3">
                <div>
                  <span className="text-purple-600">Best Overall Value:</span>{' '}
                  <span>{compareVehicles[isBestRating.indexOf(true)]?.name || compareVehicles[0].name}</span>
                  <p className="text-sm text-gray-600 mt-1">
                    Highest rating combined with competitive pricing and excellent features.
                  </p>
                </div>
                <div>
                  <span className="text-purple-600">Best for Fuel Economy:</span>{' '}
                  <span>{compareVehicles[isBestMileage.indexOf(true)]?.name || compareVehicles[0].name}</span>
                  <p className="text-sm text-gray-600 mt-1">
                    Superior fuel efficiency makes this ideal for daily commuting and long drives.
                  </p>
                </div>
                <div>
                  <span className="text-purple-600">Best Budget Option:</span>{' '}
                  <span>{compareVehicles[isBestPrice.indexOf(true)]?.name || compareVehicles[0].name}</span>
                  <p className="text-sm text-gray-600 mt-1">
                    Most affordable option without compromising on essential features.
                  </p>
                </div>
              </div>
            </div>
          </div>
        </Card>
      )}

      {/* Empty State */}
      {compareVehicles.length === 0 && (
        <Card className="p-12 text-center">
          <div className="max-w-md mx-auto">
            <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <Plus className="w-8 h-8 text-gray-400" />
            </div>
            <h3 className="mb-2">No vehicles to compare</h3>
            <p className="text-gray-600 mb-6">
              Add vehicles from our catalog to start comparing their features, specifications, and pricing.
            </p>
            <Button onClick={() => onNavigate('listing')}>
              Browse Vehicles
            </Button>
          </div>
        </Card>
      )}
    </div>
  );
}
