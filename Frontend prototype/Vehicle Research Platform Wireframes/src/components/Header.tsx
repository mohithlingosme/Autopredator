import React from 'react';
import { Search, GitCompare, Menu, User } from 'lucide-react';
import { Button } from './ui/button';
import { Input } from './ui/input';

interface HeaderProps {
  currentPage: string;
  onNavigate: (page: string) => void;
}

export function Header({ currentPage, onNavigate }: HeaderProps) {
  return (
    <header className="border-b border-gray-200 bg-white sticky top-0 z-50">
      <div className="max-w-7xl mx-auto px-6 py-4">
        <div className="flex items-center justify-between gap-4">
          {/* Logo */}
          <button 
            onClick={() => onNavigate('home')}
            className="flex items-center gap-2 cursor-pointer"
          >
            <div className="w-8 h-8 bg-blue-600 rounded flex items-center justify-center">
              <span className="text-white">AP</span>
            </div>
            <span className="hidden md:block">Autopredator</span>
          </button>

          {/* Search Bar */}
          <div className="flex-1 max-w-2xl relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
            <Input
              type="text"
              placeholder="Search vehicles by brand, model, type..."
              className="pl-10 w-full"
            />
          </div>

          {/* Navigation */}
          <nav className="hidden md:flex items-center gap-2">
            <Button
              variant={currentPage === 'listing' ? 'default' : 'ghost'}
              onClick={() => onNavigate('listing')}
            >
              New
            </Button>
            <Button
              variant={currentPage === 'used-listing' ? 'default' : 'ghost'}
              onClick={() => onNavigate('used-listing')}
            >
              Used
            </Button>
            <Button
              variant={currentPage === 'compare' ? 'default' : 'ghost'}
              onClick={() => onNavigate('compare')}
              className="gap-2"
            >
              <GitCompare className="w-4 h-4" />
              Compare
            </Button>
            <Button
              variant={currentPage === 'services' ? 'default' : 'ghost'}
              onClick={() => onNavigate('services')}
            >
              Services
            </Button>
            <Button
              variant={currentPage === 'news' ? 'default' : 'ghost'}
              onClick={() => onNavigate('news')}
            >
              Blog
            </Button>
            <Button
              variant={currentPage === 'forum' ? 'default' : 'ghost'}
              onClick={() => onNavigate('forum')}
            >
              Forum
            </Button>
            <Button 
              variant={currentPage === 'profile' ? 'default' : 'ghost'} 
              className="gap-2"
              onClick={() => onNavigate('profile')}
            >
              <User className="w-4 h-4" />
              Profile
            </Button>
          </nav>

          {/* Mobile Menu */}
          <Button variant="ghost" className="md:hidden">
            <Menu className="w-5 h-5" />
          </Button>
        </div>
      </div>
    </header>
  );
}
