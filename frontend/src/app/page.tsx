import Link from 'next/link';
import VehicleCard from '@/components/VehicleCard';
import { API_BASE_URL, formatPriceRange } from '@/lib/utils';
import { AiInsight, BlogPost, ForumPost, Vehicle } from '@/types';

async function getData() {
  const [newVehicles, usedVehicles, blogs, forumPosts, aiInsight] = await Promise.all([
    fetch(`${API_BASE_URL}/api/vehicles?type=new&limit=8`, { cache: 'no-store' }).then(res => res.json()),
    fetch(`${API_BASE_URL}/api/vehicles/used`, { cache: 'no-store' }).then(res => res.json()),
    fetch(`${API_BASE_URL}/api/blogs?limit=2`, { cache: 'no-store' }).then(res => res.json()),
    fetch(`${API_BASE_URL}/api/forum/posts?limit=2`, { cache: 'no-store' }).then(res => res.json()),
    fetch(`${API_BASE_URL}/api/ai/predict-resale`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ vehicleId: 3 }),
      cache: 'no-store'
    }).then(res => res.json())
  ]);

  return {
    newVehicles: newVehicles as Vehicle[],
    usedVehicles,
    blogs: blogs as BlogPost[],
    forumPosts: forumPosts as ForumPost[],
    aiInsight: aiInsight as AiInsight
  };
}

export default async function Home() {
  const { newVehicles = [], usedVehicles = [], blogs = [], forumPosts = [], aiInsight } = await getData();
  const usedShowcase = usedVehicles
    .map((entry: { vehicle: Vehicle; listing: { verified: boolean; km_driven?: number; year?: number } }) => ({
      vehicle: entry.vehicle,
      verified: entry.listing?.verified,
      meta: [entry.listing?.year ? `${entry.listing.year}` : undefined, entry.listing?.km_driven ? `${entry.listing.km_driven} km` : undefined].filter(
        Boolean
      ) as string[]
    }))
    .slice(0, 4);

  return (
    <div className="container mx-auto px-4 py-10 space-y-14">
      <section className="card bg-gradient-to-r from-charcoal to-blue text-white p-10">
        <div className="grid grid-cols-1 md:grid-cols-12 gap-8 items-center">
          <div className="md:col-span-7 space-y-6">
            <p className="text-sm uppercase tracking-[0.4em] text-white/70">Autopredator Vehicle Research</p>
            <h1 className="text-4xl md:text-5xl font-bold">Find. Compare. Own Smarter.</h1>
            <p className="text-lg text-white/80">
              Route seamlessly between new vehicle research, used deals, and ownership services powered by AI insights.
            </p>
            <div className="flex flex-wrap gap-4">
              <Link href="/new-vehicles" className="btn-primary px-6 py-3 text-base">
                Research New
              </Link>
              <Link href="/used-vehicles" className="btn-secondary px-6 py-3 text-base">
                Buy Used
              </Link>
              <Link href="/services" className="btn-secondary px-6 py-3 text-base border border-white/30">
                Explore Services
              </Link>
            </div>
          </div>
          <div className="md:col-span-5 bg-white/10 rounded-2xl p-6 text-white space-y-3">
            <p className="text-xs uppercase text-white/60">Trending Watchlist</p>
            {newVehicles.slice(0, 3).map(vehicle => (
              <div key={vehicle.id} className="flex items-center justify-between py-2 border-b border-white/10">
                <div>
                  <p className="font-semibold">{vehicle.name}</p>
                  <p className="text-xs text-white/70">{vehicle.fuel_type}</p>
                </div>
                <p className="font-semibold">{formatPriceRange(vehicle.price_min, vehicle.price_max, vehicle.currency)}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      <section>
        <div className="flex items-center justify-between mb-4">
          <div>
            <p className="text-xs uppercase tracking-[0.3em] text-gray-500">Section 1</p>
            <h2 className="text-2xl font-bold">Trending Vehicles</h2>
          </div>
          <Link href="/new-vehicles" className="text-blue text-sm">
            View all -{'>'}
          </Link>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-4 gap-6">
          {newVehicles.slice(0, 4).map(vehicle => (
            <VehicleCard key={vehicle.id} vehicle={vehicle} />
          ))}
        </div>
      </section>

      <section>
        <div className="flex items-center justify-between mb-4">
          <div>
            <p className="text-xs uppercase tracking-[0.3em] text-gray-500">Section 2</p>
            <h2 className="text-2xl font-bold">Used Vehicles - Top Deals</h2>
          </div>
          <Link href="/used-vehicles" className="text-blue text-sm">
            Browse AutoUsed -{'>'}
          </Link>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {usedShowcase.map(item =>
            item.vehicle ? (
              <VehicleCard key={item.vehicle.id} vehicle={item.vehicle} verified={item.verified} meta={item.meta} />
            ) : null
          )}
        </div>
      </section>

      <section>
        <div className="flex items-center justify-between mb-4">
          <div>
            <p className="text-xs uppercase tracking-[0.3em] text-gray-500">Section 3</p>
            <h2 className="text-2xl font-bold">Explore by Category</h2>
          </div>
        </div>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          {[
            { label: 'Cars', href: '/category/cars' },
            { label: 'Bikes', href: '/category/bikes' },
            { label: 'EVs', href: '/category/evs' },
            { label: 'Commercial', href: '/category/commercial' }
          ].map(category => (
            <Link key={category.href} href={category.href} className="card px-6 py-10 text-center hover:bg-blue/5">
              <p className="text-lg font-semibold">{category.label}</p>
              <p className="text-sm text-gray-500 mt-2">View research</p>
            </Link>
          ))}
        </div>
      </section>

      <section>
        <div className="flex items-center justify-between mb-4">
          <div>
            <p className="text-xs uppercase tracking-[0.3em] text-gray-500">Section 4</p>
            <h2 className="text-2xl font-bold">Blog & Forum Highlights</h2>
          </div>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {blogs.map(blog => (
            <Link key={blog.id} href={`/blog/${blog.id}`} className="card p-6 hover:-translate-y-1 transition-transform">
              <p className="text-xs uppercase tracking-[0.3em] text-gray-400">Blog</p>
              <h3 className="text-xl font-semibold mt-2">{blog.title}</h3>
              <p className="text-gray-600 mt-2 line-clamp-3">{blog.summary}</p>
              <span className="text-blue mt-4 inline-flex items-center text-sm">Read More -{'>'}</span>
            </Link>
          ))}
          {forumPosts.map(post => (
            <Link key={post.id} href={`/forum/${post.id}`} className="card p-6 hover:-translate-y-1 transition-transform">
              <p className="text-xs uppercase tracking-[0.3em] text-gray-400">Forum</p>
              <h3 className="text-xl font-semibold mt-2">{post.title}</h3>
              <p className="text-gray-600 mt-2 line-clamp-3">{post.content}</p>
              <span className="text-blue mt-4 inline-flex items-center text-sm">Join Discussion -{'>'}</span>
            </Link>
          ))}
        </div>
      </section>

      <section className="card bg-neon-green/95 text-charcoal p-6">
        <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
          <div>
            <p className="text-xs uppercase tracking-[0.4em] text-charcoal/70">Section 5</p>
            <h3 className="text-2xl font-semibold">AI Recommendation</h3>
          </div>
          <p className="text-lg font-medium">
            {aiInsight?.message || "AI suggests Toyota Fortuner based on your activity with 15% higher resale."}
          </p>
          <Link href="/insights" className="btn-secondary bg-white text-charcoal px-5 py-3">
            View AI Insights
          </Link>
        </div>
      </section>
    </div>
  );
}
