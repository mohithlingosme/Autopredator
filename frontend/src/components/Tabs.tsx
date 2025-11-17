"use client";

import { classNames } from '@/lib/utils';

interface Tab {
  id: string;
  label: string;
}

interface TabsProps {
  tabs: Tab[];
  active: string;
  onChange: (tabId: string) => void;
}

export default function Tabs({ tabs, active, onChange }: TabsProps) {
  return (
    <div className="flex flex-wrap border-b border-gray-200">
      {tabs.map(tab => (
        <button
          key={tab.id}
          type="button"
          className={classNames(
            'px-4 py-3 text-sm font-semibold border-b-2 transition-colors',
            active === tab.id ? 'border-blue text-blue' : 'border-transparent text-gray-500 hover:text-blue'
          )}
          onClick={() => onChange(tab.id)}
        >
          {tab.label}
        </button>
      ))}
    </div>
  );
}
