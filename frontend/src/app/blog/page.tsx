import Link from 'next/link';

import { BlogPost } from '@/types';

const blogPosts: BlogPost[] = [
  {
    id: 201,
    title: 'How AI and IoT shape predictive maintenance',
    summary: 'Monitoring mileage, service history, and alerts streams to keep fleets mission-ready.',
    content: 'The Autopredator platform aggregates telematics, maintenance logs, and service data to recommend actions before issues become urgent.',
    author: 'Autopredator Team',
    hero_image: '',
    tags: ['insights', 'maintenance'],
    created_at: new Date().toISOString()
  },
  {
    id: 202,
    title: 'Reducing total cost of ownership for commercial fleets',
    summary: 'Financiers crave reliable predictions, so we built dashboards that correlate spend vs usage.',
    content: 'We combine cost trend analytics with AI predictions to find vehicles that deliver the most uptime per lakh invested.',
    author: 'Insight Lab',
    hero_image: '',
    tags: ['finance', 'fleet'],
    created_at: new Date().toISOString()
  },
  {
    id: 203,
    title: 'Scaling digital compliance across cities',
    summary: 'Alerts for registration, insurance, and compliance deadlines help operators stay on schedule.',
    content: 'Autopredator syncs with document trackers and service providers to remind the right people ahead of time.',
    author: 'Compliance Desk',
    hero_image: '',
    tags: ['compliance', 'operations'],
    created_at: new Date().toISOString()
  }
];

export default function BlogPage() {
  const featured = blogPosts[0];

  return (
    <div className="container mx-auto px-4 py-10 space-y-10">
      <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <div>
          <p className="text-xs uppercase tracking-[0.3em] text-gray-500">Blog</p>
          <h1 className="text-4xl font-bold text-charcoal">Autopredator News & Insights</h1>
          <p className="text-gray-600 max-w-2xl">
            Learn how modern fleets combine AI, analytics, and compliance into a single line of sight.
          </p>
        </div>
        <Link href="/forum" className="btn-secondary">
          Join the discussion
        </Link>
      </div>

      {featured && (
        <div className="card overflow-hidden">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-0">
            <div className="h-64 md:h-full bg-gradient-to-br from-charcoal to-blue" />
            <div className="p-8 space-y-4">
              <p className="text-neon-green uppercase text-xs tracking-[0.3em]">{featured.tags?.[0]}</p>
              <h2 className="text-3xl font-bold">{featured.title}</h2>
              <p className="text-gray-600">{featured.summary}</p>
              <div className="text-sm text-gray-500">
                {featured.author} | {new Date(featured.created_at).toLocaleDateString()}
              </div>
              <Link href={`/blog/${featured.id}`} className="btn-primary w-fit">
                Read Article
              </Link>
            </div>
          </div>
        </div>
      )}

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {blogPosts.slice(1).map(post => (
          <article key={post.id} className="card hover:-translate-y-1 transition-transform">
            <div className="h-44 bg-gray-100" />
            <div className="p-6 space-y-3">
              <p className="text-sm text-neon-green uppercase tracking-[0.3em]">{post.tags?.[0]}</p>
              <h3 className="text-xl font-semibold">{post.title}</h3>
              <p className="text-gray-600 text-sm line-clamp-3">{post.summary}</p>
              <Link href={`/blog/${post.id}`} className="text-blue text-sm">
                Read More -{'>'}
              </Link>
            </div>
          </article>
        ))}
      </div>
    </div>
  );
}
