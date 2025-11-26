import React from 'react';
import { Search, Car, Bike, Zap, Truck, TrendingUp, Sparkles, ShoppingCart, Wrench, MessageSquare } from 'lucide-react';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { VehicleCard } from './VehicleCard';
import { UsedVehicleCard } from './UsedVehicleCard';
import { vehicles } from '../data/vehicles';
import { usedVehicles } from '../data/usedVehicles';
import { Card } from './ui/card';

interface HomePageProps {
  onNavigate: (page: string, vehicleId?: string) => void;
}

export function HomePage({ onNavigate }: HomePageProps) {
  const featuredVehicles = vehicles.slice(0, 3);
  const featuredUsedVehicles = usedVehicles.slice(0, 4);

  const categories = [
    { name: 'New Cars', icon: Car, count: '1,200+', page: 'listing' },
    { name: 'Used Cars', icon: ShoppingCart, count: '340+', page: 'used-listing' },
    { name: 'EVs', icon: Zap, count: '180+', page: 'listing' },
    { name: 'Services', icon: Wrench, count: '50+', page: 'services' }
  ];

  return (
    <div>
      {/* Hero Section */}
      <section className="bg-gradient-to-br from-[#2C2C2C] via-[#007BFF] to-[#2C2C2C] text-white py-20">
        <div className="max-w-7xl mx-auto px-6">
          <div className="max-w-3xl mx-auto text-center">
            <h1 className="mb-6">Find. Compare. Own Smarter.</h1>
            <p className="mb-8 text-gray-200">
              Complete vehicle research and ownership platform with AI-powered insights
            </p>

            {/* Search Bar */}
            <div className="bg-white rounded-lg p-2 flex gap-2 mb-6">
              <Input
                type="text"
                placeholder="Search by brand, model, or type..."
                className="flex-1 border-0"
              />
              <Button className="gap-2">
                <Search className="w-4 h-4" />
                Search
              </Button>
            </div>

            {/* CTA Buttons */}
            <div className="flex flex-wrap gap-4 justify-center">
              <Button
                variant="secondary"
                size="lg"
                onClick={() => onNavigate('listing')}
              >
                Research New
              </Button>
              <Button
                variant="secondary"
                size="lg"
                onClick={() => onNavigate('used-listing')}
              >
                Buy Used
              </Button>
              <Button
                variant="outline"
                size="lg"
                className="bg-transparent border-white text-white hover:bg-white hover:text-[#007BFF]"
                onClick={() => onNavigate('services')}
              >
                Explore Services
              </Button>
            </div>
          </div>
        </div>
      </section>

      {/* Trending New Vehicles */}
      <section className="py-16 bg-gray-50">
        <div className="max-w-7xl mx-auto px-6">
          <div className="flex items-center justify-between mb-8">
            <div>
              <h2 className="mb-2">Trending New Vehicles</h2>
              <p className="text-gray-600">Latest launches and popular models</p>
            </div>
            <Button variant="outline" onClick={() => onNavigate('listing')}>
              View All New
            </Button>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {featuredVehicles.map((vehicle) => (
              <VehicleCard
                key={vehicle.id}
                vehicle={vehicle}
                onView={(id) => onNavigate('detail', id)}
                onCompare={(id) => {
                  console.log('Compare:', id);
                  onNavigate('compare');
                }}
                onFavorite={(id) => console.log('Favorite:', id)}
              />
            ))}
          </div>
        </div>
      </section>

      {/* Used Vehicles Showcase */}
      <section className="py-16">
        <div className="max-w-7xl mx-auto px-6">
          <div className="flex items-center justify-between mb-8">
            <div>
              <h2 className="mb-2">Top Used Vehicle Deals</h2>
              <p className="text-gray-600">Verified and certified pre-owned vehicles</p>
            </div>
            <Button variant="outline" onClick={() => onNavigate('used-listing')}>
              Browse All Used
            </Button>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            {featuredUsedVehicles.map((vehicle) => (
              <UsedVehicleCard
                key={vehicle.id}
                vehicle={vehicle}
                onView={(id) => onNavigate('used-detail', id)}
              />
            ))}
          </div>
        </div>
      </section>

      {/* Explore by Category */}
      <section className="py-16 bg-gray-50">
        <div className="max-w-7xl mx-auto px-6">
          <h2 className="mb-8 text-center">Explore by Category</h2>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-6">
            {categories.map((category) => (
              <Card
                key={category.name}
                className="p-6 hover:shadow-lg transition-shadow cursor-pointer hover:border-[#007BFF]"
                onClick={() => onNavigate(category.page)}
              >
                <div className="flex flex-col items-center text-center">
                  <div className="w-16 h-16 bg-[#007BFF]/10 rounded-full flex items-center justify-center mb-4">
                    <category.icon className="w-8 h-8 text-[#007BFF]" />
                  </div>
                  <h3 className="mb-1">{category.name}</h3>
                  <p className="text-gray-600">{category.count}</p>
                </div>
              </Card>
            ))}
          </div>
        </div>
      </section>

      {/* Blog & Forum Highlights */}
      <section className="py-16">
        <div className="max-w-7xl mx-auto px-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
            {/* Blog Card */}
            <Card className="p-8 hover:shadow-lg transition-shadow cursor-pointer" onClick={() => onNavigate('news')}>
              <div className="flex items-start gap-4">
                <div className="w-12 h-12 bg-[#007BFF]/10 rounded-full flex items-center justify-center flex-shrink-0">
                  <TrendingUp className="w-6 h-6 text-[#007BFF]" />
                </div>
                <div>
                  <h3 className="mb-2">Latest Automotive News</h3>
                  <p className="text-gray-600 mb-4">
                    Stay updated with industry trends, new launches, and expert reviews
                  </p>
                  <Button variant="outline">Read Articles</Button>
                </div>
              </div>
            </Card>

            {/* Forum Card */}
            <Card className="p-8 hover:shadow-lg transition-shadow cursor-pointer" onClick={() => onNavigate('forum')}>
              <div className="flex items-start gap-4">
                <div className="w-12 h-12 bg-[#39FF14]/10 rounded-full flex items-center justify-center flex-shrink-0">
                  <MessageSquare className="w-6 h-6 text-[#39FF14]" />
                </div>
                <div>
                  <h3 className="mb-2">Join the Community</h3>
                  <p className="text-gray-600 mb-4">
                    Connect with owners, share experiences, and get expert advice
                  </p>
                  <Button variant="outline">Visit Forum</Button>
                </div>
              </div>
            </Card>
          </div>
        </div>
      </section>

      {/* AI Recommendation Strip */}
      <section className="py-12 bg-gradient-to-r from-purple-600 to-blue-600 text-white">
        <div className="max-w-7xl mx-auto px-6">
          <div className="flex flex-col md:flex-row items-center justify-between gap-6">
            <div className="flex items-start gap-4">
              <div className="w-12 h-12 bg-white/20 rounded-full flex items-center justify-center flex-shrink-0">
                <Sparkles className="w-6 h-6" />
              </div>
              <div>
                <h3 className="mb-2">AI-Powered Recommendations</h3>
                <p className="text-purple-100">
                  Based on your preferences, we suggest: Honda Elevate VX - Perfect balance of
                  performance, efficiency, and value for city driving.
                </p>
              </div>
            </div>
            <Button
              variant="secondary"
              size="lg"
              className="flex-shrink-0"
              onClick={() => onNavigate('insights')}
            >
              <TrendingUp className="w-4 h-4 mr-2" />
              View Insights
            </Button>
          </div>
        </div>
      </section>

      {/* Stats Section */}
      <section className="py-16">
        <div className="max-w-7xl mx-auto px-6">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-8 text-center">
            <div>
              <div className="text-blue-600 mb-2">1,940+</div>
              <p className="text-gray-600">Vehicles Listed</p>
            </div>
            <div>
              <div className="text-blue-600 mb-2">50K+</div>
              <p className="text-gray-600">User Reviews</p>
            </div>
            <div>
              <div className="text-blue-600 mb-2">98%</div>
              <p className="text-gray-600">Accuracy Rate</p>
            </div>
            <div>
              <div className="text-blue-600 mb-2">24/7</div>
              <p className="text-gray-600">AI Support</p>
            </div>
          </div>
        </div>
      </section>
    </div>
  );
}
