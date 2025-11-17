import React, { useState } from 'react';
import { Calendar, TrendingUp, Zap, FileText, ArrowRight } from 'lucide-react';
import { Card } from './ui/card';
import { Badge } from './ui/badge';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { Tabs, TabsContent, TabsList, TabsTrigger } from './ui/tabs';
import { ImageWithFallback } from './figma/ImageWithFallback';

interface NewsPageProps {
  onNavigate: (page: string) => void;
}

export function NewsPage({ onNavigate }: NewsPageProps) {
  const [searchQuery, setSearchQuery] = useState('');

  const newsArticles = [
    {
      id: 1,
      title: 'Electric Vehicle Sales Surge 45% in Q4 2025',
      summary: 'The automotive industry witnesses unprecedented growth in EV adoption as manufacturers introduce more affordable models and charging infrastructure expands nationwide.',
      category: 'EV',
      date: '2025-10-28',
      image: 'https://images.unsplash.com/photo-1593941707874-ef25b8b4a92b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwyfHxlbGVjdHJpYyUyMHZlaGljbGV8ZW58MXx8fHwxNzYxNzQ3NDUzfDA&ixlib=rb-4.1.0&q=80&w=1080',
      readTime: '5 min read'
    },
    {
      id: 2,
      title: 'New Safety Standards BS6 Phase 3 Announced',
      summary: 'Government unveils stricter emission norms and enhanced safety requirements for all vehicles manufactured from 2026 onwards, pushing manufacturers to innovate.',
      category: 'Policy',
      date: '2025-10-27',
      image: 'https://images.unsplash.com/photo-1570829194611-71a926d70ff8?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxsdXh1cnklMjBzdXYlMjBjYXJ8ZW58MXx8fHwxNzYxNzg3ODk4fDA&ixlib=rb-4.1.0&q=80&w=1080',
      readTime: '7 min read'
    },
    {
      id: 3,
      title: 'Honda Launches Next-Gen Hybrid Technology',
      summary: 'Honda introduces revolutionary e:HEV hybrid system promising 40% better fuel efficiency while maintaining performance, setting new industry benchmarks.',
      category: 'Launch',
      date: '2025-10-26',
      image: 'https://images.unsplash.com/photo-1658662160331-62f7e52e63de?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxzZWRhbiUyMGNhcnxlbnwxfHx8fDE3NjE3MTY3MTZ8MA&ixlib=rb-4.1.0&q=80&w=1080',
      readTime: '6 min read'
    },
    {
      id: 4,
      title: 'SUV Market Dominates with 52% Share',
      summary: 'Latest market analysis reveals SUVs continue to capture consumer preference across all price segments, driven by safety features and road presence.',
      category: 'Market',
      date: '2025-10-25',
      image: 'https://images.unsplash.com/photo-1649793395985-967862a3b73f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxwaWNrdXAlMjB0cnVja3xlbnwxfHx8fDE3NjE3NTk5NDN8MA&ixlib=rb-4.1.0&q=80&w=1080',
      readTime: '4 min read'
    },
    {
      id: 5,
      title: 'Financing Options Expand for EV Buyers',
      summary: 'Major banks announce special low-interest loans for electric vehicle purchases, reducing financial barriers and accelerating EV adoption nationwide.',
      category: 'Finance',
      date: '2025-10-24',
      image: 'https://images.unsplash.com/photo-1593941707874-ef25b8b4a92b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwyfHxlbGVjdHJpYyUyMHZlaGljbGV8ZW58MXx8fHwxNzYxNzQ3NDUzfDA&ixlib=rb-4.1.0&q=80&w=1080',
      readTime: '5 min read'
    },
    {
      id: 6,
      title: 'Autonomous Driving Features in Mass Market',
      summary: 'Advanced driver assistance systems become standard in mid-segment vehicles as technology costs decrease and consumer demand grows.',
      category: 'Technology',
      date: '2025-10-23',
      image: 'https://images.unsplash.com/photo-1627280052756-cc5e080c8458?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxoYXRjaGJhY2slMjBjYXJ8ZW58MXx8fHwxNzYxODA2NzI1fDA&ixlib=rb-4.1.0&q=80&w=1080',
      readTime: '6 min read'
    }
  ];

  const trendingTopics = [
    { name: 'Electric Vehicles', count: 234, trend: 'up' },
    { name: 'Hybrid Technology', count: 189, trend: 'up' },
    { name: 'Safety Standards', count: 156, trend: 'stable' },
    { name: 'Fuel Prices', count: 142, trend: 'up' },
    { name: 'New Launches', count: 128, trend: 'up' }
  ];

  const getCategoryColor = (category: string) => {
    const colors: Record<string, string> = {
      'EV': 'bg-green-600',
      'Policy': 'bg-blue-600',
      'Launch': 'bg-purple-600',
      'Market': 'bg-orange-600',
      'Finance': 'bg-yellow-600',
      'Technology': 'bg-pink-600'
    };
    return colors[category] || 'bg-gray-600';
  };

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    const today = new Date('2025-10-30');
    const diffTime = Math.abs(today.getTime() - date.getTime());
    const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));
    
    if (diffDays === 0) return 'Today';
    if (diffDays === 1) return 'Yesterday';
    if (diffDays < 7) return `${diffDays} days ago`;
    return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
  };

  return (
    <div className="max-w-7xl mx-auto px-6 py-8">
      {/* Header */}
      <div className="mb-8">
        <h1 className="mb-2">AutoResearch News</h1>
        <p className="text-gray-600">
          Stay updated with the latest automotive news, launches, and market insights
        </p>
      </div>

      {/* Search & Filter */}
      <div className="flex flex-col md:flex-row gap-4 mb-8">
        <div className="flex-1">
          <Input
            type="text"
            placeholder="Search articles..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full"
          />
        </div>
        <Tabs defaultValue="all" className="w-full md:w-auto">
          <TabsList>
            <TabsTrigger value="all">All</TabsTrigger>
            <TabsTrigger value="ev">EV</TabsTrigger>
            <TabsTrigger value="finance">Finance</TabsTrigger>
            <TabsTrigger value="policy">Policy</TabsTrigger>
          </TabsList>
        </Tabs>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Main Content */}
        <div className="lg:col-span-2 space-y-6">
          {/* Featured Article */}
          <Card className="overflow-hidden">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-0">
              <div className="relative h-64 md:h-auto">
                <ImageWithFallback
                  src={newsArticles[0].image}
                  alt={newsArticles[0].title}
                  className="w-full h-full object-cover"
                />
                <Badge className={`absolute top-4 left-4 ${getCategoryColor(newsArticles[0].category)}`}>
                  Featured
                </Badge>
              </div>
              <div className="p-6 flex flex-col justify-between">
                <div>
                  <div className="flex items-center gap-2 mb-3">
                    <Badge className={getCategoryColor(newsArticles[0].category)}>
                      {newsArticles[0].category}
                    </Badge>
                    <span className="text-sm text-gray-600">{formatDate(newsArticles[0].date)}</span>
                  </div>
                  <h2 className="mb-3">{newsArticles[0].title}</h2>
                  <p className="text-gray-600 mb-4">{newsArticles[0].summary}</p>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-sm text-gray-500">{newsArticles[0].readTime}</span>
                  <Button variant="link" className="gap-2 p-0">
                    Read More <ArrowRight className="w-4 h-4" />
                  </Button>
                </div>
              </div>
            </div>
          </Card>

          {/* News Grid */}
          <div className="grid grid-cols-1 gap-6">
            {newsArticles.slice(1).map((article) => (
              <Card key={article.id} className="overflow-hidden hover:shadow-lg transition-shadow">
                <div className="grid grid-cols-1 md:grid-cols-3 gap-0">
                  <div className="relative h-48 md:h-auto">
                    <ImageWithFallback
                      src={article.image}
                      alt={article.title}
                      className="w-full h-full object-cover"
                    />
                  </div>
                  <div className="md:col-span-2 p-6">
                    <div className="flex items-center gap-2 mb-2">
                      <Badge className={getCategoryColor(article.category)}>
                        {article.category}
                      </Badge>
                      <span className="text-sm text-gray-600 flex items-center gap-1">
                        <Calendar className="w-3 h-3" />
                        {formatDate(article.date)}
                      </span>
                    </div>
                    <h3 className="mb-2">{article.title}</h3>
                    <p className="text-gray-600 mb-4 line-clamp-2">{article.summary}</p>
                    <div className="flex items-center justify-between">
                      <span className="text-sm text-gray-500">{article.readTime}</span>
                      <Button variant="link" className="gap-2 p-0">
                        Read More <ArrowRight className="w-4 h-4" />
                      </Button>
                    </div>
                  </div>
                </div>
              </Card>
            ))}
          </div>

          {/* Load More */}
          <div className="text-center">
            <Button variant="outline" size="lg">
              Load More Articles
            </Button>
          </div>
        </div>

        {/* Sidebar */}
        <div className="space-y-6">
          {/* Trending Topics */}
          <Card className="p-6">
            <div className="flex items-center gap-2 mb-4">
              <TrendingUp className="w-5 h-5 text-blue-600" />
              <h3>Trending Topics</h3>
            </div>
            <div className="space-y-3">
              {trendingTopics.map((topic, index) => (
                <div key={index} className="flex items-center justify-between py-2 border-b last:border-0">
                  <div>
                    <div className="flex items-center gap-2">
                      <span className="text-gray-600">{topic.name}</span>
                      {topic.trend === 'up' && (
                        <TrendingUp className="w-3 h-3 text-green-600" />
                      )}
                    </div>
                    <span className="text-xs text-gray-500">{topic.count} articles</span>
                  </div>
                </div>
              ))}
            </div>
          </Card>

          {/* New Launches */}
          <Card className="p-6">
            <div className="flex items-center gap-2 mb-4">
              <Zap className="w-5 h-5 text-purple-600" />
              <h3>New Launches</h3>
            </div>
            <div className="space-y-4">
              <div>
                <div className="mb-1">Mahindra XUV700 Facelift</div>
                <p className="text-sm text-gray-600">Expected: Nov 2025</p>
              </div>
              <div>
                <div className="mb-1">Tata Harrier EV</div>
                <p className="text-sm text-gray-600">Expected: Dec 2025</p>
              </div>
              <div>
                <div className="mb-1">Honda Elevate Hybrid</div>
                <p className="text-sm text-gray-600">Expected: Jan 2026</p>
              </div>
            </div>
          </Card>

          {/* Policy Updates */}
          <Card className="p-6 bg-blue-50 border-blue-200">
            <div className="flex items-center gap-2 mb-4">
              <FileText className="w-5 h-5 text-blue-600" />
              <h3>Policy Updates</h3>
            </div>
            <div className="space-y-3 text-sm">
              <div className="pb-3 border-b border-blue-200">
                <p className="text-blue-900 mb-1">EV Subsidy Extended</p>
                <p className="text-blue-700">Government extends FAME II scheme till March 2026</p>
              </div>
              <div>
                <p className="text-blue-900 mb-1">Emission Norms</p>
                <p className="text-blue-700">BS6 Phase 3 implementation deadline announced</p>
              </div>
            </div>
          </Card>

          {/* Newsletter Signup */}
          <Card className="p-6 bg-gradient-to-br from-purple-50 to-blue-50">
            <h3 className="mb-2">Stay Updated</h3>
            <p className="text-sm text-gray-600 mb-4">
              Get the latest automotive news delivered to your inbox
            </p>
            <Input type="email" placeholder="Enter your email" className="mb-3" />
            <Button className="w-full">Subscribe</Button>
          </Card>
        </div>
      </div>
    </div>
  );
}
