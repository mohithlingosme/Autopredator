'use client';

import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';
import { useState } from 'react';
import { Menu, Scale, Search } from 'lucide-react';

const navLinks = [
  { href: '/dashboard', label: 'Dashboard' },
  { href: '/vehicles', label: 'Vehicles' },
  { href: '/fleet', label: 'Fleet' },
  { href: '/marketplace', label: 'Marketplace' },
  { href: '/insights', label: 'Insights' }
];

export default function Header() {
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const [compareCount, setCompareCount] = useState(0);
  const [searchValue, setSearchValue] = useState('');
  const pathname = usePathname();
  const router = useRouter();

  const handleSearch = (event: React.FormEvent) => {
    event.preventDefault();
    if (searchValue.trim()) {
      router.push(`/search?query=${encodeURIComponent(searchValue.trim())}`);
      setIsMenuOpen(false);
    }
  };

  return (
    <header className="bg-charcoal text-white shadow-lg sticky top-0 z-40">
      <div className="container mx-auto px-4 py-4 flex items-center justify-between gap-4">
        <Link href="/" className="text-2xl font-bold text-neon-green tracking-tight">
          Autopredator
        </Link>

        <form onSubmit={handleSearch} className="hidden md:flex items-center bg-white/10 rounded-full px-4 py-2 flex-1 max-w-xl">
          <Search className="w-5 h-5 text-gray-300 mr-2" />
          <input
            type="search"
            value={searchValue}
            onChange={event => setSearchValue(event.target.value)}
            placeholder="Search New, Used, Services..."
            className="flex-1 bg-transparent outline-none placeholder:text-gray-300"
          />
        </form>

        <div className="hidden md:flex items-center space-x-4">
          <button
            type="button"
            className="flex items-center gap-2 btn-primary"
            onClick={() => setCompareCount(count => Math.min(count + 1, 4))}
          >
            <Scale className="w-4 h-4" />
            Compare ({compareCount})
          </button>
          <div className="flex items-center gap-3 rounded-full border border-white/10 bg-white/10 px-4 py-2 text-sm text-white">
            <div className="flex h-8 w-8 items-center justify-center rounded-full bg-blue-600 text-xs font-semibold uppercase">
              AU
            </div>
            <div className="flex flex-col leading-tight">
              <span className="font-semibold">Guest</span>
              <span className="text-xs text-white/70">Owner account</span>
            </div>
          </div>
          <button
            type="button"
            onClick={() => router.push('/login')}
            className="btn-secondary px-4 py-2 text-sm"
          >
            Logout
          </button>
        </div>

        <button
          className="md:hidden p-2 rounded-md bg-white/10"
          onClick={() => setIsMenuOpen(prev => !prev)}
          aria-label="Toggle navigation"
        >
          <Menu className="w-6 h-6" />
        </button>
      </div>

      <nav className="hidden md:block bg-gray-900/80 backdrop-blur border-t border-white/10">
        <div className="container mx-auto px-4">
          <ul className="flex items-center justify-between text-sm tracking-wide">
            {navLinks.map(link => (
              <li key={link.href}>
                <Link
                  href={link.href}
                  className={`inline-flex items-center py-3 px-3 border-b-2 transition-colors ${
                    pathname === link.href ? 'border-neon-green text-neon-green' : 'border-transparent hover:border-white/30'
                  }`}
                >
                  {link.label}
                </Link>
              </li>
            ))}
          </ul>
        </div>
      </nav>

      {isMenuOpen && (
        <nav className="md:hidden bg-gray-900 border-t border-white/10">
          <form onSubmit={handleSearch} className="flex items-center bg-white/10 rounded-lg px-4 py-2 mx-4 my-4">
            <Search className="w-4 h-4 text-gray-300 mr-2" />
            <input
              type="search"
              value={searchValue}
              onChange={event => setSearchValue(event.target.value)}
              placeholder="Search vehicles or services"
              className="flex-1 bg-transparent outline-none text-white placeholder:text-gray-300"
            />
          </form>
          <ul className="space-y-1 px-4 pb-4">
            {navLinks.map(link => (
              <li key={link.href}>
                <Link
                  href={link.href}
                  className="block w-full py-2 text-white/80 hover:text-white"
                  onClick={() => setIsMenuOpen(false)}
                >
                  {link.label}
                </Link>
              </li>
            ))}
          </ul>
          <div className="border-t border-white/10 px-4 pb-4 pt-2">
            <button
              type="button"
              onClick={() => {
                router.push('/login');
                setIsMenuOpen(false);
              }}
              className="w-full rounded-full border border-white/30 px-4 py-2 text-sm text-white"
            >
              Logout
            </button>
          </div>
        </nav>
      )}
    </header>
  );
}
