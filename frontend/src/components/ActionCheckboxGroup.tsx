import React from 'react';
import { Check } from 'lucide-react';

interface ActionOption {
  id: string;
  label: string;
  description?: string;
}

interface ActionCheckboxGroupProps {
  options: ActionOption[];
  selected: string[];
  onChange: (selected: string[]) => void;
  label?: string;
}

export default function ActionCheckboxGroup({
  options,
  selected,
  onChange,
  label
}: ActionCheckboxGroupProps) {
  const handleToggle = (id: string) => {
    const newSelected = selected.includes(id)
      ? selected.filter(item => item !== id)
      : [...selected, id];
    onChange(newSelected);
  };

  return (
    <div className="space-y-3">
      {label && (
        <label className="block text-sm font-semibold text-gray-700">
          {label}
        </label>
      )}
      <div className="space-y-2">
        {options.map(option => (
          <div
            key={option.id}
            className="flex items-start space-x-3 p-3 rounded-lg border border-gray-200 hover:bg-gray-50 transition-colors"
          >
            <button
              type="button"
              onClick={() => handleToggle(option.id)}
              className={`flex-shrink-0 w-5 h-5 rounded border-2 flex items-center justify-center transition-colors ${
                selected.includes(option.id)
                  ? 'bg-blue border-blue'
                  : 'border-gray-300 hover:border-gray-400'
              }`}
            >
              {selected.includes(option.id) && (
                <Check className="w-3 h-3 text-white" />
              )}
            </button>
            <div className="flex-1">
              <label
                className="text-sm font-medium text-gray-900 cursor-pointer"
                onClick={() => handleToggle(option.id)}
              >
                {option.label}
              </label>
              {option.description && (
                <p className="text-xs text-gray-500 mt-1">{option.description}</p>
              )}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
