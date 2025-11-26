'use client';

import Image from 'next/image';
import { useMemo, useState } from 'react';

interface MarketplaceItem {
  id: number;
  title: string;
  price: number;
  currency: string;
  category: string;
  type: 'vehicle' | 'part';
  image_url?: string;
  history?: string;
  rating?: number;
  reviews?: number;
  location?: string;
}

interface MarketplaceGridProps {
  items: MarketplaceItem[];
}

export default function MarketplaceGrid({ items }: MarketplaceGridProps) {
  const [search, setSearch] = useState('');
  const [category, setCategory] = useState('all');
  const [minPrice, setMinPrice] = useState('');
  const [maxPrice, setMaxPrice] = useState('');
  const [notification, setNotification] = useState<string | null>(null);

  const categories = useMemo(() => {
    const unique = Array.from(new Set(items.map(item => item.category)));
    return ['all', ...unique];
  }, [items]);

  const filtered = useMemo(() => {
    return items.filter(item => {
      const matchesSearch = item.title.toLowerCase().includes(search.toLowerCase());
      const matchesCategory = category === 'all' || item.category === category;
      const matchesMin = !minPrice || item.price >= Number(minPrice);
      const matchesMax = !maxPrice || item.price <= Number(maxPrice);
      return matchesSearch && matchesCategory && matchesMin && matchesMax;
    });
  }, [items, search, category, minPrice, maxPrice]);

  const handleBuy = (item: MarketplaceItem) => {
    setNotification(`Payment integration coming soon. "${item.title}" is reserved for you.`);
  };

  return (
    <div className="space-y-6">
      <header className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
        <div>
          <p className="text-xs uppercase tracking-[0.4em] text-gray-400">Marketplace</p>
          <h1 className="text-3xl font-semibold text-charcoal">Buy vehicles & parts</h1>
        </div>
        <div className="flex flex-wrap gap-3">
          <input
            type="search"
            value={search}
            onChange={event => setSearch(event.target.value)}
            placeholder="Search by model, part, or brand"
            className="rounded-full border border-gray-200 px-4 py-2 text-sm outline-none focus:border-charcoal"
          />
          <select
            value={category}
            onChange={event => setCategory(event.target.value)}
            className="rounded-full border border-gray-200 px-4 py-2 text-sm"
          >
            {categories.map(cat => (
              <option key={cat} value={cat}>
                {cat === 'all' ? 'All categories' : cat}
              </option>
            ))}
          </select>
        </div>
      </header>

      <div className="flex flex-wrap gap-3">
        <input
          type="number"
          min={0}
          value={minPrice}
          onChange={event => setMinPrice(event.target.value)}
          placeholder="Min price"
          className="rounded-full border border-gray-200 px-4 py-2 text-sm outline-none focus:border-charcoal flex-1"
        />
        <input
          type="number"
          min={0}
          value={maxPrice}
          onChange={event => setMaxPrice(event.target.value)}
          placeholder="Max price"
          className="rounded-full border border-gray-200 px-4 py-2 text-sm outline-none focus:border-charcoal flex-1"
        />
      </div>

      {notification && <p className="text-sm text-green-600">{notification}</p>}

      <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
        {filtered.map(item => (
          <div key={item.id} className="rounded-3xl border border-gray-200 bg-white p-5 shadow-sm flex flex-col">
            <div className="relative h-48 w-full overflow-hidden rounded-2xl bg-gray-100">
              <Image
                src={item.image_url || 'https://via.placeholder.com/500x300'}
                alt={item.title}
                fill
                className="object-cover"
                sizes="(max-width:768px) 100vw, 50vw"
                unoptimized
              />
            </div>
            <div className="mt-4 space-y-2">
              <div className="flex items-center justify-between">
                <h3 className="text-lg font-semibold text-charcoal">{item.title}</h3>
                <span className="text-sm text-gray-500">{item.rating?.toFixed(1) ?? '★'} ★</span>
              </div>
              <p className="text-sm text-gray-500 line-clamp-2">
                {item.history ?? 'Verified stock · Document checks complete.'}
              </p>
              <p className="text-sm text-gray-500">{item.reviews ? `${item.reviews} reviews` : 'No reviews yet'}</p>
              <div className="flex items-center justify-between">
                <span className="text-blue text-lg font-bold">
                  {item.currency} {item.price.toLocaleString()}
                </span>
                <button
                  type="button"
                  onClick={() => handleBuy(item)}
                  className="btn-secondary rounded-full px-4 py-2 text-xs"
                >
                  Buy Now
                </button>
              </div>
              <p className="text-xs text-gray-400 uppercase tracking-[0.3em]">
                {item.category} · {item.type}
              </p>
            </div>
          </div>
        ))}
        {filtered.length === 0 && (
          <div className="col-span-full rounded-3xl border border-dashed border-gray-300 p-8 text-center text-gray-500">
            No marketplace items match your filters yet. Try adjusting your search.
          </div>
        )}
      </div>
    </div>
  );
}
