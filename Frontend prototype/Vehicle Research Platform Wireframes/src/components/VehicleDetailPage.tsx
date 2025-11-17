import React, { useState } from 'react';
import { ChevronRight, Heart, GitCompare, Star, Fuel, Settings, Users, Calendar, Gauge, Zap, Shield, TrendingUp, DollarSign } from 'lucide-react';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Tabs, TabsContent, TabsList, TabsTrigger } from './ui/tabs';
import { Card } from './ui/card';
import { vehicles } from '../data/vehicles';
import { VehicleCard } from './VehicleCard';
import { ImageWithFallback } from './figma/ImageWithFallback';
import { Slider } from './ui/slider';
import { PieChart, Pie, Cell, ResponsiveContainer, BarChart, Bar, XAxis, YAxis, Tooltip, Legend } from 'recharts';

interface VehicleDetailPageProps {
  vehicleId: string;
  onNavigate: (page: string, vehicleId?: string) => void;
}

export function VehicleDetailPage({ vehicleId, onNavigate }: VehicleDetailPageProps) {
  const vehicle = vehicles.find(v => v.id === vehicleId) || vehicles[0];
  const similarVehicles = vehicles.filter(v => v.bodyType === vehicle.bodyType && v.id !== vehicle.id).slice(0, 3);

  const [loanAmount, setLoanAmount] = useState([vehicle.priceMin]);
  const [interestRate, setInterestRate] = useState([8.5]);
  const [tenure, setTenure] = useState([5]);

  const calculateEMI = () => {
    const principal = loanAmount[0];
    const rate = interestRate[0] / 12 / 100;
    const months = tenure[0] * 12;
    const emi = (principal * rate * Math.pow(1 + rate, months)) / (Math.pow(1 + rate, months) - 1);
    return emi;
  };

  const emi = calculateEMI();
  const totalAmount = emi * tenure[0] * 12;
  const totalInterest = totalAmount - loanAmount[0];

  const ownershipCostData = [
    { name: 'Purchase Price', value: vehicle.priceMin },
    { name: 'Maintenance (5yr)', value: 120000 },
    { name: 'Insurance (5yr)', value: 80000 },
    { name: 'Fuel (5yr)', value: 350000 }
  ];

  const COLORS = ['#3b82f6', '#10b981', '#f59e0b', '#ef4444'];

  const depreciationData = [
    { year: 'Year 1', value: 85, segment: 80 },
    { year: 'Year 2', value: 72, segment: 65 },
    { year: 'Year 3', value: 62, segment: 52 },
    { year: 'Year 4', value: 54, segment: 42 },
    { year: 'Year 5', value: 48, segment: 35 }
  ];

  return (
    <div>
      {/* Breadcrumb */}
      <div className="bg-gray-50 border-b">
        <div className="max-w-7xl mx-auto px-6 py-4">
          <div className="flex items-center gap-2 text-sm text-gray-600">
            <button onClick={() => onNavigate('home')} className="hover:text-blue-600">Home</button>
            <ChevronRight className="w-4 h-4" />
            <button onClick={() => onNavigate('listing')} className="hover:text-blue-600">{vehicle.bodyType}s</button>
            <ChevronRight className="w-4 h-4" />
            <span className="text-gray-900">{vehicle.name}</span>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-6 py-8">
        {/* Main Vehicle Info */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-8">
          {/* Image Gallery */}
          <div>
            <div className="rounded-lg overflow-hidden mb-4">
              <ImageWithFallback
                src={vehicle.image}
                alt={vehicle.name}
                className="w-full h-96 object-cover"
              />
            </div>
            <div className="grid grid-cols-4 gap-2">
              {[1, 2, 3, 4].map((i) => (
                <div key={i} className="aspect-video rounded overflow-hidden bg-gray-200">
                  <ImageWithFallback
                    src={vehicle.image}
                    alt={`${vehicle.name} ${i}`}
                    className="w-full h-full object-cover opacity-60"
                  />
                </div>
              ))}
            </div>
          </div>

          {/* Vehicle Details */}
          <div>
            <div className="flex items-start gap-2 mb-2">
              <h1 className="flex-1">{vehicle.name}</h1>
              <button className="p-2 rounded-full hover:bg-gray-100">
                <Heart className="w-5 h-5 text-gray-600" />
              </button>
            </div>

            <div className="flex items-center gap-4 mb-4">
              <div className="flex items-center gap-1">
                <Star className="w-5 h-5 fill-yellow-400 text-yellow-400" />
                <span>{vehicle.rating.toFixed(1)}</span>
                <span className="text-gray-500">({vehicle.reviews} reviews)</span>
              </div>
              <Badge>{vehicle.bodyType}</Badge>
              {vehicle.fuelType === 'Electric' && (
                <Badge className="bg-green-600">Electric</Badge>
              )}
            </div>

            <div className="mb-6">
              <div className="text-gray-600 mb-1">Price Range</div>
              <div className="text-blue-600">{vehicle.priceRange}</div>
            </div>

            {/* Quick Specs */}
            <div className="grid grid-cols-2 gap-4 mb-6 p-4 bg-gray-50 rounded-lg">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center">
                  <Fuel className="w-5 h-5 text-blue-600" />
                </div>
                <div>
                  <div className="text-sm text-gray-600">Fuel Type</div>
                  <div>{vehicle.fuelType}</div>
                </div>
              </div>
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center">
                  <Settings className="w-5 h-5 text-blue-600" />
                </div>
                <div>
                  <div className="text-sm text-gray-600">Transmission</div>
                  <div>{vehicle.transmission}</div>
                </div>
              </div>
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center">
                  <Gauge className="w-5 h-5 text-blue-600" />
                </div>
                <div>
                  <div className="text-sm text-gray-600">Mileage</div>
                  <div>{vehicle.mileage}</div>
                </div>
              </div>
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center">
                  <Users className="w-5 h-5 text-blue-600" />
                </div>
                <div>
                  <div className="text-sm text-gray-600">Seating</div>
                  <div>{vehicle.seating} Seats</div>
                </div>
              </div>
            </div>

            {/* Action Buttons */}
            <div className="flex gap-3">
              <Button className="flex-1" onClick={() => onNavigate('compare')}>
                <GitCompare className="w-4 h-4 mr-2" />
                Add to Compare
              </Button>
              <Button variant="outline" className="flex-1">
                Get Offers
              </Button>
              <Button variant="outline" className="flex-1">
                Test Drive
              </Button>
            </div>
          </div>
        </div>

        {/* Tabs Section */}
        <Tabs defaultValue="overview" className="mb-12">
          <TabsList className="w-full justify-start">
            <TabsTrigger value="overview">Overview</TabsTrigger>
            <TabsTrigger value="specs">Specifications</TabsTrigger>
            <TabsTrigger value="features">Features</TabsTrigger>
            <TabsTrigger value="finance">Finance</TabsTrigger>
            <TabsTrigger value="reviews">Reviews</TabsTrigger>
            <TabsTrigger value="legal">Legal</TabsTrigger>
          </TabsList>

          <TabsContent value="overview" className="space-y-6">
            <Card className="p-6">
              <h3 className="mb-4">Overview</h3>
              <p className="text-gray-600 mb-4">
                The {vehicle.name} is a {vehicle.bodyType.toLowerCase()} that combines performance, 
                efficiency, and modern features. With its {vehicle.engine} engine producing {vehicle.power} 
                of power, it delivers an excellent driving experience while maintaining impressive fuel 
                efficiency of {vehicle.mileage}.
              </p>

              <h3 className="mb-4">Total Ownership Cost (5 Years)</h3>
              <div className="h-64">
                <ResponsiveContainer width="100%" height="100%">
                  <PieChart>
                    <Pie
                      data={ownershipCostData}
                      cx="50%"
                      cy="50%"
                      labelLine={false}
                      label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}
                      outerRadius={80}
                      fill="#8884d8"
                      dataKey="value"
                    >
                      {ownershipCostData.map((entry, index) => (
                        <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                      ))}
                    </Pie>
                    <Tooltip formatter={(value: number) => `₹${(value / 100000).toFixed(1)}L`} />
                  </PieChart>
                </ResponsiveContainer>
              </div>
            </Card>
          </TabsContent>

          <TabsContent value="specs">
            <Card className="p-6">
              <h3 className="mb-6">Technical Specifications</h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <h4 className="mb-4 text-blue-600">Engine & Performance</h4>
                  <div className="space-y-3">
                    <div className="flex justify-between py-2 border-b">
                      <span className="text-gray-600">Engine</span>
                      <span>{vehicle.engine}</span>
                    </div>
                    <div className="flex justify-between py-2 border-b">
                      <span className="text-gray-600">Power</span>
                      <span>{vehicle.power}</span>
                    </div>
                    <div className="flex justify-between py-2 border-b">
                      <span className="text-gray-600">Torque</span>
                      <span>{vehicle.torque}</span>
                    </div>
                    <div className="flex justify-between py-2 border-b">
                      <span className="text-gray-600">Fuel Type</span>
                      <span>{vehicle.fuelType}</span>
                    </div>
                    <div className="flex justify-between py-2 border-b">
                      <span className="text-gray-600">Transmission</span>
                      <span>{vehicle.transmission}</span>
                    </div>
                    <div className="flex justify-between py-2 border-b">
                      <span className="text-gray-600">Mileage</span>
                      <span>{vehicle.mileage}</span>
                    </div>
                  </div>
                </div>
                <div>
                  <h4 className="mb-4 text-blue-600">Dimensions & Capacity</h4>
                  <div className="space-y-3">
                    <div className="flex justify-between py-2 border-b">
                      <span className="text-gray-600">Dimensions (L×W×H)</span>
                      <span className="text-sm">{vehicle.dimensions}</span>
                    </div>
                    <div className="flex justify-between py-2 border-b">
                      <span className="text-gray-600">Seating Capacity</span>
                      <span>{vehicle.seating} Seats</span>
                    </div>
                    <div className="flex justify-between py-2 border-b">
                      <span className="text-gray-600">Body Type</span>
                      <span>{vehicle.bodyType}</span>
                    </div>
                    <div className="flex justify-between py-2 border-b">
                      <span className="text-gray-600">Ground Clearance</span>
                      <span>180 mm</span>
                    </div>
                    <div className="flex justify-between py-2 border-b">
                      <span className="text-gray-600">Boot Space</span>
                      <span>433 L</span>
                    </div>
                    <div className="flex justify-between py-2 border-b">
                      <span className="text-gray-600">Fuel Tank</span>
                      <span>50 L</span>
                    </div>
                  </div>
                </div>
              </div>
            </Card>
          </TabsContent>

          <TabsContent value="features">
            <Card className="p-6">
              <h3 className="mb-6">Key Features</h3>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                <div>
                  <h4 className="mb-4 text-blue-600">Safety</h4>
                  <ul className="space-y-2">
                    <li className="flex items-center gap-2">
                      <Shield className="w-4 h-4 text-green-600" />
                      <span>6 Airbags</span>
                    </li>
                    <li className="flex items-center gap-2">
                      <Shield className="w-4 h-4 text-green-600" />
                      <span>ABS with EBD</span>
                    </li>
                    <li className="flex items-center gap-2">
                      <Shield className="w-4 h-4 text-green-600" />
                      <span>Electronic Stability Control</span>
                    </li>
                    <li className="flex items-center gap-2">
                      <Shield className="w-4 h-4 text-green-600" />
                      <span>Hill Hold Assist</span>
                    </li>
                  </ul>
                </div>
                <div>
                  <h4 className="mb-4 text-blue-600">Comfort</h4>
                  <ul className="space-y-2">
                    <li className="flex items-center gap-2">
                      <Zap className="w-4 h-4 text-blue-600" />
                      <span>Climate Control</span>
                    </li>
                    <li className="flex items-center gap-2">
                      <Zap className="w-4 h-4 text-blue-600" />
                      <span>Ventilated Seats</span>
                    </li>
                    <li className="flex items-center gap-2">
                      <Zap className="w-4 h-4 text-blue-600" />
                      <span>Panoramic Sunroof</span>
                    </li>
                    <li className="flex items-center gap-2">
                      <Zap className="w-4 h-4 text-blue-600" />
                      <span>Ambient Lighting</span>
                    </li>
                  </ul>
                </div>
                <div>
                  <h4 className="mb-4 text-blue-600">Technology</h4>
                  <ul className="space-y-2">
                    <li className="flex items-center gap-2">
                      <Star className="w-4 h-4 text-purple-600" />
                      <span>10.25" Touchscreen</span>
                    </li>
                    <li className="flex items-center gap-2">
                      <Star className="w-4 h-4 text-purple-600" />
                      <span>Wireless Charging</span>
                    </li>
                    <li className="flex items-center gap-2">
                      <Star className="w-4 h-4 text-purple-600" />
                      <span>Connected Car Tech</span>
                    </li>
                    <li className="flex items-center gap-2">
                      <Star className="w-4 h-4 text-purple-600" />
                      <span>360° Camera</span>
                    </li>
                  </ul>
                </div>
              </div>
            </Card>
          </TabsContent>

          <TabsContent value="finance">
            <Card className="p-6">
              <h3 className="mb-6">EMI Calculator</h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                <div className="space-y-6">
                  <div>
                    <div className="flex justify-between mb-2">
                      <span>Loan Amount</span>
                      <span>₹{(loanAmount[0] / 100000).toFixed(1)}L</span>
                    </div>
                    <Slider
                      value={loanAmount}
                      onValueChange={setLoanAmount}
                      min={vehicle.priceMin * 0.1}
                      max={vehicle.priceMax}
                      step={10000}
                    />
                  </div>
                  <div>
                    <div className="flex justify-between mb-2">
                      <span>Interest Rate</span>
                      <span>{interestRate[0].toFixed(1)}%</span>
                    </div>
                    <Slider
                      value={interestRate}
                      onValueChange={setInterestRate}
                      min={7}
                      max={15}
                      step={0.1}
                    />
                  </div>
                  <div>
                    <div className="flex justify-between mb-2">
                      <span>Tenure</span>
                      <span>{tenure[0]} years</span>
                    </div>
                    <Slider
                      value={tenure}
                      onValueChange={setTenure}
                      min={1}
                      max={7}
                      step={1}
                    />
                  </div>
                </div>
                <div className="bg-gradient-to-br from-blue-50 to-purple-50 rounded-lg p-6">
                  <h4 className="mb-6">Your Monthly EMI</h4>
                  <div className="text-blue-600 mb-6">₹{emi.toFixed(0).replace(/\B(?=(\d{3})+(?!\d))/g, ',')}</div>
                  <div className="space-y-3">
                    <div className="flex justify-between py-2 border-b border-blue-200">
                      <span className="text-gray-600">Principal Amount</span>
                      <span>₹{(loanAmount[0] / 100000).toFixed(2)}L</span>
                    </div>
                    <div className="flex justify-between py-2 border-b border-blue-200">
                      <span className="text-gray-600">Total Interest</span>
                      <span>₹{(totalInterest / 100000).toFixed(2)}L</span>
                    </div>
                    <div className="flex justify-between py-2">
                      <span>Total Amount</span>
                      <span>₹{(totalAmount / 100000).toFixed(2)}L</span>
                    </div>
                  </div>
                  <Button className="w-full mt-6">Apply for Loan</Button>
                </div>
              </div>
            </Card>
          </TabsContent>

          <TabsContent value="reviews">
            <Card className="p-6">
              <h3 className="mb-6">User Reviews</h3>
              <div className="space-y-6">
                {[1, 2, 3].map((i) => (
                  <div key={i} className="pb-6 border-b">
                    <div className="flex items-center justify-between mb-2">
                      <div className="flex items-center gap-2">
                        <div className="w-10 h-10 bg-gray-200 rounded-full"></div>
                        <div>
                          <div>User {i}</div>
                          <div className="text-sm text-gray-600">Owner for 2 years</div>
                        </div>
                      </div>
                      <div className="flex items-center gap-1">
                        {[...Array(5)].map((_, j) => (
                          <Star key={j} className="w-4 h-4 fill-yellow-400 text-yellow-400" />
                        ))}
                      </div>
                    </div>
                    <p className="text-gray-600">
                      Excellent vehicle with great fuel efficiency and comfortable ride. 
                      The features are top-notch and maintenance costs are reasonable.
                    </p>
                  </div>
                ))}
              </div>
            </Card>
          </TabsContent>

          <TabsContent value="legal">
            <Card className="p-6">
              <h3 className="mb-6">Legal & Compliance</h3>
              <div className="space-y-6">
                <div>
                  <h4 className="mb-3 text-blue-600">RTO & Registration</h4>
                  <div className="space-y-2">
                    <div className="flex justify-between py-2 border-b">
                      <span className="text-gray-600">RTO Tax (Delhi)</span>
                      <span>₹1,23,000</span>
                    </div>
                    <div className="flex justify-between py-2 border-b">
                      <span className="text-gray-600">Registration Charges</span>
                      <span>₹5,000</span>
                    </div>
                    <div className="flex justify-between py-2 border-b">
                      <span className="text-gray-600">Insurance (1st year)</span>
                      <span>₹18,500</span>
                    </div>
                  </div>
                </div>
                <div>
                  <h4 className="mb-3 text-blue-600">Emissions & Standards</h4>
                  <div className="space-y-2">
                    <div className="flex justify-between py-2 border-b">
                      <span className="text-gray-600">Emission Class</span>
                      <Badge>BS6 Phase 2</Badge>
                    </div>
                    <div className="flex justify-between py-2 border-b">
                      <span className="text-gray-600">Safety Rating</span>
                      <div className="flex items-center gap-1">
                        {[...Array(5)].map((_, i) => (
                          <Star key={i} className="w-4 h-4 fill-yellow-400 text-yellow-400" />
                        ))}
                      </div>
                    </div>
                    <div className="flex justify-between py-2 border-b">
                      <span className="text-gray-600">Warranty</span>
                      <span>3 years / 1,00,000 km</span>
                    </div>
                  </div>
                </div>
                <div className="bg-green-50 border border-green-200 rounded-lg p-4">
                  <div className="flex items-center gap-2 text-green-700">
                    <Shield className="w-5 h-5" />
                    <span>No active recalls for this vehicle</span>
                  </div>
                </div>
              </div>
            </Card>
          </TabsContent>
        </Tabs>

        {/* AI Insights */}
        <Card className="p-6 mb-8 bg-gradient-to-br from-purple-50 to-blue-50">
          <div className="flex items-start gap-4">
            <div className="w-12 h-12 bg-purple-100 rounded-full flex items-center justify-center flex-shrink-0">
              <TrendingUp className="w-6 h-6 text-purple-600" />
            </div>
            <div className="flex-1">
              <h3 className="mb-2">AI Insights</h3>
              <p className="text-gray-600 mb-4">
                This vehicle's resale value is <span className="text-purple-600">22% higher</span> than 
                segment average. Predicted depreciation at 5 years: <span className="text-purple-600">48%</span>.
                Maintenance costs are expected to be <span className="text-green-600">15% lower</span> than competitors.
              </p>
              <div className="h-64">
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart data={depreciationData}>
                    <XAxis dataKey="year" />
                    <YAxis />
                    <Tooltip />
                    <Legend />
                    <Bar dataKey="value" name="This Vehicle" fill="#3b82f6" />
                    <Bar dataKey="segment" name="Segment Average" fill="#9ca3af" />
                  </BarChart>
                </ResponsiveContainer>
              </div>
            </div>
          </div>
        </Card>

        {/* Similar Vehicles */}
        <div>
          <h2 className="mb-6">Similar Vehicles</h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {similarVehicles.map((v) => (
              <VehicleCard
                key={v.id}
                vehicle={v}
                onView={(id) => onNavigate('detail', id)}
                onCompare={(id) => onNavigate('compare')}
                onFavorite={(id) => console.log('Favorite:', id)}
              />
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
