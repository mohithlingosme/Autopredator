import React from 'react';
import { TrendingUp, DollarSign, AlertCircle, Sparkles } from 'lucide-react';
import { Card } from './ui/card';
import { Badge } from './ui/badge';
import { VehicleCard } from './VehicleCard';
import { vehicles } from '../data/vehicles';
import {
  LineChart,
  Line,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
  RadarChart,
  PolarGrid,
  PolarAngleAxis,
  PolarRadiusAxis,
  Radar
} from 'recharts';

interface InsightsPageProps {
  onNavigate: (page: string, vehicleId?: string) => void;
}

export function InsightsPage({ onNavigate }: InsightsPageProps) {
  const ownershipCostData = [
    { year: 'Year 1', cost: 15.2, segment: 16.5 },
    { year: 'Year 2', cost: 17.8, segment: 19.2 },
    { year: 'Year 3', cost: 20.4, segment: 22.8 },
    { year: 'Year 4', cost: 23.6, segment: 26.5 },
    { year: 'Year 5', cost: 27.2, segment: 30.8 }
  ];

  const depreciationData = [
    { year: 'Year 1', percentage: 15 },
    { year: 'Year 2', percentage: 28 },
    { year: 'Year 3', percentage: 38 },
    { year: 'Year 4', percentage: 46 },
    { year: 'Year 5', percentage: 52 }
  ];

  const maintenanceData = [
    { month: 'Jan', cost: 3200, predicted: 3500 },
    { month: 'Feb', cost: 2800, predicted: 3000 },
    { month: 'Mar', cost: 4500, predicted: 4200 },
    { month: 'Apr', cost: 3100, predicted: 3300 },
    { month: 'May', cost: 3800, predicted: 3600 },
    { month: 'Jun', cost: 5200, predicted: 5000 }
  ];

  const performanceData = [
    { category: 'Fuel Efficiency', value: 82 },
    { category: 'Performance', value: 75 },
    { category: 'Comfort', value: 88 },
    { category: 'Safety', value: 92 },
    { category: 'Technology', value: 85 },
    { category: 'Value', value: 78 }
  ];

  const costSavingVehicles = vehicles.filter(v => v.fuelType === 'Electric' || parseFloat(v.mileage) > 18).slice(0, 3);

  return (
    <div className="max-w-7xl mx-auto px-6 py-8">
      {/* Header */}
      <div className="mb-8">
        <h1 className="mb-2">AI-Powered Insights</h1>
        <p className="text-gray-600">
          Predictive analytics and data-driven recommendations for smarter vehicle decisions
        </p>
      </div>

      {/* Key Metrics */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
        <Card className="p-6">
          <div className="flex items-center gap-3 mb-2">
            <div className="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center">
              <TrendingUp className="w-5 h-5 text-blue-600" />
            </div>
            <div>
              <div className="text-sm text-gray-600">Avg. Resale Value</div>
              <div className="text-blue-600">68%</div>
            </div>
          </div>
          <p className="text-xs text-gray-600">At 3 years for top vehicles</p>
        </Card>

        <Card className="p-6">
          <div className="flex items-center gap-3 mb-2">
            <div className="w-10 h-10 bg-green-100 rounded-full flex items-center justify-center">
              <DollarSign className="w-5 h-5 text-green-600" />
            </div>
            <div>
              <div className="text-sm text-gray-600">Cost Savings</div>
              <div className="text-green-600">₹2.3L</div>
            </div>
          </div>
          <p className="text-xs text-gray-600">5-year ownership with EVs</p>
        </Card>

        <Card className="p-6">
          <div className="flex items-center gap-3 mb-2">
            <div className="w-10 h-10 bg-purple-100 rounded-full flex items-center justify-center">
              <Sparkles className="w-5 h-5 text-purple-600" />
            </div>
            <div>
              <div className="text-sm text-gray-600">Prediction Accuracy</div>
              <div className="text-purple-600">94%</div>
            </div>
          </div>
          <p className="text-xs text-gray-600">AI model confidence level</p>
        </Card>

        <Card className="p-6">
          <div className="flex items-center gap-3 mb-2">
            <div className="w-10 h-10 bg-orange-100 rounded-full flex items-center justify-center">
              <AlertCircle className="w-5 h-5 text-orange-600" />
            </div>
            <div>
              <div className="text-sm text-gray-600">Market Trend</div>
              <div className="text-orange-600">↑ 12%</div>
            </div>
          </div>
          <p className="text-xs text-gray-600">SUV demand this quarter</p>
        </Card>
      </div>

      {/* Ownership Cost Over 5 Years */}
      <Card className="p-6 mb-8">
        <div className="mb-6">
          <h2 className="mb-2">Total Ownership Cost Analysis</h2>
          <p className="text-gray-600">
            Comprehensive 5-year cost projection including depreciation, maintenance, and fuel
          </p>
        </div>
        <div className="h-80">
          <ResponsiveContainer width="100%" height="100%">
            <LineChart data={ownershipCostData}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="year" />
              <YAxis label={{ value: 'Cost (₹ Lakhs)', angle: -90, position: 'insideLeft' }} />
              <Tooltip formatter={(value: number) => `₹${value}L`} />
              <Legend />
              <Line 
                type="monotone" 
                dataKey="cost" 
                name="Your Vehicle" 
                stroke="#3b82f6" 
                strokeWidth={2}
                dot={{ r: 4 }}
              />
              <Line 
                type="monotone" 
                dataKey="segment" 
                name="Segment Average" 
                stroke="#9ca3af" 
                strokeWidth={2}
                strokeDasharray="5 5"
              />
            </LineChart>
          </ResponsiveContainer>
        </div>
        <div className="mt-4 p-4 bg-green-50 rounded-lg">
          <p className="text-sm text-green-700">
            <span className="font-medium">Insight:</span> Your selected vehicle saves approximately{' '}
            <span className="font-medium">₹3.6L (13%)</span> compared to segment average over 5 years.
          </p>
        </div>
      </Card>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-8">
        {/* Depreciation Chart */}
        <Card className="p-6">
          <div className="mb-6">
            <h3 className="mb-2">Depreciation Forecast</h3>
            <p className="text-sm text-gray-600">Expected value retention over time</p>
          </div>
          <div className="h-64">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={depreciationData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="year" />
                <YAxis label={{ value: 'Depreciation %', angle: -90, position: 'insideLeft' }} />
                <Tooltip formatter={(value: number) => `${value}%`} />
                <Bar dataKey="percentage" fill="#f59e0b" />
              </BarChart>
            </ResponsiveContainer>
          </div>
          <div className="mt-4 flex items-center gap-2">
            <Badge className="bg-orange-600">AI Prediction</Badge>
            <span className="text-sm text-gray-600">Confidence: 87%</span>
          </div>
        </Card>

        {/* Performance Radar */}
        <Card className="p-6">
          <div className="mb-6">
            <h3 className="mb-2">Vehicle Performance Index</h3>
            <p className="text-sm text-gray-600">Multi-dimensional analysis across key factors</p>
          </div>
          <div className="h-64">
            <ResponsiveContainer width="100%" height="100%">
              <RadarChart data={performanceData}>
                <PolarGrid />
                <PolarAngleAxis dataKey="category" />
                <PolarRadiusAxis angle={90} domain={[0, 100]} />
                <Radar 
                  name="Performance Score" 
                  dataKey="value" 
                  stroke="#3b82f6" 
                  fill="#3b82f6" 
                  fillOpacity={0.5} 
                />
                <Tooltip />
              </RadarChart>
            </ResponsiveContainer>
          </div>
          <div className="mt-4 flex items-center gap-2">
            <Badge className="bg-blue-600">Overall Score</Badge>
            <span className="text-sm">83/100 - Excellent</span>
          </div>
        </Card>
      </div>

      {/* Maintenance Prediction */}
      <Card className="p-6 mb-8">
        <div className="mb-6">
          <h2 className="mb-2">Maintenance Cost Prediction</h2>
          <p className="text-gray-600">AI-powered forecast vs actual maintenance spending</p>
        </div>
        <div className="h-64">
          <ResponsiveContainer width="100%" height="100%">
            <LineChart data={maintenanceData}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="month" />
              <YAxis label={{ value: 'Cost (₹)', angle: -90, position: 'insideLeft' }} />
              <Tooltip formatter={(value: number) => `₹${value}`} />
              <Legend />
              <Line 
                type="monotone" 
                dataKey="cost" 
                name="Actual Cost" 
                stroke="#10b981" 
                strokeWidth={2}
              />
              <Line 
                type="monotone" 
                dataKey="predicted" 
                name="AI Predicted" 
                stroke="#6366f1" 
                strokeWidth={2}
                strokeDasharray="5 5"
              />
            </LineChart>
          </ResponsiveContainer>
        </div>
        <div className="mt-4 p-4 bg-purple-50 rounded-lg">
          <p className="text-sm text-purple-700">
            <span className="font-medium">Next Service Due:</span> Expected in 2,300 km. 
            Predicted cost: <span className="font-medium">₹4,200</span> based on your driving patterns.
          </p>
        </div>
      </Card>

      {/* AI Recommendations */}
      <div className="mb-8">
        <div className="flex items-center justify-between mb-6">
          <div>
            <h2 className="mb-2">Recommended Vehicles to Reduce Long-Term Costs</h2>
            <p className="text-gray-600">
              Based on ownership cost analysis and efficiency metrics
            </p>
          </div>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {costSavingVehicles.map((vehicle) => (
            <VehicleCard
              key={vehicle.id}
              vehicle={vehicle}
              onView={(id) => onNavigate('detail', id)}
              onCompare={(id) => onNavigate('compare')}
              onFavorite={(id) => console.log('Favorite:', id)}
            />
          ))}
        </div>
      </div>

      {/* Market Trends */}
      <Card className="p-6 bg-gradient-to-br from-blue-50 to-purple-50">
        <div className="flex items-start gap-4">
          <div className="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center flex-shrink-0">
            <TrendingUp className="w-6 h-6 text-blue-600" />
          </div>
          <div>
            <h3 className="mb-3">Market Trends & Insights</h3>
            <div className="space-y-3">
              <div>
                <div className="flex items-center gap-2 mb-1">
                  <Badge className="bg-green-600">Rising</Badge>
                  <span>Electric Vehicle Adoption</span>
                </div>
                <p className="text-sm text-gray-600">
                  EV sales up 45% year-over-year. Predicted to reach 30% market share by 2027.
                </p>
              </div>
              <div>
                <div className="flex items-center gap-2 mb-1">
                  <Badge className="bg-blue-600">Stable</Badge>
                  <span>SUV Segment</span>
                </div>
                <p className="text-sm text-gray-600">
                  SUVs maintain strong demand with 12% growth. Best resale value in the market.
                </p>
              </div>
              <div>
                <div className="flex items-center gap-2 mb-1">
                  <Badge className="bg-orange-600">Watch</Badge>
                  <span>Fuel Prices</span>
                </div>
                <p className="text-sm text-gray-600">
                  Petrol prices expected to rise 8-10% over next 12 months. Consider fuel-efficient options.
                </p>
              </div>
            </div>
          </div>
        </div>
      </Card>
    </div>
  );
}
