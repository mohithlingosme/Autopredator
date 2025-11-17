import Link from 'next/link';
import { API_BASE_URL } from '@/lib/utils';
import { BlogPost } from '@/types';

async function getBlogs(): Promise<BlogPost[]> {
  const response = await fetch(`${API_BASE_URL}/api/blogs`, { cache: 'no-store' });
  return response.json();
}

export default async function BlogPage() {
  const blogPosts = await getBlogs();
  const featured = blogPosts[0];

  return (
    <div className="container mx-auto px-4 py-10 space-y-10">
      <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <div>
          <p className="text-xs uppercase tracking-[0.3em] text-gray-500">Page 8</p>
          <h1 className="text-4xl font-bold text-charcoal">Autopredator Blog & News Hub</h1>
          <p className="text-gray-600 max-w-2xl">Research-backed automotive stories, policy analysis, and data-led launch coverage.</p>
        </div>
        <Link href="/forum" className="btn-secondary">
          Join Forum
        </Link>
      </div>

      {featured && (
        <div className="card overflow-hidden">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-0">
            <div className="h-64 md:h-full bg-gray-100" />
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
