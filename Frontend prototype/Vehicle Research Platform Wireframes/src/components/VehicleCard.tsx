import React from 'react';
import { Heart, GitCompare, Star, Fuel, Settings } from 'lucide-react';
import { Card } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { ImageWithFallback } from './figma/ImageWithFallback';

export interface Vehicle {
  id: string;
  name: string;
  brand: string;
  model: string;
  priceRange: string;
  priceMin: number;
  priceMax: number;
  image: string;
  fuelType: string;
  transmission: string;
  mileage: string;
  rating: number;
  reviews: number;
  bodyType: string;
  seating: number;
  engine: string;
  power: string;
  torque: string;
  dimensions: string;
}

interface VehicleCardProps {
  vehicle: Vehicle;
  onCompare?: (id: string) => void;
  onFavorite?: (id: string) => void;
  onView?: (id: string) => void;
  isComparing?: boolean;
  isFavorite?: boolean;
}

export function VehicleCard({ 
  vehicle, 
  onCompare, 
  onFavorite, 
  onView,
  isComparing = false,
  isFavorite = false 
}: VehicleCardProps) {
  return (
    <Card className="overflow-hidden hover:shadow-lg transition-shadow cursor-pointer group">
      <div className="relative" onClick={() => onView?.(vehicle.id)}>
        <ImageWithFallback
          src={vehicle.image}
          alt={vehicle.name}
          className="w-full h-48 object-cover"
        />
        <button
          onClick={(e) => {
            e.stopPropagation();
            onFavorite?.(vehicle.id);
          }}
          className="absolute top-2 right-2 p-2 bg-white rounded-full shadow-md hover:bg-gray-50"
        >
          <Heart 
            className={`w-4 h-4 ${isFavorite ? 'fill-red-500 text-red-500' : 'text-gray-600'}`}
          />
        </button>
        {vehicle.fuelType === 'Electric' && (
          <Badge className="absolute top-2 left-2 bg-green-600">
            EV
          </Badge>
        )}
      </div>

      <div className="p-4">
        <div className="mb-2">
          <h3 className="line-clamp-1">{vehicle.name}</h3>
          <p className="text-gray-600">{vehicle.priceRange}</p>
        </div>

        <div className="flex items-center gap-4 mb-3 text-sm text-gray-600">
          <div className="flex items-center gap-1">
            <Fuel className="w-4 h-4" />
            <span>{vehicle.fuelType}</span>
          </div>
          <div className="flex items-center gap-1">
            <Settings className="w-4 h-4" />
            <span>{vehicle.transmission}</span>
          </div>
        </div>

        <div className="flex items-center justify-between mb-3 text-sm">
          <div className="flex items-center gap-1">
            <Star className="w-4 h-4 fill-yellow-400 text-yellow-400" />
            <span>{vehicle.rating.toFixed(1)}</span>
            <span className="text-gray-500">({vehicle.reviews})</span>
          </div>
          <span className="text-gray-600">{vehicle.mileage}</span>
        </div>

        <Button
          variant={isComparing ? 'default' : 'outline'}
          className="w-full gap-2"
          onClick={(e) => {
            e.stopPropagation();
            onCompare?.(vehicle.id);
          }}
        >
          <GitCompare className="w-4 h-4" />
          {isComparing ? 'Remove' : 'Compare'}
        </Button>
      </div>
    </Card>
  );
}
