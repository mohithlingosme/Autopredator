import Image from 'next/image';
import Link from 'next/link';
import VehicleCard from '@/components/VehicleCard';
import VehicleDetailTabs from '@/components/VehicleDetailTabs';
import { API_BASE_URL, formatPriceRange } from '@/lib/utils';
import { AiInsight, ServiceHistoryRecord, Vehicle, VehicleListing } from '@/types';

interface VehicleResponse {
  vehicle: Vehicle;
  listings: VehicleListing[];
  serviceHistory: ServiceHistoryRecord[];
  related: Vehicle[];
  aiInsight?: AiInsight;
}

async function getVehicle(id: string): Promise<VehicleResponse> {
  const response = await fetch(`${API_BASE_URL}/api/vehicles/${id}`, { cache: 'no-store' });
  if (!response.ok) {
    throw new Error('Vehicle not found');
  }
  return response.json();
}

export default async function VehicleDetailPage({ params }: { params: { id: string } }) {
  const data = await getVehicle(params.id);
  const { vehicle, listings = [], serviceHistory = [], related = [], aiInsight } = data;
  const galleryImages = [
    vehicle.image_url || '/placeholder.jpg',
    vehicle.thumbnail_url || '/placeholder.jpg',
    '/placeholder.jpg'
  ];

  return (
    <div className="container mx-auto px-4 py-10 space-y-12">
      <nav className="text-sm text-gray-500">
        <ol className="flex gap-2">
          <li>
            <Link href="/" className="hover:text-blue">
              Home
            </Link>
          </li>
          <li>/</li>
          <li>
            <Link href={vehicle.type === 'used' ? '/used-vehicles' : '/new-vehicles'} className="hover:text-blue">
              {vehicle.type === 'used' ? 'AutoUsed' : 'New Vehicles'}
            </Link>
          </li>
          <li>/</li>
          <li className="text-charcoal font-semibold">{vehicle.name}</li>
        </ol>
      </nav>

      <div className="grid grid-cols-1 lg:grid-cols-12 gap-8">
        <div className="lg:col-span-8 space-y-8">
          <div className="card p-4">
            <div className="grid grid-cols-1 md:grid-cols-12 gap-4">
              <div className="md:col-span-9 relative h-80 rounded-xl overflow-hidden bg-gray-100">
                <Image src={galleryImages[0]} alt={vehicle.name} fill className="object-cover" sizes="(max-width:768px) 100vw, 66vw" />
              </div>
              <div className="md:col-span-3 space-y-3">
                {galleryImages.map((image, index) => (
                  <div key={index} className="relative h-24 rounded-lg overflow-hidden bg-gray-50">
                    <Image src={image} alt={`Thumbnail ${index}`} fill className="object-cover" sizes="150px" />
                    {index === 2 && (
                      <div className="absolute inset-0 bg-black/40 text-white flex items-center justify-center text-sm font-semibold">
                        360 deg View
                      </div>
                    )}
                  </div>
                ))}
              </div>
            </div>
          </div>

          <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
            <div>
              <p className="text-sm uppercase tracking-[0.3em] text-gray-500">
                {vehicle.brand} | {vehicle.segment}
              </p>
              <h1 className="text-4xl font-bold text-charcoal">{vehicle.name}</h1>
              <p className="text-2xl text-blue font-semibold">
                {formatPriceRange(vehicle.price_min, vehicle.price_max, vehicle.currency)}
              </p>
            </div>
            <div className="flex flex-wrap gap-3">
              {['Add to Compare', 'Get Offers', 'Book Test Drive', 'Contact Seller'].map(action => (
                <button key={action} type="button" className="btn-secondary whitespace-nowrap">
                  {action}
                </button>
              ))}
            </div>
          </div>

          <VehicleDetailTabs vehicle={vehicle} listings={listings} serviceHistory={serviceHistory} />
        </div>

        <aside className="lg:col-span-4 space-y-6">
          <div className="card p-5 space-y-4">
            <p className="text-sm text-gray-500">Ready to own?</p>
            <button type="button" className="btn-primary w-full">
              Reserve Vehicle
            </button>
            <button type="button" className="btn-secondary w-full">
              Download Brochure
            </button>
            <div className="text-sm text-gray-500">
              Verified listings: {listings.filter(listing => listing.verified).length}/{listings.length}
            </div>
          </div>

          <div className="card p-5 space-y-3">
            <h3 className="text-lg font-semibold">Seller Insights</h3>
            {listings.map(listing => (
              <div key={listing.id} className="text-sm text-gray-600 border-b pb-3">
                <p className="font-semibold text-gray-800">Listing #{listing.id}</p>
                <p>
                  {listing.owner_type} | {listing.city}
                </p>
                <p>
                  {listing.year} • {listing.km_driven.toLocaleString()} km • {listing.condition}
                </p>
              </div>
            ))}
          </div>
        </aside>
      </div>

      <section className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="card p-4">
          <p className="text-sm text-gray-500 uppercase tracking-[0.3em]">AI Insight</p>
          <p className="text-lg font-semibold">{aiInsight?.message || "This car's resale value is 22% higher..."}</p>
          <p className="text-sm text-gray-500 mt-2">
            Predicted Fair Value: Rs {aiInsight?.fairValue?.toLocaleString('en-IN')} (+/- 3%)
          </p>
        </div>
        <div className="card p-4">
          <p className="text-sm text-gray-500 uppercase tracking-[0.3em]">Ownership Forecast</p>
          <p className="text-lg font-semibold">Confidence {Math.round((aiInsight?.confidence || 0.82) * 100)}%</p>
          <p className="text-sm text-gray-500 mt-2">Maintenance prediction stays under segment average for 5 years.</p>
        </div>
        <div className="card p-4">
          <p className="text-sm text-gray-500 uppercase tracking-[0.3em]">Service Score</p>
          <p className="text-lg font-semibold">
            Avg Service Rating:{' '}
            {listings.length
              ? (listings.reduce((acc, listing) => acc + (listing.service_score || 0), 0) / listings.length).toFixed(1)
              : '—'}
          </p>
          <p className="text-sm text-gray-500 mt-2">Documents ready: {listings.flatMap(listing => listing.documents).length}</p>
        </div>
      </section>

      <section>
        <div className="flex items-center justify-between mb-4">
          <div>
            <p className="text-xs uppercase tracking-[0.3em] text-gray-500">Related Section</p>
            <h2 className="text-2xl font-bold">Similar Vehicles</h2>
          </div>
          <Link href="/compare" className="text-blue text-sm">
            Compare -{'>'}
          </Link>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {related.map(vehicle => (
            <VehicleCard key={vehicle.id} vehicle={vehicle} />
          ))}
        </div>
      </section>
    </div>
  );
}
