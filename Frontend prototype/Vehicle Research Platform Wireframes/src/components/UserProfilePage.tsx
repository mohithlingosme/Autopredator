import React from 'react';
import { User, Heart, GitCompare, Calendar, MessageSquare, Settings, Bell } from 'lucide-react';
import { Card } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Tabs, TabsContent, TabsList, TabsTrigger } from './ui/tabs';
import { VehicleCard } from './VehicleCard';
import { UsedVehicleCard } from './UsedVehicleCard';
import { vehicles } from '../data/vehicles';
import { usedVehicles } from '../data/usedVehicles';

interface UserProfilePageProps {
  onNavigate: (page: string, vehicleId?: string) => void;
}

export function UserProfilePage({ onNavigate }: UserProfilePageProps) {
  const savedNewVehicles = vehicles.slice(0, 3);
  const savedUsedVehicles = usedVehicles.slice(0, 3);
  const compareList = vehicles.slice(0, 2);

  const bookings = [
    {
      id: 1,
      type: 'Test Drive',
      vehicle: 'Hyundai Creta SX',
      date: '2025-11-05',
      time: '10:00 AM',
      location: 'Delhi Showroom',
      status: 'Confirmed'
    },
    {
      id: 2,
      type: 'Service',
      vehicle: 'Honda City ZX',
      date: '2025-11-08',
      time: '2:00 PM',
      location: 'AutoCare Center',
      status: 'Pending'
    }
  ];

  const forumPosts = [
    {
      id: 1,
      title: 'Best SUV under 15 lakhs?',
      replies: 23,
      views: 890,
      date: '2025-10-28'
    },
    {
      id: 2,
      title: 'EV charging infrastructure in Bangalore',
      replies: 45,
      views: 1560,
      date: '2025-10-25'
    }
  ];

  const notifications = [
    { id: 1, text: 'New price drop alert: Hyundai Creta', time: '2 hours ago', unread: true },
    { id: 2, text: 'Your test drive is confirmed for tomorrow', time: '5 hours ago', unread: true },
    { id: 3, text: 'Someone replied to your forum post', time: '1 day ago', unread: false },
    { id: 4, text: 'New EMI offer available', time: '2 days ago', unread: false }
  ];

  return (
    <div>
      {/* Profile Header */}
      <div className="bg-gradient-to-r from-[#2C2C2C] to-[#007BFF] text-white py-12">
        <div className="max-w-7xl mx-auto px-6">
          <div className="flex items-start justify-between">
            <div className="flex items-center gap-6">
              <div className="w-24 h-24 bg-white rounded-full flex items-center justify-center">
                <User className="w-12 h-12 text-[#007BFF]" />
              </div>
              <div>
                <h1 className="mb-2">Rohit Kumar</h1>
                <p className="text-gray-200 mb-2">rohit.kumar@example.com</p>
                <div className="flex items-center gap-4">
                  <Badge variant="secondary">Premium Member</Badge>
                  <span className="text-sm">Member since Oct 2024</span>
                </div>
              </div>
            </div>
            <Button variant="secondary" className="gap-2">
              <Settings className="w-4 h-4" />
              Edit Profile
            </Button>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-6 py-8">
        <div className="grid grid-cols-1 lg:grid-cols-4 gap-8">
          {/* Main Content */}
          <div className="lg:col-span-3">
            <Tabs defaultValue="saved">
              <TabsList className="w-full justify-start mb-6">
                <TabsTrigger value="saved" className="gap-2">
                  <Heart className="w-4 h-4" />
                  Saved Vehicles
                </TabsTrigger>
                <TabsTrigger value="compare" className="gap-2">
                  <GitCompare className="w-4 h-4" />
                  Compare List
                </TabsTrigger>
                <TabsTrigger value="bookings" className="gap-2">
                  <Calendar className="w-4 h-4" />
                  My Bookings
                </TabsTrigger>
                <TabsTrigger value="forum" className="gap-2">
                  <MessageSquare className="w-4 h-4" />
                  Forum Activity
                </TabsTrigger>
              </TabsList>

              {/* Saved Vehicles Tab */}
              <TabsContent value="saved">
                <div className="space-y-8">
                  <div>
                    <div className="flex items-center justify-between mb-4">
                      <h2>Saved New Vehicles ({savedNewVehicles.length})</h2>
                      <Button variant="outline" size="sm" onClick={() => onNavigate('listing')}>
                        Browse More
                      </Button>
                    </div>
                    <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                      {savedNewVehicles.map((vehicle) => (
                        <VehicleCard
                          key={vehicle.id}
                          vehicle={vehicle}
                          onView={(id) => onNavigate('detail', id)}
                          onCompare={(id) => onNavigate('compare')}
                          onFavorite={(id) => console.log('Remove favorite:', id)}
                          isFavorite={true}
                        />
                      ))}
                    </div>
                  </div>

                  <div>
                    <div className="flex items-center justify-between mb-4">
                      <h2>Saved Used Vehicles ({savedUsedVehicles.length})</h2>
                      <Button variant="outline" size="sm" onClick={() => onNavigate('used-listing')}>
                        Browse More
                      </Button>
                    </div>
                    <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                      {savedUsedVehicles.map((vehicle) => (
                        <UsedVehicleCard
                          key={vehicle.id}
                          vehicle={vehicle}
                          onView={(id) => onNavigate('used-detail', id)}
                        />
                      ))}
                    </div>
                  </div>
                </div>
              </TabsContent>

              {/* Compare List Tab */}
              <TabsContent value="compare">
                <div className="mb-4">
                  <h2 className="mb-2">Vehicles in Compare List ({compareList.length})</h2>
                  <p className="text-gray-600">You can compare up to 4 vehicles at a time</p>
                </div>
                <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-6">
                  {compareList.map((vehicle) => (
                    <VehicleCard
                      key={vehicle.id}
                      vehicle={vehicle}
                      onView={(id) => onNavigate('detail', id)}
                      onCompare={(id) => console.log('Remove from compare:', id)}
                      isComparing={true}
                    />
                  ))}
                </div>
                <Button className="w-full" onClick={() => onNavigate('compare')}>
                  Go to Comparison Page
                </Button>
              </TabsContent>

              {/* Bookings Tab */}
              <TabsContent value="bookings">
                <h2 className="mb-6">My Bookings</h2>
                <div className="space-y-4">
                  {bookings.map((booking) => (
                    <Card key={booking.id} className="p-6">
                      <div className="flex items-start justify-between mb-4">
                        <div>
                          <Badge className="mb-2">{booking.type}</Badge>
                          <h3 className="mb-1">{booking.vehicle}</h3>
                          <div className="text-sm text-gray-600">
                            {booking.date} at {booking.time}
                          </div>
                          <div className="text-sm text-gray-600">{booking.location}</div>
                        </div>
                        <Badge 
                          className={booking.status === 'Confirmed' ? 'bg-[#39FF14] text-[#2C2C2C]' : 'bg-orange-500'}
                        >
                          {booking.status}
                        </Badge>
                      </div>
                      <div className="flex gap-2">
                        <Button variant="outline" size="sm">View Details</Button>
                        <Button variant="outline" size="sm">Reschedule</Button>
                        <Button variant="outline" size="sm" className="text-red-600">Cancel</Button>
                      </div>
                    </Card>
                  ))}
                </div>
              </TabsContent>

              {/* Forum Activity Tab */}
              <TabsContent value="forum">
                <h2 className="mb-6">My Forum Posts</h2>
                <div className="space-y-4">
                  {forumPosts.map((post) => (
                    <Card key={post.id} className="p-6 hover:shadow-lg transition-shadow cursor-pointer">
                      <h3 className="mb-2">{post.title}</h3>
                      <div className="flex items-center gap-4 text-sm text-gray-600">
                        <div className="flex items-center gap-1">
                          <MessageSquare className="w-4 h-4" />
                          <span>{post.replies} replies</span>
                        </div>
                        <div className="flex items-center gap-1">
                          <span>{post.views} views</span>
                        </div>
                        <div className="flex items-center gap-1">
                          <Calendar className="w-4 h-4" />
                          <span>{post.date}</span>
                        </div>
                      </div>
                    </Card>
                  ))}
                </div>
              </TabsContent>
            </Tabs>
          </div>

          {/* Sidebar */}
          <div className="space-y-6">
            {/* Quick Stats */}
            <Card className="p-6">
              <h3 className="mb-4">Account Stats</h3>
              <div className="space-y-3">
                <div className="flex justify-between py-2 border-b">
                  <span className="text-gray-600">Saved Vehicles</span>
                  <span className="text-[#007BFF]">6</span>
                </div>
                <div className="flex justify-between py-2 border-b">
                  <span className="text-gray-600">Compare List</span>
                  <span className="text-[#007BFF]">2</span>
                </div>
                <div className="flex justify-between py-2 border-b">
                  <span className="text-gray-600">Forum Posts</span>
                  <span className="text-[#007BFF]">12</span>
                </div>
                <div className="flex justify-between py-2">
                  <span className="text-gray-600">Bookings</span>
                  <span className="text-[#007BFF]">2</span>
                </div>
              </div>
            </Card>

            {/* Notifications */}
            <Card className="p-6">
              <div className="flex items-center justify-between mb-4">
                <div className="flex items-center gap-2">
                  <Bell className="w-5 h-5 text-[#007BFF]" />
                  <h3>Notifications</h3>
                </div>
                <Badge className="bg-[#007BFF]">2</Badge>
              </div>
              <div className="space-y-3">
                {notifications.map((notification) => (
                  <div 
                    key={notification.id} 
                    className={`p-3 rounded text-sm ${
                      notification.unread ? 'bg-blue-50' : 'bg-gray-50'
                    }`}
                  >
                    <div className="mb-1">{notification.text}</div>
                    <div className="text-xs text-gray-600">{notification.time}</div>
                  </div>
                ))}
              </div>
              <Button variant="outline" size="sm" className="w-full mt-4">
                View All
              </Button>
            </Card>

            {/* Premium Upgrade */}
            <Card className="p-6 bg-gradient-to-br from-[#007BFF] to-[#2C2C2C] text-white">
              <h3 className="mb-2">Upgrade to Premium</h3>
              <p className="text-sm mb-4 text-gray-200">
                Get exclusive deals, priority support, and advanced features
              </p>
              <Button variant="secondary" className="w-full">
                Upgrade Now
              </Button>
            </Card>
          </div>
        </div>
      </div>
    </div>
  );
}
