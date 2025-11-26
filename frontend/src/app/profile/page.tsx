'use client';

import { useEffect, useState } from 'react';

import VehicleCard from '@/components/VehicleCard';
import apiClient from '@/lib/api';
import { ForumPost, Vehicle } from '@/types';

const communityPosts: ForumPost[] = [
  {
    id: 1,
    title: 'Planning service schedules for electric fleets',
    content: 'Share insights on balancing regenerative braking with predictive maintenance.',
    category: 'technical',
    views: 780,
    tags: ['maintenance', 'EV'],
    created_at: new Date().toISOString(),
  },
  {
    id: 2,
    title: 'Scaling fleet coverage across tier-2 cities',
    content: 'How do you keep drivers informed while keeping compliance in check?',
    category: 'general',
    views: 430,
    tags: ['operations', 'fleet'],
    created_at: new Date().toISOString()
  },
  {
    id: 3,
    title: 'Repair partner recommendations',
    content: 'Looking for vetted service partners for payload trucks in Maharashtra.',
    category: 'buying',
    views: 510,
    tags: ['maintenance', 'repair'],
    created_at: new Date().toISOString()
  }
];

const tabs = ['My Vehicles', 'Saved Cars', 'My Bookings', 'My Forum Posts', 'Settings'];

export default function ProfilePage() {
  const [activeTab, setActiveTab] = useState('Saved Cars');
  const [vehicles, setVehicles] = useState<Vehicle[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let cancelled = false;

    const loadVehicles = async () => {
      try {
        const response = await apiClient.get<Vehicle[]>('/vehicles/');
        if (!cancelled) {
          setVehicles(response.data);
        }
      } finally {
        if (!cancelled) {
          setLoading(false);
        }
      }
    };

    loadVehicles();
    return () => {
      cancelled = true;
    };
  }, []);

  return (
    <div className="container mx-auto px-4 py-10 space-y-8">
      <div className="card p-6 flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <div>
          <p className="text-xs uppercase tracking-[0.3em] text-gray-500">My profile</p>
          <h1 className="text-3xl font-bold text-charcoal">My Garage & Activity</h1>
          <p className="text-sm text-gray-500">
            Track owned vehicles, saved insight summaries, and community discussions.
          </p>
        </div>
        <button type="button" className="btn-primary">
          Upgrade membership
        </button>
      </div>

      <div className="flex flex-wrap gap-3 border-b">
        {tabs.map(tab => (
          <button
            key={tab}
            type="button"
            onClick={() => setActiveTab(tab)}
            className={`px-4 py-2 font-semibold ${activeTab === tab ? 'border-b-2 border-blue text-blue' : 'text-gray-500'}`}
          >
            {tab}
          </button>
        ))}
      </div>

      {activeTab === 'Saved Cars' && (
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {loading ? (
            <p className="text-gray-500 col-span-full text-center">Loading vehicles…</p>
          ) : vehicles.length ? (
            vehicles.slice(0, 6).map(vehicle => <VehicleCard key={vehicle.id} vehicle={vehicle} />)
          ) : (
            <div className="rounded-2xl border border-dashed border-gray-300 bg-white/70 p-8 text-center text-gray-500 col-span-full">
              Add vehicles to your profile to see them here.
            </div>
          )}
        </div>
      )}

      {activeTab === 'My Forum Posts' && (
        <div className="space-y-4">
          {communityPosts.map(post => (
            <div key={post.id} className="card p-4">
              <h3 className="text-lg font-semibold">{post.title}</h3>
              <p className="text-sm text-gray-600 line-clamp-2">{post.content}</p>
              <div className="text-xs text-gray-500 mt-2">Views {post.views}</div>
            </div>
          ))}
        </div>
      )}

      {activeTab === 'My Vehicles' && (
        <div className="card p-6 text-sm text-gray-600">
          We work best when you add your vehicles to monitor maintenance, compliance, and AI predictions.
        </div>
      )}
    </div>
  );
}
