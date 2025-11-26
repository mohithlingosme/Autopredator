'use client';

import Link from 'next/link';
import { ChevronRight, Menu } from 'lucide-react';
import Button from './Button';

interface JournalTopNavProps {
  title?: string;
  breadcrumbs?: Array<{ label: string; href?: string }>;
  onMenuClick?: () => void;
}

export default function JournalTopNav({ title = 'Journal', breadcrumbs = [], onMenuClick }: JournalTopNavProps) {
  return (
    <header className="flex flex-col gap-3 border-b border-gray-200 bg-white/80 px-6 py-4 shadow-sm">
      <div className="flex items-center justify-between">
        <div className="flex items-center">
          {onMenuClick && (
            <Button
              variant="outline"
              size="sm"
              onClick={onMenuClick}
              className="mr-4 lg:hidden p-2"
              aria-label="Open menu"
            >
              <Menu className="h-4 w-4" />
            </Button>
          )}
          <div>
            <p className="text-xs uppercase tracking-[0.4em] text-gray-400">Workspace</p>
            <h1 className="text-2xl font-semibold text-charcoal">{title}</h1>
          </div>
        </div>
        <Link href="/journal/new" className="btn-primary hover:bg-blue/90">
          + New entry
        </Link>
      </div>
      {breadcrumbs.length > 0 && (
        <div className="flex items-center gap-2 text-xs font-medium text-gray-500">
          {breadcrumbs.map((crumb, index) => (
            <span key={crumb.label} className="flex items-center gap-1">
              {crumb.href ? <Link href={crumb.href}>{crumb.label}</Link> : <span>{crumb.label}</span>}
              {index < breadcrumbs.length - 1 && <ChevronRight className="h-3 w-3" />}
            </span>
          ))}
        </div>
      )}
    </header>
  );
}
