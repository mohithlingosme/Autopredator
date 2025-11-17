import Image from 'next/image';
import Link from 'next/link';
import { CheckCircle2, Fuel, Gauge, Heart, Settings2 } from 'lucide-react';
import { Vehicle } from '@/types';
import { formatPriceRange } from '@/lib/utils';

interface VehicleCardProps {
  vehicle: Vehicle;
  href?: string;
  showActions?: boolean;
  verified?: boolean;
  meta?: string[];
  onFavorite?: (vehicleId: number) => void;
  onCompare?: (vehicleId: number) => void;
}

export default function VehicleCard({
  vehicle,
  href = `/vehicle/${vehicle.id}`,
  showActions = true,
  verified,
  meta,
  onFavorite,
  onCompare
}: VehicleCardProps) {
  const price = formatPriceRange(vehicle.price_min, vehicle.price_max, vehicle.currency);
  const specBadges =
    meta?.filter(Boolean) ||
    ([vehicle.fuel_type, vehicle.transmission, vehicle.seating_capacity ? `${vehicle.seating_capacity} seater` : undefined].filter(
      Boolean
    ) as string[]);

  return (
    <Link href={href} className="card overflow-hidden hover:-translate-y-1 transition-transform block">
      <div className="relative h-48 w-full bg-gray-100">
        <Image
          src={vehicle.image_url || '/placeholder.jpg'}
          alt={vehicle.name}
          fill
          className="object-cover"
          sizes="(max-width:768px) 100vw, 33vw"
        />
        {verified && (
          <span className="absolute top-4 left-4 bg-white/90 text-green-600 px-3 py-1 rounded-full text-xs font-semibold uppercase flex items-center gap-1">
            <CheckCircle2 className="w-3 h-3" />
            Verified
          </span>
        )}
      </div>
      <div className="p-5">
        <div className="flex items-center justify-between text-xs uppercase tracking-wide text-gray-500 mb-2">
          <span>{vehicle.brand}</span>
          {vehicle.rating && (
            <span className="text-amber-500 font-semibold">{vehicle.rating.toFixed(1)} ★</span>
          )}
        </div>
        <h3 className="text-xl font-semibold mb-1 text-charcoal">{vehicle.name}</h3>
        <p className="text-blue text-lg font-bold mb-4">{price}</p>

        <div className="flex flex-wrap gap-2 text-sm">
          {specBadges.map(spec => (
            <span key={spec} className="inline-flex items-center gap-1 bg-gray-100 px-3 py-1 rounded-full text-gray-600">
              {spec.includes('km') && <Gauge className="w-3 h-3" />}
              {spec.toLowerCase().includes('petrol') && <Fuel className="w-3 h-3" />}
              {spec.toLowerCase().includes('auto') && <Settings2 className="w-3 h-3" />}
              {spec}
            </span>
          ))}
        </div>

        {showActions && (
          <div className="mt-4 flex items-center justify-between text-sm">
            <button
              type="button"
              className="btn-secondary flex-1 mr-2 text-center"
              onClick={event => {
                event.preventDefault();
                onCompare?.(vehicle.id);
              }}
            >
              Compare
            </button>
            <button
              type="button"
              className="w-10 h-10 rounded-full border border-gray-200 flex items-center justify-center text-red-500 hover:bg-red-50"
              onClick={event => {
                event.preventDefault();
                onFavorite?.(vehicle.id);
              }}
              aria-label="Save vehicle"
            >
              <Heart className="w-4 h-4" />
            </button>
          </div>
        )}
      </div>
    </Link>
  );
}
