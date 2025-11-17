'use client';

import { useEffect, useMemo, useState } from 'react';
import Link from 'next/link';
import { API_BASE_URL } from '@/lib/utils';
import { ForumPost } from '@/types';

const categories = [
  { id: 'all', label: 'All Topics' },
  { id: 'general', label: 'General' },
  { id: 'technical', label: 'Technical' },
  { id: 'buying', label: 'Buying Advice' },
  { id: 'ev', label: 'EV Owners' }
];

export default function ForumPage() {
  const [activeCategory, setActiveCategory] = useState('all');
  const [posts, setPosts] = useState<ForumPost[]>([]);
  const [search, setSearch] = useState('');

  useEffect(() => {
    fetch(`${API_BASE_URL}/api/forum/posts`)
      .then(response => response.json())
      .then(data => setPosts(data));
  }, []);

  const filteredPosts = useMemo(() => {
    return posts.filter(post => {
      const categoryMatch = activeCategory === 'all' || post.category === activeCategory;
      const searchMatch = post.title.toLowerCase().includes(search.toLowerCase());
      return categoryMatch && searchMatch;
    });
  }, [posts, activeCategory, search]);

  return (
    <div className="container mx-auto px-4 py-10 space-y-8">
      <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <div>
          <p className="text-xs uppercase tracking-[0.3em] text-gray-500">Page 9</p>
          <h1 className="text-3xl font-bold text-charcoal">AutoSocial Community</h1>
          <p className="text-gray-500">Discuss ownership, tech, policy and EV experiences with 12k+ enthusiasts.</p>
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

      <div className="flex flex-col md:flex-row gap-6">
        <div className="md:w-2/3 space-y-4">
          <div className="flex items-center gap-3">
            <input
              type="search"
              className="flex-1 border rounded-md px-3 py-2"
              placeholder="Search topics..."
              value={search}
              onChange={event => setSearch(event.target.value)}
            />
          </div>

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
        <aside className="md:w-1/3 space-y-4">
          <div className="card p-4">
            <h3 className="font-semibold mb-3">Hot Threads</h3>
            <ul className="text-sm text-gray-600 space-y-2">
              {posts.slice(0, 3).map(post => (
                <li key={post.id}>
                  <Link href={`/forum/${post.id}`} className="text-blue">
                    {post.title}
                  </Link>
                </li>
              ))}
            </ul>
          </div>
          <div className="card p-4">
            <h3 className="font-semibold mb-3">Top Contributors</h3>
            <ul className="text-sm text-gray-600 space-y-2">
              {['Rohan', 'Priya', 'EV_Guru'].map(user => (
                <li key={user}>{user}</li>
              ))}
            </ul>
          </div>
        </aside>
      </div>
    </div>
  );
}
