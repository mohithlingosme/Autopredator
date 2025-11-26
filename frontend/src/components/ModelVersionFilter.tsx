import React, { useState } from 'react';
import { ChevronDown, Check } from 'lucide-react';
import Button from './Button';

interface ModelVersion {
  id: string;
  name: string;
  version: string;
  description?: string;
}

interface ModelVersionFilterProps {
  options: ModelVersion[];
  selected: string[];
  onChange: (selected: string[]) => void;
  label?: string;
}

export default function ModelVersionFilter({
  options,
  selected,
  onChange,
  label = 'Model Versions'
}: ModelVersionFilterProps) {
  const [isOpen, setIsOpen] = useState(false);

  const handleToggle = (id: string) => {
    const newSelected = selected.includes(id)
      ? selected.filter(item => item !== id)
      : [...selected, id];
    onChange(newSelected);
  };

  const handleSelectAll = () => {
    onChange(options.map(option => option.id));
  };

  const handleClearAll = () => {
    onChange([]);
  };

  const selectedCount = selected.length;
  const displayText = selectedCount === 0
    ? 'All versions'
    : selectedCount === 1
    ? options.find(opt => opt.id === selected[0])?.name || '1 version'
    : `${selectedCount} versions`;

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
        <span>{displayText}</span>
        <ChevronDown className="h-4 w-4" />
      </Button>

      {isOpen && (
        <div className="absolute z-10 mt-1 w-full bg-white border border-gray-200 rounded-lg shadow-lg max-h-64 overflow-y-auto">
          <div className="p-2">
            <div className="flex justify-between items-center mb-2">
              <Button variant="outline" size="sm" onClick={handleSelectAll}>
                Select All
              </Button>
              <Button variant="outline" size="sm" onClick={handleClearAll}>
                Clear All
              </Button>
            </div>
            <div className="space-y-1">
              {options.map(option => (
                <button
                  key={option.id}
                  onClick={() => handleToggle(option.id)}
                  className="w-full flex items-center justify-between px-3 py-2 text-sm hover:bg-gray-100 rounded"
                >
                  <div className="flex items-center">
                    <div className="flex-shrink-0 w-4 h-4 rounded border-2 border-gray-300 mr-3 flex items-center justify-center">
                      {selected.includes(option.id) && (
                        <Check className="w-3 h-3 text-blue" />
                      )}
                    </div>
                    <div className="text-left">
                      <div className="font-medium">{option.name}</div>
                      <div className="text-xs text-gray-500">v{option.version}</div>
                      {option.description && (
                        <div className="text-xs text-gray-400">{option.description}</div>
                      )}
                    </div>
                  </div>
                </button>
              ))}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
