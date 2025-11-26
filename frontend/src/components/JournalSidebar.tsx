'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';

const navItems = [
  { href: '/journal', label: 'Journal dashboard' },
  { href: '/journal/new', label: 'New entry' }
];

export default function JournalSidebar() {
  const pathname = usePathname();

  return (
    <nav className="space-y-2 px-4 py-6">
      <div className="text-xs uppercase tracking-[0.4em] text-gray-500 mb-4">Journal</div>
      <div className="space-y-1">
        {navItems.map(item => {
          const active = pathname === item.href;
          return (
            <Link
              key={item.href}
              href={item.href}
              className={`block rounded-2xl px-4 py-2 text-sm font-semibold transition ${
                active ? 'bg-blue text-white shadow-lg' : 'bg-white/60 text-gray-700 hover:bg-blue/10'
              }`}
            >
              {item.label}
            </Link>
          );
        })}
      </div>
    </nav>
  );
}
