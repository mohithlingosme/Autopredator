'use client';

import { useEffect, useState } from 'react';
import VehicleCard from '@/components/VehicleCard';
import { API_BASE_URL } from '@/lib/utils';
import { Vehicle, ForumPost } from '@/types';

const tabs = ['My Vehicles', 'Saved Cars', 'My Bookings', 'My Forum Posts', 'Settings'];

export default function ProfilePage() {
  const [activeTab, setActiveTab] = useState('Saved Cars');
  const [vehicles, setVehicles] = useState<Vehicle[]>([]);
  const [posts, setPosts] = useState<ForumPost[]>([]);

  useEffect(() => {
    fetch(`${API_BASE_URL}/api/vehicles?limit=6`)
      .then(response => response.json())
      .then(data => setVehicles(data));
    fetch(`${API_BASE_URL}/api/forum/posts`)
      .then(response => response.json())
      .then(data => setPosts(data));
  }, []);

  return (
    <div className="container mx-auto px-4 py-10 space-y-8">
      <div className="card p-6 flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <div>
          <p className="text-xs uppercase tracking-[0.3em] text-gray-500">Page 11</p>
          <h1 className="text-3xl font-bold text-charcoal">My Garage & Saved Items</h1>
          <p className="text-sm text-gray-500">Manage your vehicles, bookings, savings and forum activity.</p>
        </div>
        <button type="button" className="btn-primary">
          Upgrade Membership
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
          {vehicles.map(vehicle => (
            <VehicleCard key={vehicle.id} vehicle={vehicle} />
          ))}
        </div>
      )}

      {activeTab === 'My Forum Posts' && (
        <div className="space-y-4">
          {posts.slice(0, 5).map(post => (
            <div key={post.id} className="card p-4">
              <h3 className="text-lg font-semibold">{post.title}</h3>
              <p className="text-sm text-gray-600 line-clamp-2">{post.content}</p>
            </div>
          ))}
        </div>
      )}

      {activeTab === 'My Vehicles' && (
        <div className="card p-6 text-sm text-gray-600">
          <p>No vehicles registered. Add your vehicle to track service history and reminders.</p>
        </div>
      )}
    </div>
  );
}
