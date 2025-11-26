'use client';

import Link from 'next/link';
import { motion } from 'framer-motion';
import Card from '@/components/Card';
import Button from '@/components/Button';
import { TrendingUp, Activity, FileText, Plus } from 'lucide-react';
import { Line } from 'react-chartjs-2';
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
} from 'chart.js';

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend
);

export default function JournalDashboardPage() {
  // Mock data for charts
  const chartData = {
    labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
    datasets: [
      {
        label: 'Confidence Score',
        data: [0.7, 0.8, 0.6, 0.9, 0.85, 0.95],
        borderColor: '#007bff',
        backgroundColor: 'rgba(0, 123, 255, 0.1)',
        tension: 0.4,
      },
    ],
  };

  const chartOptions = {
    responsive: true,
    plugins: {
      legend: {
        position: 'top' as const,
      },
      title: {
        display: true,
        text: 'Prediction Confidence Over Time',
      },
    },
  };

  return (
    <motion.section
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.5 }}
      className="space-y-6"
    >
      <div className="grid gap-4 md:grid-cols-2">
        <motion.div
          initial={{ opacity: 0, x: -20 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ delay: 0.1 }}
        >
          <Card>
            <div className="flex items-center space-x-3">
              <Activity className="h-8 w-8 text-blue" />
              <div>
                <h2 className="text-lg font-semibold text-charcoal">Active insights</h2>
                <p className="text-sm text-gray-500 mt-1">Track your most recent predictions and health metrics.</p>
              </div>
            </div>
            <div className="mt-4 grid grid-cols-2 gap-4">
              <div className="text-center">
                <div className="text-2xl font-bold text-blue">12</div>
                <div className="text-sm text-gray-500">Active Predictions</div>
              </div>
              <div className="text-center">
                <div className="text-2xl font-bold text-green-600">95%</div>
                <div className="text-sm text-gray-500">Avg Confidence</div>
              </div>
            </div>
          </Card>
        </motion.div>

        <motion.div
          initial={{ opacity: 0, x: 20 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ delay: 0.2 }}
        >
          <Card>
            <div className="flex items-center space-x-3">
              <FileText className="h-8 w-8 text-blue" />
              <div>
                <h2 className="text-lg font-semibold text-charcoal">Entry stats</h2>
                <p className="text-sm text-gray-500 mt-1">Add new journal entries, review predictions, and export reports.</p>
              </div>
            </div>
            <div className="mt-4 grid grid-cols-2 gap-4">
              <div className="text-center">
                <div className="text-2xl font-bold text-blue">47</div>
                <div className="text-sm text-gray-500">Total Entries</div>
              </div>
              <div className="text-center">
                <div className="text-2xl font-bold text-green-600">3</div>
                <div className="text-sm text-gray-500">This Week</div>
              </div>
            </div>
          </Card>
        </motion.div>
      </div>

      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.3 }}
        className="rounded-3xl border border-dashed border-gray-300 bg-white/80 p-6 shadow-sm"
      >
        <div className="flex items-start justify-between mb-6">
          <div>
            <h3 className="text-xl font-semibold text-charcoal flex items-center">
              <TrendingUp className="h-6 w-6 mr-2 text-blue" />
              Prediction history
            </h3>
            <p className="text-sm text-gray-500">Latest AI output with confidence trends.</p>
          </div>
          <Link href="/journal/new">
            <Button size="sm">
              <Plus className="h-4 w-4 mr-2" />
              Create entry
            </Button>
          </Link>
        </div>
        <div className="h-64 w-full">
          <Line
            data={chartData}
            options={{
              ...chartOptions,
              responsive: true,
              maintainAspectRatio: false,
            }}
          />
        </div>
        <div className="mt-6 grid gap-3 md:grid-cols-3">
          {[
            { label: 'High Confidence', value: '85%', color: 'text-green-600' },
            { label: 'Medium Confidence', value: '12%', color: 'text-yellow-600' },
            { label: 'Low Confidence', value: '3%', color: 'text-red-600' },
          ].map(item => (
            <motion.div
              key={item.label}
              whileHover={{ scale: 1.05 }}
              className="rounded-2xl border border-gray-100 bg-gray-50 p-4 text-center"
            >
              <div className={`text-2xl font-bold ${item.color}`}>{item.value}</div>
              <div className="text-sm text-gray-600">{item.label}</div>
            </motion.div>
          ))}
        </div>
      </motion.div>
    </motion.section>
  );
}
