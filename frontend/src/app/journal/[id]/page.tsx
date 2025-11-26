'use client';

import { useState } from 'react';
import { motion } from 'framer-motion';
import JournalTopNav from '@/components/JournalTopNav';
import Card from '@/components/Card';
import Button from '@/components/Button';
import DateRangePicker from '@/components/DateRangePicker';
import ModelVersionFilter from '@/components/ModelVersionFilter';
import { Clock, TrendingUp, FileText, Download, Share, Edit, Eye, BarChart3 } from 'lucide-react';

interface JournalDetailPageProps {
  params: {
    id: string;
  };
}

export default function JournalDetailPage({ params }: JournalDetailPageProps) {
  const [dateRange, setDateRange] = useState<{ start: Date | null; end: Date | null }>({ start: null, end: null });
  const [selectedModels, setSelectedModels] = useState<string[]>([]);

  // Mock data
  const entry = {
    id: params.id,
    title: 'Vehicle Maintenance Prediction',
    content: 'Analyzed maintenance data for fleet vehicles. Predicted potential issues based on usage patterns and historical data.',
    predictionType: 'maintenance',
    confidence: 0.87,
    createdAt: '2024-01-15',
    status: 'completed',
  };

  const modelVersions = [
    { id: 'v1.0', name: 'Maintenance Predictor', version: '1.0', description: 'Initial model' },
    { id: 'v1.1', name: 'Maintenance Predictor', version: '1.1', description: 'Improved accuracy' },
    { id: 'v2.0', name: 'Advanced Predictor', version: '2.0', description: 'Multi-factor analysis' },
  ];

  const timeline = [
    { time: '10:30 AM', event: 'Entry created', type: 'create' },
    { time: '10:32 AM', event: 'Data analysis started', type: 'process' },
    { time: '10:35 AM', event: 'Prediction generated', type: 'result' },
    { time: '10:36 AM', event: 'Report exported', type: 'export' },
  ];

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.5 }}
      className="space-y-6"
    >
      <JournalTopNav
        title={`Entry ${params.id}`}
        breadcrumbs={[
          { label: 'Journal', href: '/journal' },
          { label: `Entry ${params.id}` }
        ]}
      />

      <div className="grid gap-6 lg:grid-cols-3">
        <div className="lg:col-span-2 space-y-6">
          <Card>
            <div className="flex items-start justify-between mb-4">
              <div>
                <h2 className="text-xl font-semibold text-charcoal">{entry.title}</h2>
                <div className="flex items-center mt-2 text-sm text-gray-500">
                  <Clock className="h-4 w-4 mr-1" />
                  Created on {entry.createdAt}
                  <span className="mx-2">•</span>
                  <span className={`px-2 py-1 rounded-full text-xs ${
                    entry.status === 'completed' ? 'bg-green-100 text-green-800' : 'bg-yellow-100 text-yellow-800'
                  }`}>
                    {entry.status}
                  </span>
                </div>
              </div>
              <div className="flex space-x-2">
                <Button variant="outline" size="sm">
                  <Edit className="h-4 w-4 mr-2" />
                  Edit
                </Button>
                <Button variant="outline" size="sm">
                  <Share className="h-4 w-4 mr-2" />
                  Share
                </Button>
              </div>
            </div>

            <div className="prose prose-sm max-w-none">
              <p>{entry.content}</p>
            </div>

            <div className="mt-6 grid grid-cols-2 gap-4">
              <div>
                <label className="text-sm font-medium text-gray-700">Prediction Type</label>
                <p className="text-sm text-gray-900 capitalize">{entry.predictionType}</p>
              </div>
              <div>
                <label className="text-sm font-medium text-gray-700">Confidence Score</label>
                <p className="text-sm text-gray-900">{(entry.confidence * 100).toFixed(1)}%</p>
              </div>
            </div>
          </Card>

          <Card>
            <h3 className="text-lg font-semibold text-charcoal mb-4 flex items-center">
              <BarChart3 className="h-5 w-5 mr-2 text-blue" />
              Prediction Results
            </h3>
            <div className="space-y-4">
              <div className="bg-gray-50 p-4 rounded-lg">
                <h4 className="font-medium text-gray-900">Maintenance Recommendations</h4>
                <ul className="mt-2 text-sm text-gray-600 space-y-1">
                  <li>• Oil change recommended in 500 miles</li>
                  <li>• Tire rotation due in 2 weeks</li>
                  <li>• Brake inspection advised</li>
                </ul>
              </div>
              <div className="bg-blue-50 p-4 rounded-lg">
                <h4 className="font-medium text-blue-900">Confidence Analysis</h4>
                <p className="mt-2 text-sm text-blue-700">
                  High confidence based on historical data patterns and current vehicle metrics.
                </p>
              </div>
            </div>
          </Card>
        </div>

        <div className="space-y-6">
          <Card>
            <h3 className="text-lg font-semibold text-charcoal mb-4">Filters</h3>
            <div className="space-y-4">
              <DateRangePicker
                value={dateRange}
                onChange={setDateRange}
                label="Date Range"
              />
              <ModelVersionFilter
                options={modelVersions}
                selected={selectedModels}
                onChange={setSelectedModels}
                label="Model Versions"
              />
            </div>
          </Card>

          <Card>
            <h3 className="text-lg font-semibold text-charcoal mb-4 flex items-center">
              <Clock className="h-5 w-5 mr-2 text-blue" />
              Timeline
            </h3>
            <div className="space-y-3">
              {timeline.map((item, index) => (
                <div key={index} className="flex items-start space-x-3">
                  <div className="flex-shrink-0 w-2 h-2 bg-blue-500 rounded-full mt-2"></div>
                  <div className="flex-1">
                    <p className="text-sm font-medium text-gray-900">{item.event}</p>
                    <p className="text-xs text-gray-500">{item.time}</p>
                  </div>
                </div>
              ))}
            </div>
          </Card>

          <Card>
            <h3 className="text-lg font-semibold text-charcoal mb-4">Actions</h3>
            <div className="space-y-3">
              <Button variant="outline" className="w-full justify-start">
                <Download className="h-4 w-4 mr-2" />
                Export Report
              </Button>
              <Button variant="outline" className="w-full justify-start">
                <Eye className="h-4 w-4 mr-2" />
                View Raw Data
              </Button>
              <Button variant="outline" className="w-full justify-start">
                <TrendingUp className="h-4 w-4 mr-2" />
                Compare Results
              </Button>
            </div>
          </Card>
        </div>
      </div>
    </motion.div>
  );
}
