'use client';

import { ChevronDown } from 'lucide-react';
import { classNames } from '@/lib/utils';

export type FilterSectionType = 'select' | 'checkbox' | 'toggle';

export interface FilterSection {
  id: string;
  title: string;
  type: FilterSectionType;
  options: Array<{ label: string; value: string }>;
  multi?: boolean;
}

interface FilterSidebarProps {
  sections: FilterSection[];
  values: Record<string, string[]>;
  onChange: (sectionId: string, values: string[]) => void;
  footer?: React.ReactNode;
}

export default function FilterSidebar({ sections, values, onChange, footer }: FilterSidebarProps) {
  const toggleValue = (sectionId: string, value: string) => {
    const current = values[sectionId] || [];
    if (current.includes(value)) {
      onChange(sectionId, current.filter(item => item !== value));
    } else {
      onChange(sectionId, [...current, value]);
    }
  };

  return (
    <aside className="card p-5 sticky top-24 h-fit w-full">
      <div className="flex items-center justify-between mb-4">
        <h2 className="text-lg font-semibold text-charcoal">Filters</h2>
        <button type="button" className="text-sm text-blue" onClick={() => onChange('reset', [])}>
          Reset
        </button>
      </div>

      <div className="space-y-6">
        {sections.map(section => (
          <div key={section.id} className="border border-gray-100 rounded-lg">
            <button
              type="button"
              className="w-full flex items-center justify-between px-3 py-2 text-left font-semibold"
            >
              {section.title}
              <ChevronDown className="w-4 h-4 text-gray-500" />
            </button>
            <div className="px-3 pb-3 space-y-2">
              {section.type === 'select' && (
                <select
                  className="w-full border rounded-md px-2 py-2"
                  value={values[section.id]?.[0] || ''}
                  onChange={event => onChange(section.id, event.target.value ? [event.target.value] : [])}
                >
                  <option value="">All</option>
                  {section.options.map(option => (
                    <option key={option.value} value={option.value}>
                      {option.label}
                    </option>
                  ))}
                </select>
              )}

              {section.type === 'checkbox' &&
                section.options.map(option => (
                  <label key={option.value} className="flex items-center gap-2 text-sm">
                    <input
                      type="checkbox"
                      checked={values[section.id]?.includes(option.value) || false}
                      onChange={() => toggleValue(section.id, option.value)}
                    />
                    {option.label}
                  </label>
                ))}

              {section.type === 'toggle' &&
                section.options.map(option => {
                  const active = values[section.id]?.includes(option.value);
                  return (
                    <button
                      key={option.value}
                      type="button"
                      className={classNames(
                        'w-full border rounded-md px-3 py-2 text-left text-sm',
                        active ? 'border-blue text-blue bg-blue/10' : 'border-gray-200'
                      )}
                      onClick={() => toggleValue(section.id, option.value)}
                    >
                      {option.label}
                    </button>
                  );
                })}
            </div>
          </div>
        ))}
      </div>

      {footer && <div className="mt-6">{footer}</div>}
    </aside>
  );
}
