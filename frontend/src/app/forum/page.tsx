'use client';

import { useMemo, useState } from 'react';
import Link from 'next/link';

import { ForumPost } from '@/types';

const categories = [
  { id: 'all', label: 'All Topics' },
  { id: 'general', label: 'General' },
  { id: 'technical', label: 'Technical' },
  { id: 'buying', label: 'Buying Advice' },
  { id: 'ev', label: 'EV Owners' }
];

const threads: ForumPost[] = [
  {
    id: 101,
    title: 'Operationalizing predictive service schedules',
    content: 'How are you turning the AI maintenance alerts into action for drivers on the road?',
    category: 'technical',
    views: 1245,
    tags: ['maintenance', 'ai'],
    created_at: new Date().toISOString()
  },
  {
    id: 102,
    title: 'Financing a 50 vehicle expansion',
    content: 'Need ideas for leasing and insurance deals that cover hybrid pickups.',
    category: 'buying',
    views: 892,
    tags: ['finance', 'fleet'],
    created_at: new Date().toISOString()
  },
  {
    id: 103,
    title: 'EV adoption checklist for rural refuels',
    content: 'Sharing lessons learned from first 20 EV vans in tier-2 geographies.',
    category: 'ev',
    views: 638,
    tags: ['ev', 'operations'],
    created_at: new Date().toISOString()
  }
];

export default function ForumPage() {
  const [activeCategory, setActiveCategory] = useState('all');
  const [search, setSearch] = useState('');

  const filteredPosts = useMemo(() => {
    return threads.filter(post => {
      const matchesCategory = activeCategory === 'all' || post.category === activeCategory;
      const matchesSearch = post.title.toLowerCase().includes(search.toLowerCase());
      return matchesCategory && matchesSearch;
    });
  }, [activeCategory, search]);

  return (
    <div className="container mx-auto px-4 py-10 space-y-8">
      <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <div>
          <p className="text-xs uppercase tracking-[0.3em] text-gray-500">Community</p>
          <h1 className="text-3xl font-bold text-charcoal">AutoSocial Community</h1>
          <p className="text-gray-500">Share policies, tech, and maintenance wins with fellow operators.</p>
        </div>
        <button type="button" className="btn-primary">
          Start New Discussion
        </button>
      </div>

      <div className="card p-4 flex flex-wrap gap-3">
        {categories.map(category => (
          <button
            key={category.id}
            type="button"
            onClick={() => setActiveCategory(category.id)}
            className={`px-4 py-2 rounded-lg ${activeCategory === category.id ? 'bg-blue text-white' : 'bg-gray-100 text-gray-700'}`}
          >
            {category.label}
          </button>
        ))}
      </div>

      <div className="flex items-center gap-3">
        <input
          type="search"
          className="flex-1 border rounded-md px-3 py-2"
          placeholder="Search community threads..."
          value={search}
          onChange={event => setSearch(event.target.value)}
        />
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {filteredPosts.map(post => (
          <div key={post.id} className="card p-5 space-y-2">
            <div className="flex items-center gap-2 text-xs uppercase tracking-[0.3em] text-gray-400">
              {post.category} | {post.tags?.join(', ')}
            </div>
            <Link href={`/forum/${post.id}`} className="text-xl font-semibold">
              {post.title}
            </Link>
            <p className="text-sm text-gray-600 line-clamp-2">{post.content}</p>
            <div className="text-xs text-gray-500">
              Views: {post.views} | {new Date(post.created_at).toLocaleDateString()}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
