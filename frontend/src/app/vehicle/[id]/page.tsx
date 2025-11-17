import VehicleDetailFetcher from '@/components/VehicleDetailFetcher';

export default function VehicleDetailPage({ params }: { params: { id: string } }) {
  return (
    <section className="min-h-screen bg-gray-50 py-12">
      <div className="container mx-auto px-4">
        <VehicleDetailFetcher vehicleId={params.id} />
      </div>
    </section>
  );
}
