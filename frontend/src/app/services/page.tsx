'use client';

import { useState } from 'react';
import { ShieldCheck, Wallet, Wrench, Scale, ShoppingBag } from 'lucide-react';
import InsuranceEstimator from '@/components/InsuranceEstimator';

const tabs = [
  {
    id: 'insurance',
    label: 'Insurance',
    icon: ShieldCheck,
    services: [
      { title: 'Zero Dep', description: 'Full coverage with zero depreciation', cta: 'Get Quote' },
      { title: 'Third Party', description: 'Mandatory cover starting Rs 2,500/year', cta: 'Buy Now' }
    ]
  },
  {
    id: 'finance',
    label: 'Finance',
    icon: Wallet,
    services: [
      { title: 'Pre-approved Loans', description: 'Instant offers from 12 banks', cta: 'Check Offers' },
      { title: 'Lease Plans', description: 'Flexible lease for fleets', cta: 'Consult Advisor' }
    ]
  },
  {
    id: 'mechanics',
    label: 'Mechanics',
    icon: Wrench,
    services: [
      { title: 'Doorstep Service', description: 'Periodic maintenance at your home', cta: 'Book Slot' },
      { title: 'Certified Workshops', description: 'OEM grade repairs by master techs', cta: 'Find Center' }
    ]
  },
  {
    id: 'legal',
    label: 'Legal',
    icon: Scale,
    services: [
      { title: 'RC Transfer', description: 'End-to-end RTO support across India', cta: 'Start Transfer' },
      { title: 'Compliance', description: 'Tax, emission, and recall compliance', cta: 'Talk to Expert' }
    ]
  },
  {
    id: 'accessories',
    label: 'Accessories',
    icon: ShoppingBag,
    services: [
      { title: 'Genuine Parts', description: 'OEM accessories with warranty', cta: 'Shop Now' },
      { title: 'EV Upgrades', description: 'Charging docks & battery health check', cta: 'Explore' }
    ]
  }
];

export default function ServicesPage() {
  const [activeTab, setActiveTab] = useState(tabs[0].id);

  const activeServices = tabs.find(tab => tab.id === activeTab)?.services ?? [];

  return (
    <div className="container mx-auto px-4 py-10 space-y-12">
      <div className="text-center space-y-3">
        <p className="text-xs uppercase tracking-[0.3em] text-gray-500">Page 7</p>
        <h1 className="text-4xl font-bold text-charcoal">AutoCare | AutoFinance | AutoLegal</h1>
        <p className="text-gray-600 text-lg max-w-2xl mx-auto">
          Manage insurance, finance, service and legal workflows from a single hub. AI-backed widgets recommend the
          right cover and partners.
        </p>
      </div>

      <div className="card p-2 flex flex-wrap gap-2">
        {tabs.map(tab => {
          const Icon = tab.icon;
          return (
            <button
              key={tab.id}
              type="button"
              className={`flex-1 min-w-[150px] flex items-center justify-center gap-2 px-3 py-3 rounded-lg ${
                activeTab === tab.id ? 'bg-blue text-white' : 'bg-gray-100 text-gray-700'
              }`}
              onClick={() => setActiveTab(tab.id)}
            >
              <Icon className="w-5 h-5" />
              {tab.label}
            </button>
          );
        })}
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {activeServices.map(service => (
          <div key={service.title} className="card p-6">
            <p className="text-sm uppercase tracking-[0.3em] text-gray-500 mb-2">Service</p>
            <h3 className="text-xl font-semibold">{service.title}</h3>
            <p className="text-gray-600 mt-2">{service.description}</p>
            <button type="button" className="btn-primary mt-4">
              {service.cta}
            </button>
          </div>
        ))}
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <InsuranceEstimator />
        <div className="card p-5 space-y-4">
          <h3 className="text-lg font-semibold">Featured Partners</h3>
          <div className="flex flex-wrap gap-3">
            {['HDFC Bank', 'Acko', 'Tata Motors', 'Mahindra Finance'].map(partner => (
              <div key={partner} className="px-4 py-2 border rounded-full text-sm text-gray-600">
                {partner}
              </div>
            ))}
          </div>
          <p className="text-sm text-gray-500">Verified partners ensure faster approvals and transparent pricing.</p>
        </div>
      </div>
    </div>
  );
}
