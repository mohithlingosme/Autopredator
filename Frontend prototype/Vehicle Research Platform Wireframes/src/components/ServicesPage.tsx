import React, { useState } from 'react';
import { Shield, DollarSign, Wrench, Scale, ShoppingBag, Calculator } from 'lucide-react';
import { Card } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Tabs, TabsContent, TabsList, TabsTrigger } from './ui/tabs';
import { Input } from './ui/input';
import { Slider } from './ui/slider';
import { ImageWithFallback } from './figma/ImageWithFallback';

interface ServicesPageProps {
  onNavigate: (page: string) => void;
}

export function ServicesPage({ onNavigate }: ServicesPageProps) {
  const [insuranceVehicleValue, setInsuranceVehicleValue] = useState([1500000]);
  const [loanAmount, setLoanAmount] = useState([1000000]);
  const [loanTenure, setLoanTenure] = useState([5]);

  const calculateInsurance = () => {
    return Math.round(insuranceVehicleValue[0] * 0.035);
  };

  const calculateEMI = () => {
    const P = loanAmount[0];
    const r = 8.5 / 12 / 100;
    const n = loanTenure[0] * 12;
    return Math.round((P * r * Math.pow(1 + r, n)) / (Math.pow(1 + r, n) - 1));
  };

  const services = {
    insurance: [
      { name: 'Tata AIG', rating: 4.5, price: '₹18,500/yr', features: ['Zero Dep', '24/7 Support', 'Cashless Garage'] },
      { name: 'ICICI Lombard', rating: 4.6, price: '₹19,200/yr', features: ['Comprehensive', 'RSA', 'Engine Protection'] },
      { name: 'HDFC ERGO', rating: 4.4, price: '₹17,800/yr', features: ['NCB Protection', 'Invoice Cover', 'Key Replacement'] }
    ],
    finance: [
      { name: 'HDFC Bank', rating: 4.7, rate: '8.5% p.a.', features: ['Instant Approval', 'Flexible Tenure', 'Zero Prepayment'] },
      { name: 'ICICI Bank', rating: 4.6, rate: '8.75% p.a.', features: ['Up to 90% Funding', 'Quick Disbursal', 'Digital Process'] },
      { name: 'Axis Bank', rating: 4.5, rate: '8.65% p.a.', features: ['Minimal Documentation', 'Doorstep Service', '7 Year Tenure'] }
    ],
    mechanics: [
      { name: 'AutoCare Service Center', rating: 4.8, location: 'Delhi NCR', services: ['General Service', 'AC Repair', 'Body Work'] },
      { name: 'Premium Auto Workshop', rating: 4.7, location: 'Mumbai', services: ['Engine Overhaul', 'Transmission', 'Electronics'] },
      { name: 'QuickFix Garage', rating: 4.6, location: 'Bangalore', services: ['Oil Change', 'Brake Service', 'Detailing'] }
    ],
    legal: [
      { name: 'Vehicle Registration Assistance', description: 'Complete RTO documentation support' },
      { name: 'Transfer of Ownership', description: 'Hassle-free ownership transfer services' },
      { name: 'Insurance Claim Support', description: 'Expert guidance for claim processing' },
      { name: 'Loan Settlement', description: 'NOC and clearance documentation' }
    ]
  };

  return (
    <div>
      {/* Hero Section */}
      <div className="bg-gradient-to-r from-[#2C2C2C] to-[#007BFF] text-white py-12">
        <div className="max-w-7xl mx-auto px-6">
          <h1 className="mb-4">AutoCare Services</h1>
          <p className="text-xl text-gray-200">
            Complete vehicle ownership solutions - Insurance, Finance, Maintenance & Legal
          </p>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-6 py-8">
        <Tabs defaultValue="insurance">
          <TabsList className="w-full justify-start mb-8">
            <TabsTrigger value="insurance" className="gap-2">
              <Shield className="w-4 h-4" />
              Insurance
            </TabsTrigger>
            <TabsTrigger value="finance" className="gap-2">
              <DollarSign className="w-4 h-4" />
              Finance
            </TabsTrigger>
            <TabsTrigger value="mechanics" className="gap-2">
              <Wrench className="w-4 h-4" />
              Mechanics
            </TabsTrigger>
            <TabsTrigger value="legal" className="gap-2">
              <Scale className="w-4 h-4" />
              Legal
            </TabsTrigger>
            <TabsTrigger value="accessories" className="gap-2">
              <ShoppingBag className="w-4 h-4" />
              Accessories
            </TabsTrigger>
          </TabsList>

          {/* Insurance Tab */}
          <TabsContent value="insurance">
            <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
              <div className="lg:col-span-2">
                <h2 className="mb-6">Vehicle Insurance Partners</h2>
                <div className="space-y-6">
                  {services.insurance.map((provider, index) => (
                    <Card key={index} className="p-6 hover:shadow-lg transition-shadow">
                      <div className="flex items-start justify-between mb-4">
                        <div>
                          <h3 className="mb-2">{provider.name}</h3>
                          <div className="flex items-center gap-2 mb-2">
                            <div className="flex items-center gap-1">
                              <span className="text-yellow-400">★</span>
                              <span>{provider.rating}</span>
                            </div>
                            <Badge className="bg-[#007BFF]">Partner</Badge>
                          </div>
                          <div className="text-[#007BFF] mb-3">{provider.price}</div>
                        </div>
                        <Button>Get Quote</Button>
                      </div>
                      <div className="flex flex-wrap gap-2">
                        {provider.features.map((feature, i) => (
                          <Badge key={i} variant="outline">{feature}</Badge>
                        ))}
                      </div>
                    </Card>
                  ))}
                </div>
              </div>

              {/* Insurance Calculator */}
              <div>
                <Card className="p-6 sticky top-24">
                  <div className="flex items-center gap-2 mb-4">
                    <Calculator className="w-5 h-5 text-[#007BFF]" />
                    <h3>Premium Estimator</h3>
                  </div>
                  <div className="space-y-4">
                    <div>
                      <label className="text-sm text-gray-600 mb-2 block">Vehicle IDV</label>
                      <Input
                        type="text"
                        value={`₹${(insuranceVehicleValue[0] / 100000).toFixed(1)}L`}
                        readOnly
                        className="mb-2"
                      />
                      <Slider
                        value={insuranceVehicleValue}
                        onValueChange={setInsuranceVehicleValue}
                        min={300000}
                        max={5000000}
                        step={50000}
                      />
                    </div>
                    <div className="p-4 bg-blue-50 rounded-lg">
                      <div className="text-sm text-gray-600 mb-1">Estimated Premium</div>
                      <div className="text-[#007BFF]">₹{calculateInsurance().toLocaleString()}/year</div>
                    </div>
                    <Button className="w-full">Compare Quotes</Button>
                  </div>
                </Card>
              </div>
            </div>
          </TabsContent>

          {/* Finance Tab */}
          <TabsContent value="finance">
            <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
              <div className="lg:col-span-2">
                <h2 className="mb-6">Auto Loan Partners</h2>
                <div className="space-y-6">
                  {services.finance.map((bank, index) => (
                    <Card key={index} className="p-6 hover:shadow-lg transition-shadow">
                      <div className="flex items-start justify-between mb-4">
                        <div>
                          <h3 className="mb-2">{bank.name}</h3>
                          <div className="flex items-center gap-2 mb-2">
                            <div className="flex items-center gap-1">
                              <span className="text-yellow-400">★</span>
                              <span>{bank.rating}</span>
                            </div>
                          </div>
                          <div className="text-[#39FF14] mb-3">{bank.rate}</div>
                        </div>
                        <Button>Apply Now</Button>
                      </div>
                      <div className="flex flex-wrap gap-2">
                        {bank.features.map((feature, i) => (
                          <Badge key={i} variant="outline">{feature}</Badge>
                        ))}
                      </div>
                    </Card>
                  ))}
                </div>
              </div>

              {/* Loan Calculator */}
              <div>
                <Card className="p-6 sticky top-24">
                  <div className="flex items-center gap-2 mb-4">
                    <Calculator className="w-5 h-5 text-[#007BFF]" />
                    <h3>EMI Calculator</h3>
                  </div>
                  <div className="space-y-4">
                    <div>
                      <label className="text-sm text-gray-600 mb-2 block">Loan Amount</label>
                      <Input
                        type="text"
                        value={`₹${(loanAmount[0] / 100000).toFixed(1)}L`}
                        readOnly
                        className="mb-2"
                      />
                      <Slider
                        value={loanAmount}
                        onValueChange={setLoanAmount}
                        min={200000}
                        max={5000000}
                        step={50000}
                      />
                    </div>
                    <div>
                      <label className="text-sm text-gray-600 mb-2 block">Tenure (Years)</label>
                      <Input
                        type="text"
                        value={`${loanTenure[0]} years`}
                        readOnly
                        className="mb-2"
                      />
                      <Slider
                        value={loanTenure}
                        onValueChange={setLoanTenure}
                        min={1}
                        max={7}
                        step={1}
                      />
                    </div>
                    <div className="p-4 bg-blue-50 rounded-lg">
                      <div className="text-sm text-gray-600 mb-1">Monthly EMI @ 8.5%</div>
                      <div className="text-[#007BFF]">₹{calculateEMI().toLocaleString()}/month</div>
                    </div>
                    <Button className="w-full">Check Eligibility</Button>
                  </div>
                </Card>
              </div>
            </div>
          </TabsContent>

          {/* Mechanics Tab */}
          <TabsContent value="mechanics">
            <h2 className="mb-6">Authorized Service Centers</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {services.mechanics.map((garage, index) => (
                <Card key={index} className="p-6 hover:shadow-lg transition-shadow">
                  <div className="mb-4">
                    <h3 className="mb-2">{garage.name}</h3>
                    <div className="flex items-center gap-2 mb-2">
                      <span className="text-yellow-400">★</span>
                      <span>{garage.rating}</span>
                    </div>
                    <div className="text-sm text-gray-600">{garage.location}</div>
                  </div>
                  <div className="mb-4">
                    <div className="text-sm text-gray-600 mb-2">Services:</div>
                    <div className="flex flex-wrap gap-2">
                      {garage.services.map((service, i) => (
                        <Badge key={i} variant="outline">{service}</Badge>
                      ))}
                    </div>
                  </div>
                  <Button variant="outline" className="w-full">Book Service</Button>
                </Card>
              ))}
            </div>
          </TabsContent>

          {/* Legal Tab */}
          <TabsContent value="legal">
            <h2 className="mb-6">Legal & Documentation Services</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {services.legal.map((service, index) => (
                <Card key={index} className="p-6 hover:shadow-lg transition-shadow">
                  <div className="flex items-start gap-4">
                    <div className="w-12 h-12 bg-[#007BFF]/10 rounded-full flex items-center justify-center flex-shrink-0">
                      <Scale className="w-6 h-6 text-[#007BFF]" />
                    </div>
                    <div className="flex-1">
                      <h3 className="mb-2">{service.name}</h3>
                      <p className="text-gray-600 mb-4">{service.description}</p>
                      <Button variant="outline">Learn More</Button>
                    </div>
                  </div>
                </Card>
              ))}
            </div>
          </TabsContent>

          {/* Accessories Tab */}
          <TabsContent value="accessories">
            <h2 className="mb-6">Vehicle Accessories & Add-ons</h2>
            <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
              {['Seat Covers', 'Car Mats', 'Dash Cams', 'Air Purifiers', 'Phone Mounts', 'GPS Trackers', 'Floor Mats', 'Steering Covers'].map((item, index) => (
                <Card key={index} className="p-6 text-center hover:shadow-lg transition-shadow cursor-pointer">
                  <div className="w-16 h-16 bg-gray-200 rounded-full mx-auto mb-4"></div>
                  <h4 className="mb-2">{item}</h4>
                  <div className="text-[#007BFF] mb-3">From ₹499</div>
                  <Button variant="outline" size="sm" className="w-full">View</Button>
                </Card>
              ))}
            </div>
          </TabsContent>
        </Tabs>
      </div>
    </div>
  );
}
