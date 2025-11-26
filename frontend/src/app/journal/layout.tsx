'use client';

import { useState } from 'react';
import { Menu, X } from 'lucide-react';
import JournalSidebar from '@/components/JournalSidebar';
import JournalTopNav from '@/components/JournalTopNav';
import Button from '@/components/Button';

export default function JournalRootLayout({ children }: { children: React.ReactNode }) {
  const [sidebarOpen, setSidebarOpen] = useState(false);

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Mobile sidebar overlay */}
      {sidebarOpen && (
        <div
          className="fixed inset-0 z-40 bg-black/50 lg:hidden"
          onClick={() => setSidebarOpen(false)}
        />
      )}

      <div className="grid min-h-screen grid-cols-[280px,1fr]">
        {/* Desktop sidebar */}
        <aside className="hidden border-r border-gray-200 bg-white lg:block">
          <JournalSidebar />
        </aside>

        {/* Mobile sidebar */}
        <aside
          className={`fixed inset-y-0 left-0 z-50 w-64 transform border-r border-gray-200 bg-white transition-transform duration-300 ease-in-out lg:hidden ${
            sidebarOpen ? 'translate-x-0' : '-translate-x-full'
          }`}
        >
          <div className="flex items-center justify-between p-4 border-b border-gray-200">
            <h2 className="text-lg font-semibold text-charcoal">Journal</h2>
            <Button
              variant="outline"
              size="sm"
              onClick={() => setSidebarOpen(false)}
              className="p-1"
            >
              <X className="h-4 w-4" />
            </Button>
          </div>
          <JournalSidebar />
        </aside>

        <div className="flex flex-col">
          <JournalTopNav onMenuClick={() => setSidebarOpen(true)} />
          <main className="flex-1 p-6">{children}</main>
        </div>
      </div>
    </div>
  );
}
