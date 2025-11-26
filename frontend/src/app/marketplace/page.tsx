'use client';

import { useEffect, useState } from 'react';

import MarketplaceGrid from '@/components/MarketplaceGrid';
import apiClient from '@/lib/api';

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
}

interface ProductResponse {
  id: number;
  name: string;
  category: string;
  description: string;
  price: number;
  image?: string;
}

export default function MarketplacePage() {
  const [items, setItems] = useState<MarketplaceItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;

    const loadItems = async () => {
      try {
        const response = await apiClient.get<ProductResponse[]>('/products/');
        if (cancelled) return;

        setItems(
          response.data.map(product => ({
            id: product.id,
            title: product.name,
            price: product.price,
            currency: 'INR',
            category: product.category,
            type: product.category.toLowerCase().includes('part') ? 'part' : 'vehicle',
            image_url: product.image,
            history: product.description,
            rating: 4.5,
            reviews: 12
          }))
        );
      } catch {
        if (!cancelled) {
          setError('Unable to load marketplace items right now.');
        }
      } finally {
        if (!cancelled) {
          setLoading(false);
        }
      }
    };

    loadItems();
    return () => {
      cancelled = true;
    };
  }, []);

  return (
    <section className="min-h-screen bg-gray-50 py-16">
      <div className="container mx-auto px-4">
        {loading ? (
          <div className="rounded-2xl border border-dashed border-gray-300 bg-white/80 p-8 text-center text-gray-500">
            Fetching marketplace inventory…
          </div>
        ) : error ? (
          <div className="rounded-2xl border border-red-200 bg-white/80 p-8 text-center text-red-600">{error}</div>
        ) : (
          <MarketplaceGrid items={items} />
        )}
      </div>
    </section>
  );
}
