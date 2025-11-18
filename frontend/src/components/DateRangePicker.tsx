import React, { useState } from 'react';
import { Calendar, ChevronDown } from 'lucide-react';
import Button from './Button';

interface DateRange {
  start: Date | null;
  end: Date | null;
}

interface DateRangePickerProps {
  value: DateRange;
  onChange: (range: DateRange) => void;
  label?: string;
}

export default function DateRangePicker({ value, onChange, label }: DateRangePickerProps) {
  const [isOpen, setIsOpen] = useState(false);

  const formatDate = (date: Date | null) => {
    if (!date) return '';
    return date.toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
    });
  };

  const handlePreset = (preset: string) => {
    const now = new Date();
    let start: Date | null = null;
    let end: Date | null = null;

    switch (preset) {
      case 'today':
        start = end = now;
        break;
      case 'yesterday':
        start = end = new Date(now.getTime() - 24 * 60 * 60 * 1000);
        break;
      case 'last7days':
        start = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
        end = now;
        break;
      case 'last30days':
        start = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
        end = now;
        break;
      case 'thisMonth':
        start = new Date(now.getFullYear(), now.getMonth(), 1);
        end = new Date(now.getFullYear(), now.getMonth() + 1, 0);
        break;
      case 'lastMonth':
        start = new Date(now.getFullYear(), now.getMonth() - 1, 1);
        end = new Date(now.getFullYear(), now.getMonth(), 0);
        break;
    }

    onChange({ start, end });
    setIsOpen(false);
  };

  const presets = [
    { label: 'Today', value: 'today' },
    { label: 'Yesterday', value: 'yesterday' },
    { label: 'Last 7 days', value: 'last7days' },
    { label: 'Last 30 days', value: 'last30days' },
    { label: 'This month', value: 'thisMonth' },
    { label: 'Last month', value: 'lastMonth' },
  ];

  return (
    <div className="relative">
      {label && (
        <label className="block text-sm font-semibold text-gray-700 mb-2">
          {label}
        </label>
      )}
      <Button
        variant="outline"
        onClick={() => setIsOpen(!isOpen)}
        className="w-full justify-between"
      >
        <div className="flex items-center">
          <Calendar className="h-4 w-4 mr-2" />
          <span>
            {value.start && value.end
              ? `${formatDate(value.start)} - ${formatDate(value.end)}`
              : 'Select date range'}
          </span>
        </div>
        <ChevronDown className="h-4 w-4" />
      </Button>

      {isOpen && (
        <div className="absolute z-10 mt-1 w-full bg-white border border-gray-200 rounded-lg shadow-lg">
          <div className="p-2">
            <div className="space-y-1">
              {presets.map(preset => (
                <button
                  key={preset.value}
                  onClick={() => handlePreset(preset.value)}
                  className="w-full text-left px-3 py-2 text-sm hover:bg-gray-100 rounded"
                >
                  {preset.label}
                </button>
              ))}
            </div>
            <div className="border-t border-gray-200 mt-2 pt-2">
              <p className="text-xs text-gray-500 mb-2">Custom range (coming soon)</p>
              <div className="grid grid-cols-2 gap-2">
                <input
                  type="date"
                  className="w-full px-2 py-1 text-sm border border-gray-300 rounded"
                  value={value.start ? value.start.toISOString().split('T')[0] : ''}
                  onChange={(e) => {
                    const date = e.target.value ? new Date(e.target.value) : null;
                    onChange({ ...value, start: date });
                  }}
                />
                <input
                  type="date"
                  className="w-full px-2 py-1 text-sm border border-gray-300 rounded"
                  value={value.end ? value.end.toISOString().split('T')[0] : ''}
                  onChange={(e) => {
                    const date = e.target.value ? new Date(e.target.value) : null;
                    onChange({ ...value, end: date });
                  }}
                />
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
