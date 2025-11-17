import React from 'react';
import { Facebook, Twitter, Instagram, Linkedin, Youtube } from 'lucide-react';

export function Footer() {
  return (
    <footer className="bg-gray-900 text-gray-300 mt-16">
      <div className="max-w-7xl mx-auto px-6 py-12">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-8 mb-8">
          {/* About */}
          <div>
            <h3 className="text-white mb-4">About Autopredator</h3>
            <p className="text-sm">
              Your trusted platform for vehicle research, comparison, and AI-powered insights.
            </p>
          </div>

          {/* Quick Links */}
          <div>
            <h3 className="text-white mb-4">Quick Links</h3>
            <ul className="space-y-2 text-sm">
              <li><a href="#" className="hover:text-white">Browse Vehicles</a></li>
              <li><a href="#" className="hover:text-white">Compare</a></li>
              <li><a href="#" className="hover:text-white">AI Insights</a></li>
              <li><a href="#" className="hover:text-white">News & Updates</a></li>
            </ul>
          </div>

          {/* Support */}
          <div>
            <h3 className="text-white mb-4">Support</h3>
            <ul className="space-y-2 text-sm">
              <li><a href="#" className="hover:text-white">Help Center</a></li>
              <li><a href="#" className="hover:text-white">Contact Us</a></li>
              <li><a href="#" className="hover:text-white">Careers</a></li>
              <li><a href="#" className="hover:text-white">Terms & Privacy</a></li>
            </ul>
          </div>

          {/* Connect */}
          <div>
            <h3 className="text-white mb-4">Connect With Us</h3>
            <div className="flex gap-4">
              <a href="#" className="hover:text-white">
                <Facebook className="w-5 h-5" />
              </a>
              <a href="#" className="hover:text-white">
                <Twitter className="w-5 h-5" />
              </a>
              <a href="#" className="hover:text-white">
                <Instagram className="w-5 h-5" />
              </a>
              <a href="#" className="hover:text-white">
                <Linkedin className="w-5 h-5" />
              </a>
              <a href="#" className="hover:text-white">
                <Youtube className="w-5 h-5" />
              </a>
            </div>
          </div>
        </div>

        <div className="border-t border-gray-800 pt-8 text-center text-sm">
          <p>© 2025 Autopredator Vehicle Research. All rights reserved.</p>
        </div>
      </div>
    </footer>
  );
}
