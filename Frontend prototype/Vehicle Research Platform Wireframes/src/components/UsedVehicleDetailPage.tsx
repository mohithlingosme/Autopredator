import React, { useState } from 'react';
import { ChevronRight, Phone, MessageCircle, Shield, CheckCircle2, AlertTriangle, FileText, Calendar, User, Star, TrendingUp } from 'lucide-react';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Tabs, TabsContent, TabsList, TabsTrigger } from './ui/tabs';
import { Card } from './ui/card';
import { usedVehicles } from '../data/usedVehicles';
import { UsedVehicleCard } from './UsedVehicleCard';
import { ImageWithFallback } from './figma/ImageWithFallback';
import { LineChart, Line, XAxis, YAxis, Tooltip, ResponsiveContainer, ReferenceLine } from 'recharts';

interface UsedVehicleDetailPageProps {
  vehicleId: string;
  onNavigate: (page: string, vehicleId?: string) => void;
}

export function UsedVehicleDetailPage({ vehicleId, onNavigate }: UsedVehicleDetailPageProps) {
  const vehicle = usedVehicles.find(v => v.id === vehicleId) || usedVehicles[0];
  const similarVehicles = usedVehicles.filter(v => 
    v.brand === vehicle.brand && v.id !== vehicle.id
  ).slice(0, 3);

  const valueData = [
    { month: 'Now', value: vehicle.price / 100000 },
    { month: '+6m', value: (vehicle.price * 0.95) / 100000 },
    { month: '+1y', value: (vehicle.price * 0.88) / 100000 },
    { month: '+2y', value: (vehicle.price * 0.75) / 100000 },
    { month: '+3y', value: (vehicle.price * 0.65) / 100000 }
  ];

  const serviceHistory = [
    { date: '2025-08-15', type: 'General Service', cost: 8500, odometer: 20000 },
    { date: '2025-02-20', type: 'Oil Change + Filters', cost: 4200, odometer: 15000 },
    { date: '2024-08-10', type: 'General Service', cost: 7800, odometer: 10000 },
    { date: '2024-02-05', type: 'First Service', cost: 3500, odometer: 5000 }
  ];

  return (
    <div>
      {/* Breadcrumb */}
      <div className="bg-gray-50 border-b">
        <div className="max-w-7xl mx-auto px-6 py-4">
          <div className="flex items-center gap-2 text-sm text-gray-600">
            <button onClick={() => onNavigate('home')} className="hover:text-blue-600">Home</button>
            <ChevronRight className="w-4 h-4" />
            <button onClick={() => onNavigate('used-listing')} className="hover:text-blue-600">Used Vehicles</button>
            <ChevronRight className="w-4 h-4" />
            <span className="text-gray-900">{vehicle.name}</span>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-6 py-8">
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8 mb-8">
          {/* Main Content */}
          <div className="lg:col-span-2">
            {/* Image Gallery */}
            <div className="mb-6">
              <div className="rounded-lg overflow-hidden mb-4 relative">
                <ImageWithFallback
                  src={vehicle.image}
                  alt={vehicle.name}
                  className="w-full h-96 object-cover"
                />
                {vehicle.blockchainVerified && (
                  <Badge className="absolute top-4 left-4 bg-[#39FF14] text-[#2C2C2C] gap-1">
                    <Shield className="w-4 h-4" />
                    Blockchain Verified
                  </Badge>
                )}
                {vehicle.rtoSynced && (
                  <Badge className="absolute top-4 right-4 bg-[#007BFF] gap-1">
                    <CheckCircle2 className="w-4 h-4" />
                    RTO Synced
                  </Badge>
                )}
              </div>
              <div className="grid grid-cols-5 gap-2">
                {[1, 2, 3, 4].map((i) => (
                  <div key={i} className="aspect-video rounded overflow-hidden bg-gray-200">
                    <ImageWithFallback
                      src={vehicle.image}
                      alt={`${vehicle.name} ${i}`}
                      className="w-full h-full object-cover opacity-60"
                    />
                  </div>
                ))}
                <div className="aspect-video rounded overflow-hidden bg-[#2C2C2C] flex items-center justify-center text-white">
                  <div className="text-center">
                    <div className="text-sm">360°</div>
                    <div className="text-xs">View</div>
                  </div>
                </div>
              </div>
            </div>

            {/* Vehicle Title */}
            <div className="mb-6">
              <div className="flex items-start justify-between mb-2">
                <h1>{vehicle.name}</h1>
              </div>
              <div className="flex items-center gap-2 flex-wrap">
                <Badge variant="outline">{vehicle.year}</Badge>
                <Badge variant="outline">{vehicle.ownerType}</Badge>
                <Badge variant="outline">{(vehicle.kmDriven / 1000).toFixed(0)}K km</Badge>
                <Badge variant="outline">{vehicle.location}</Badge>
                {vehicle.verified && (
                  <Badge className="bg-[#39FF14] text-[#2C2C2C]">
                    <CheckCircle2 className="w-3 h-3 mr-1" />
                    Verified
                  </Badge>
                )}
              </div>
            </div>

            {/* Tabs */}
            <Tabs defaultValue="overview">
              <TabsList className="w-full justify-start">
                <TabsTrigger value="overview">Overview</TabsTrigger>
                <TabsTrigger value="specs">Specifications</TabsTrigger>
                <TabsTrigger value="service">Service History</TabsTrigger>
                <TabsTrigger value="documents">Documents</TabsTrigger>
                <TabsTrigger value="similar">Similar Cars</TabsTrigger>
              </TabsList>

              <TabsContent value="overview">
                <Card className="p-6">
                  <h3 className="mb-4">Vehicle Overview</h3>
                  <div className="grid grid-cols-2 md:grid-cols-3 gap-4 mb-6">
                    <div>
                      <div className="text-sm text-gray-600 mb-1">Fuel Type</div>
                      <div>{vehicle.fuelType}</div>
                    </div>
                    <div>
                      <div className="text-sm text-gray-600 mb-1">Transmission</div>
                      <div>{vehicle.transmission}</div>
                    </div>
                    <div>
                      <div className="text-sm text-gray-600 mb-1">Condition</div>
                      <div>{vehicle.condition}</div>
                    </div>
                    <div>
                      <div className="text-sm text-gray-600 mb-1">Registration</div>
                      <div>{vehicle.registrationNumber}</div>
                    </div>
                    <div>
                      <div className="text-sm text-gray-600 mb-1">Service History</div>
                      <div className="flex items-center gap-1">
                        {vehicle.serviceHistory ? (
                          <>
                            <CheckCircle2 className="w-4 h-4 text-green-600" />
                            <span>Available</span>
                          </>
                        ) : (
                          <>
                            <AlertTriangle className="w-4 h-4 text-orange-600" />
                            <span>Not Available</span>
                          </>
                        )}
                      </div>
                    </div>
                    <div>
                      <div className="text-sm text-gray-600 mb-1">Accident History</div>
                      <div className="flex items-center gap-1">
                        {vehicle.accidentHistory ? (
                          <>
                            <AlertTriangle className="w-4 h-4 text-red-600" />
                            <span>Yes</span>
                          </>
                        ) : (
                          <>
                            <CheckCircle2 className="w-4 h-4 text-green-600" />
                            <span>None</span>
                          </>
                        )}
                      </div>
                    </div>
                  </div>

                  <h4 className="mb-3 text-[#007BFF]">AI-Powered Value Prediction</h4>
                  <div className="bg-gradient-to-br from-blue-50 to-purple-50 rounded-lg p-4 mb-4">
                    <div className="flex items-center justify-between mb-4">
                      <div>
                        <div className="text-sm text-gray-600">Predicted Fair Value</div>
                        <div className="text-[#007BFF]">₹{(vehicle.predictedValue / 100000).toFixed(2)}L</div>
                      </div>
                      <div className="text-right">
                        <div className="text-sm text-gray-600">AI Confidence</div>
                        <div className="text-[#39FF14]">{vehicle.valueConfidence}%</div>
                      </div>
                    </div>
                    <div className="h-48">
                      <ResponsiveContainer width="100%" height="100%">
                        <LineChart data={valueData}>
                          <XAxis dataKey="month" />
                          <YAxis label={{ value: '₹ Lakhs', angle: -90, position: 'insideLeft' }} />
                          <Tooltip formatter={(value: number) => `₹${value.toFixed(2)}L`} />
                          <ReferenceLine 
                            y={vehicle.predictedValue / 100000} 
                            stroke="#39FF14" 
                            strokeDasharray="3 3"
                            label="Fair Value"
                          />
                          <Line 
                            type="monotone" 
                            dataKey="value" 
                            stroke="#007BFF" 
                            strokeWidth={2}
                          />
                        </LineChart>
                      </ResponsiveContainer>
                    </div>
                  </div>
                </Card>
              </TabsContent>

              <TabsContent value="specs">
                <Card className="p-6">
                  <h3 className="mb-6">Technical Specifications</h3>
                  <div className="space-y-3">
                    <div className="flex justify-between py-3 border-b">
                      <span className="text-gray-600">Brand</span>
                      <span>{vehicle.brand}</span>
                    </div>
                    <div className="flex justify-between py-3 border-b">
                      <span className="text-gray-600">Model</span>
                      <span>{vehicle.model}</span>
                    </div>
                    <div className="flex justify-between py-3 border-b">
                      <span className="text-gray-600">Year</span>
                      <span>{vehicle.year}</span>
                    </div>
                    <div className="flex justify-between py-3 border-b">
                      <span className="text-gray-600">KM Driven</span>
                      <span>{vehicle.kmDriven.toLocaleString()} km</span>
                    </div>
                    <div className="flex justify-between py-3 border-b">
                      <span className="text-gray-600">Fuel Type</span>
                      <span>{vehicle.fuelType}</span>
                    </div>
                    <div className="flex justify-between py-3 border-b">
                      <span className="text-gray-600">Transmission</span>
                      <span>{vehicle.transmission}</span>
                    </div>
                    <div className="flex justify-between py-3 border-b">
                      <span className="text-gray-600">Owner Type</span>
                      <span>{vehicle.ownerType}</span>
                    </div>
                    <div className="flex justify-between py-3 border-b">
                      <span className="text-gray-600">Registration Number</span>
                      <span>{vehicle.registrationNumber}</span>
                    </div>
                  </div>
                </Card>
              </TabsContent>

              <TabsContent value="service">
                <Card className="p-6">
                  <h3 className="mb-6">Service History</h3>
                  {vehicle.serviceHistory ? (
                    <div className="space-y-4">
                      {serviceHistory.map((service, index) => (
                        <div key={index} className="border-l-4 border-[#007BFF] pl-4 pb-4">
                          <div className="flex items-center justify-between mb-2">
                            <div className="flex items-center gap-2">
                              <Calendar className="w-4 h-4 text-gray-500" />
                              <span>{service.date}</span>
                            </div>
                            <Badge variant="outline">{service.odometer.toLocaleString()} km</Badge>
                          </div>
                          <div className="mb-1">{service.type}</div>
                          <div className="text-sm text-gray-600">Cost: ₹{service.cost.toLocaleString()}</div>
                        </div>
                      ))}
                    </div>
                  ) : (
                    <p className="text-gray-600">Service history not available for this vehicle.</p>
                  )}
                </Card>
              </TabsContent>

              <TabsContent value="documents">
                <Card className="p-6">
                  <h3 className="mb-6">Available Documents</h3>
                  <div className="space-y-3">
                    <div className="flex items-center justify-between p-4 bg-gray-50 rounded">
                      <div className="flex items-center gap-3">
                        <FileText className="w-5 h-5 text-[#007BFF]" />
                        <span>Registration Certificate (RC)</span>
                      </div>
                      {vehicle.rtoSynced && (
                        <CheckCircle2 className="w-5 h-5 text-green-600" />
                      )}
                    </div>
                    <div className="flex items-center justify-between p-4 bg-gray-50 rounded">
                      <div className="flex items-center gap-3">
                        <FileText className="w-5 h-5 text-[#007BFF]" />
                        <span>Insurance Papers</span>
                      </div>
                      <CheckCircle2 className="w-5 h-5 text-green-600" />
                    </div>
                    <div className="flex items-center justify-between p-4 bg-gray-50 rounded">
                      <div className="flex items-center gap-3">
                        <FileText className="w-5 h-5 text-[#007BFF]" />
                        <span>Service Records</span>
                      </div>
                      {vehicle.serviceHistory && (
                        <CheckCircle2 className="w-5 h-5 text-green-600" />
                      )}
                    </div>
                    <div className="flex items-center justify-between p-4 bg-gray-50 rounded">
                      <div className="flex items-center gap-3">
                        <Shield className="w-5 h-5 text-[#39FF14]" />
                        <span>Blockchain Verification</span>
                      </div>
                      {vehicle.blockchainVerified && (
                        <CheckCircle2 className="w-5 h-5 text-green-600" />
                      )}
                    </div>
                  </div>
                </Card>
              </TabsContent>

              <TabsContent value="similar">
                <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                  {similarVehicles.map((v) => (
                    <UsedVehicleCard
                      key={v.id}
                      vehicle={v}
                      onView={(id) => onNavigate('used-detail', id)}
                    />
                  ))}
                </div>
              </TabsContent>
            </Tabs>
          </div>

          {/* Sidebar */}
          <div className="space-y-6">
            {/* Price Card */}
            <Card className="p-6">
              <div className="mb-4">
                <div className="text-sm text-gray-600 mb-1">Asking Price</div>
                <div className="text-[#007BFF] mb-2">₹{(vehicle.price / 100000).toFixed(2)}L</div>
                {vehicle.negotiable && (
                  <Badge className="bg-[#39FF14] text-[#2C2C2C]">Negotiable</Badge>
                )}
              </div>
              <div className="text-sm text-gray-600 mb-4">
                Original Price: <span className="line-through">₹{(vehicle.originalPrice / 100000).toFixed(2)}L</span>
              </div>
              <div className="space-y-2 mb-4">
                <Button className="w-full gap-2 bg-[#007BFF]">
                  <Phone className="w-4 h-4" />
                  Contact Seller
                </Button>
                <Button variant="outline" className="w-full gap-2">
                  <MessageCircle className="w-4 h-4" />
                  Chat Now
                </Button>
                <Button variant="outline" className="w-full">
                  Book Inspection
                </Button>
              </div>
            </Card>

            {/* Seller Info */}
            <Card className="p-6">
              <h3 className="mb-4">Seller Information</h3>
              <div className="flex items-center gap-3 mb-4">
                <div className="w-12 h-12 bg-gray-200 rounded-full flex items-center justify-center">
                  <User className="w-6 h-6 text-gray-600" />
                </div>
                <div className="flex-1">
                  <div className="mb-1">{vehicle.sellerInfo.name}</div>
                  <div className="flex items-center gap-1 text-sm">
                    <Star className="w-3 h-3 fill-yellow-400 text-yellow-400" />
                    <span>{vehicle.sellerInfo.rating.toFixed(1)}</span>
                  </div>
                </div>
              </div>
              <div className="space-y-2 text-sm">
                <div className="flex justify-between py-2 border-b">
                  <span className="text-gray-600">Type</span>
                  <Badge variant="outline">{vehicle.sellerType}</Badge>
                </div>
                <div className="flex justify-between py-2 border-b">
                  <span className="text-gray-600">Vehicles Sold</span>
                  <span>{vehicle.sellerInfo.vehiclesSold}</span>
                </div>
                <div className="flex justify-between py-2">
                  <span className="text-gray-600">Phone</span>
                  <span>{vehicle.sellerInfo.phone}</span>
                </div>
              </div>
            </Card>

            {/* Financing */}
            <Card className="p-6 bg-gradient-to-br from-[#007BFF] to-[#2C2C2C] text-white">
              <h3 className="mb-2">Need Financing?</h3>
              <p className="text-sm mb-4 text-gray-200">
                Get instant loan approval with our partner banks
              </p>
              <Button variant="secondary" className="w-full">
                Check Eligibility
              </Button>
            </Card>
          </div>
        </div>
      </div>
    </div>
  );
}
