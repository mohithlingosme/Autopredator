import Image from 'next/image';
import Link from 'next/link';
import { Heart } from 'lucide-react';

import { Vehicle } from '@/types';

interface VehicleCardProps {
  vehicle: Vehicle;
  href?: string;
  showActions?: boolean;
  onFavorite?: (vehicleId: number) => void;
  onCompare?: (vehicleId: number) => void;
}

export default function VehicleCard({
  vehicle,
  href = `/vehicle/${vehicle.id}`,
  showActions = true,
  onFavorite,
  onCompare
}: VehicleCardProps) {
  const title = `${vehicle.make} ${vehicle.model}`.trim();
  const statusLabel = vehicle.status ? vehicle.status.toUpperCase() : 'NEW';
  const highlight = vehicle.next_service_date
    ? `Next service ${vehicle.next_service_date}`
    : 'No upcoming service';
  const createdAtLabel = vehicle.created_at
    ? new Date(vehicle.created_at).toLocaleDateString()
    : 'Unknown registration date';

  return (
    <Link href={href} className="card overflow-hidden hover:-translate-y-1 transition-transform block">
      <div className="relative h-48 w-full bg-gray-100">
        <Image
          src={vehicle.image_url || '/placeholder.jpg'}
          alt={title || 'Vehicle'}
          fill
          className="object-cover"
          sizes="(max-width:768px) 100vw, 33vw"
        />
        <span className="absolute top-4 left-4 bg-white/80 text-green-600 px-3 py-1 rounded-full text-xs font-semibold uppercase">
          {statusLabel}
        </span>
      </div>
      <div className="p-5">
        <div className="flex items-center justify-between text-xs uppercase tracking-[0.4em] text-gray-500 mb-1">
          <span>{vehicle.vin ? vehicle.vin.slice(-6) : 'VIN'}</span>
          <span>{vehicle.year ?? 'Year N/A'}</span>
        </div>
        <h3 className="text-xl font-semibold mb-1 text-charcoal">{title || 'Unnamed vehicle'}</h3>
        <p className="text-sm text-gray-500">{vehicle.fuel_type ?? 'Fuel type not tracked'}</p>
        <div className="mt-3 flex flex-wrap gap-2 text-xs text-gray-600">
          <span className="inline-flex items-center rounded-full border border-gray-200 px-3 py-1">
            {highlight}
          </span>
          <span className="inline-flex items-center rounded-full border border-gray-200 px-3 py-1">
            Registered {createdAtLabel}
          </span>
        </div>

        {showActions && (
          <div className="mt-4 flex items-center justify-between text-sm gap-2">
            <button
              type="button"
              className="btn-secondary flex-1 text-center"
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
