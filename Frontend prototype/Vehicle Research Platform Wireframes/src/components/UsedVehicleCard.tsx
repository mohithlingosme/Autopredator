import React from 'react';
import { MapPin, Gauge, Fuel, Settings, Shield, CheckCircle2 } from 'lucide-react';
import { Card } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { ImageWithFallback } from './figma/ImageWithFallback';
import { UsedVehicle } from '../data/usedVehicles';

interface UsedVehicleCardProps {
  vehicle: UsedVehicle;
  onView?: (id: string) => void;
}

export function UsedVehicleCard({ vehicle, onView }: UsedVehicleCardProps) {
  const discount = Math.round(((vehicle.originalPrice - vehicle.price) / vehicle.originalPrice) * 100);

  return (
    <Card className="overflow-hidden hover:shadow-lg transition-shadow cursor-pointer group">
      <div className="relative" onClick={() => onView?.(vehicle.id)}>
        <ImageWithFallback
          src={vehicle.image}
          alt={vehicle.name}
          className="w-full h-48 object-cover"
        />
        {vehicle.verified && (
          <Badge className="absolute top-2 left-2 bg-[#39FF14] text-[#2C2C2C] gap-1">
            <CheckCircle2 className="w-3 h-3" />
            Verified
          </Badge>
        )}
        {vehicle.sellerType === 'certified' && (
          <Badge className="absolute top-2 right-2 bg-[#007BFF]">
            Certified
          </Badge>
        )}
        {discount > 0 && (
          <div className="absolute bottom-2 left-2 bg-[#2C2C2C] text-white px-2 py-1 rounded text-sm">
            {discount}% off
          </div>
        )}
      </div>

      <div className="p-4">
        <div className="mb-3">
          <h3 className="line-clamp-1 mb-1">{vehicle.name}</h3>
          <div className="flex items-center justify-between">
            <div className="text-[#007BFF]">₹{(vehicle.price / 100000).toFixed(2)}L</div>
            {vehicle.negotiable && (
              <Badge variant="outline" className="text-xs">Negotiable</Badge>
            )}
          </div>
        </div>

        <div className="grid grid-cols-2 gap-2 mb-3 text-sm text-gray-600">
          <div className="flex items-center gap-1">
            <Gauge className="w-3 h-3" />
            <span>{(vehicle.kmDriven / 1000).toFixed(0)}K km</span>
          </div>
          <div className="flex items-center gap-1">
            <Fuel className="w-3 h-3" />
            <span>{vehicle.fuelType}</span>
          </div>
          <div className="flex items-center gap-1">
            <Settings className="w-3 h-3" />
            <span>{vehicle.transmission}</span>
          </div>
          <div className="flex items-center gap-1">
            <MapPin className="w-3 h-3" />
            <span>{vehicle.location}</span>
          </div>
        </div>

        <div className="flex items-center justify-between mb-3 pb-3 border-b text-xs">
          <span className="text-gray-600">{vehicle.year} • {vehicle.ownerType}</span>
          {vehicle.blockchainVerified && (
            <div className="flex items-center gap-1 text-[#39FF14]">
              <Shield className="w-3 h-3" />
              <span>Blockchain</span>
            </div>
          )}
        </div>

        <Button
          variant="outline"
          className="w-full"
          onClick={(e) => {
            e.stopPropagation();
            onView?.(vehicle.id);
          }}
        >
          View Details
        </Button>
      </div>
    </Card>
  );
}
