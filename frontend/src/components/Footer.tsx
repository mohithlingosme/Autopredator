import Link from 'next/link';
import { Facebook, Instagram, Linkedin } from 'lucide-react';

const footerLinks = [
  { href: '/about', label: 'About' },
  { href: '/contact', label: 'Contact' },
  { href: '/terms', label: 'Terms' },
  { href: '/privacy', label: 'Privacy' },
  { href: '/careers', label: 'Careers' },
  { href: '/help', label: 'Help Center' }
];

export default function Footer() {
  return (
    <footer className="bg-charcoal text-white py-10 mt-16">
      <div className="container mx-auto px-4">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
          <div>
            <h3 className="text-lg font-bold mb-4">Autopredator</h3>
            <p className="text-gray-300">
              Find. Compare. Own Smarter. Research, compare and manage the entire vehicle ownership journey from a single
              dashboard.
            </p>
          </div>

          <div>
            <h4 className="text-md font-semibold mb-4">Quick Links</h4>
            <ul className="space-y-2">
              {footerLinks.map(link => (
                <li key={link.href}>
                  <Link href={link.href} className="text-gray-300 hover:text-neon-green transition-colors">
                    {link.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          <div>
            <h4 className="text-md font-semibold mb-4">Products</h4>
            <ul className="space-y-2 text-gray-300">
              <li>AutoNew</li>
              <li>AutoUsed</li>
              <li>AutoCare</li>
              <li>AutoFinance</li>
            </ul>
          </div>

          <div>
            <h4 className="text-md font-semibold mb-4">Connect</h4>
            <div className="flex space-x-4">
              <a href="https://facebook.com" className="text-gray-300 hover:text-neon-green" aria-label="Facebook">
                <Facebook className="w-5 h-5" />
              </a>
              <a href="https://linkedin.com" className="text-gray-300 hover:text-neon-green" aria-label="LinkedIn">
                <Linkedin className="w-5 h-5" />
              </a>
              <a href="https://instagram.com" className="text-gray-300 hover:text-neon-green" aria-label="Instagram">
                <Instagram className="w-5 h-5" />
              </a>
            </div>
          </div>
        </div>

        <div className="border-t border-gray-700 mt-10 pt-6 flex flex-col md:flex-row items-center justify-between text-sm text-gray-400">
          <p>© 2025 Autopredator Vehicle Research</p>
          <p className="mt-2 md:mt-0">Made for enthusiasts, dealers and enterprise fleets.</p>
        </div>
      </div>
    </footer>
  );
}
