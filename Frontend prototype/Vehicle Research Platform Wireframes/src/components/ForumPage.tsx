import React, { useState } from 'react';
import { MessageSquare, TrendingUp, User, Eye, Clock, Plus, Search } from 'lucide-react';
import { Card } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Input } from './ui/input';
import { Tabs, TabsContent, TabsList, TabsTrigger } from './ui/tabs';
import { Avatar } from './ui/avatar';

interface ForumPageProps {
  onNavigate: (page: string) => void;
}

export function ForumPage({ onNavigate }: ForumPageProps) {
  const [searchQuery, setSearchQuery] = useState('');

  const forumPosts = [
    {
      id: 1,
      title: 'Hyundai Creta vs Kia Seltos - Real Owner Experience',
      author: 'RohitSharma',
      authorRating: 4.8,
      category: 'Buying Advice',
      replies: 45,
      views: 2340,
      lastActivity: '2 hours ago',
      solved: true
    },
    {
      id: 2,
      title: 'Tata Nexon EV - 1 Year Ownership Review',
      author: 'EVEnthusiast',
      authorRating: 4.9,
      category: 'EV Owners',
      replies: 67,
      views: 4560,
      lastActivity: '5 hours ago',
      solved: false
    },
    {
      id: 3,
      title: 'Best Service Center for Honda City in Bangalore?',
      author: 'BangaloreDriver',
      authorRating: 4.3,
      category: 'Technical',
      replies: 23,
      views: 890,
      lastActivity: '1 day ago',
      solved: true
    },
    {
      id: 4,
      title: 'Insurance Claim Process - Step by Step Guide',
      author: 'AutoExpert',
      authorRating: 4.9,
      category: 'General',
      replies: 89,
      views: 6780,
      lastActivity: '3 hours ago',
      solved: false
    },
    {
      id: 5,
      title: 'Maruti Swift vs Hyundai i20 - Which One to Buy?',
      author: 'FirstTimeBuyer',
      authorRating: 4.1,
      category: 'Buying Advice',
      replies: 56,
      views: 3240,
      lastActivity: '6 hours ago',
      solved: true
    },
    {
      id: 6,
      title: 'DIY: How to Change Engine Oil at Home',
      author: 'MechanicPro',
      authorRating: 4.7,
      category: 'Technical',
      replies: 34,
      views: 1890,
      lastActivity: '2 days ago',
      solved: false
    },
    {
      id: 7,
      title: 'Weekend Road Trip Suggestions from Delhi',
      author: 'TravelLover',
      authorRating: 4.5,
      category: 'Off-Topic',
      replies: 78,
      views: 5670,
      lastActivity: '8 hours ago',
      solved: false
    },
    {
      id: 8,
      title: 'Comparing EV Charging Networks in India',
      author: 'GreenDrive',
      authorRating: 4.8,
      category: 'EV Owners',
      replies: 42,
      views: 2890,
      lastActivity: '12 hours ago',
      solved: false
    }
  ];

  const topContributors = [
    { name: 'AutoExpert', posts: 342, helpful: 289, rating: 4.9 },
    { name: 'EVEnthusiast', posts: 267, helpful: 234, rating: 4.9 },
    { name: 'MechanicPro', posts: 198, helpful: 176, rating: 4.7 },
    { name: 'RohitSharma', posts: 156, helpful: 142, rating: 4.8 },
    { name: 'BangaloreDriver', posts: 134, helpful: 98, rating: 4.3 }
  ];

  const hotThreads = [
    { title: 'Best time to buy a car in 2025', replies: 123 },
    { title: 'EV vs Petrol - Cost Analysis', replies: 98 },
    { title: 'Insurance premium hike discussion', replies: 87 },
    { title: 'New vehicle launch predictions', replies: 76 }
  ];

  return (
    <div>
      {/* Hero Section */}
      <div className="bg-gradient-to-r from-[#2C2C2C] to-[#007BFF] text-white py-12">
        <div className="max-w-7xl mx-auto px-6">
          <div className="flex items-center gap-3 mb-4">
            <MessageSquare className="w-8 h-8" />
            <h1>AutoSocial Community</h1>
          </div>
          <p className="text-xl text-gray-200 mb-6">
            Connect with fellow vehicle owners, share experiences, and get expert advice
          </p>
          <div className="flex gap-4">
            <Input
              type="text"
              placeholder="Search topics or discussions..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="max-w-md bg-white text-gray-900"
            />
            <Button variant="secondary" className="gap-2">
              <Plus className="w-4 h-4" />
              Start Discussion
            </Button>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-6 py-8">
        <div className="grid grid-cols-1 lg:grid-cols-4 gap-8">
          {/* Main Content */}
          <div className="lg:col-span-3">
            <Tabs defaultValue="all">
              <TabsList className="w-full justify-start mb-6">
                <TabsTrigger value="all">All Discussions</TabsTrigger>
                <TabsTrigger value="general">General</TabsTrigger>
                <TabsTrigger value="technical">Technical</TabsTrigger>
                <TabsTrigger value="buying">Buying Advice</TabsTrigger>
                <TabsTrigger value="ev">EV Owners</TabsTrigger>
                <TabsTrigger value="offtopic">Off-Topic</TabsTrigger>
              </TabsList>

              <TabsContent value="all">
                <div className="space-y-4">
                  {forumPosts.map((post) => (
                    <Card key={post.id} className="p-6 hover:shadow-lg transition-shadow cursor-pointer">
                      <div className="flex gap-4">
                        {/* Avatar */}
                        <div className="flex-shrink-0">
                          <div className="w-12 h-12 bg-gradient-to-br from-[#007BFF] to-[#2C2C2C] rounded-full flex items-center justify-center text-white">
                            {post.author[0]}
                          </div>
                        </div>

                        {/* Content */}
                        <div className="flex-1">
                          <div className="flex items-start justify-between mb-2">
                            <div>
                              <h3 className="mb-1 hover:text-[#007BFF]">{post.title}</h3>
                              <div className="flex items-center gap-3 text-sm text-gray-600">
                                <div className="flex items-center gap-1">
                                  <User className="w-3 h-3" />
                                  <span>{post.author}</span>
                                </div>
                                <Badge variant="outline">{post.category}</Badge>
                                {post.solved && (
                                  <Badge className="bg-[#39FF14] text-[#2C2C2C]">Solved</Badge>
                                )}
                              </div>
                            </div>
                          </div>

                          <div className="flex items-center gap-6 text-sm text-gray-600">
                            <div className="flex items-center gap-1">
                              <MessageSquare className="w-4 h-4" />
                              <span>{post.replies} replies</span>
                            </div>
                            <div className="flex items-center gap-1">
                              <Eye className="w-4 h-4" />
                              <span>{post.views.toLocaleString()} views</span>
                            </div>
                            <div className="flex items-center gap-1">
                              <Clock className="w-4 h-4" />
                              <span>{post.lastActivity}</span>
                            </div>
                          </div>
                        </div>
                      </div>
                    </Card>
                  ))}
                </div>

                {/* Pagination */}
                <div className="flex items-center justify-center gap-2 mt-8">
                  <Button variant="outline" size="sm">Previous</Button>
                  <Button variant="default" size="sm">1</Button>
                  <Button variant="outline" size="sm">2</Button>
                  <Button variant="outline" size="sm">3</Button>
                  <Button variant="outline" size="sm">Next</Button>
                </div>
              </TabsContent>

              <TabsContent value="general">
                <p className="text-gray-600">General discussions filtered...</p>
              </TabsContent>

              <TabsContent value="technical">
                <p className="text-gray-600">Technical discussions filtered...</p>
              </TabsContent>

              <TabsContent value="buying">
                <p className="text-gray-600">Buying advice discussions filtered...</p>
              </TabsContent>

              <TabsContent value="ev">
                <p className="text-gray-600">EV owner discussions filtered...</p>
              </TabsContent>

              <TabsContent value="offtopic">
                <p className="text-gray-600">Off-topic discussions filtered...</p>
              </TabsContent>
            </Tabs>
          </div>

          {/* Sidebar */}
          <div className="space-y-6">
            {/* Top Contributors */}
            <Card className="p-6">
              <div className="flex items-center gap-2 mb-4">
                <TrendingUp className="w-5 h-5 text-[#007BFF]" />
                <h3>Top Contributors</h3>
              </div>
              <div className="space-y-4">
                {topContributors.map((contributor, index) => (
                  <div key={index} className="flex items-center gap-3">
                    <div className="w-10 h-10 bg-gradient-to-br from-[#007BFF] to-[#2C2C2C] rounded-full flex items-center justify-center text-white">
                      {index + 1}
                    </div>
                    <div className="flex-1">
                      <div className="mb-1">{contributor.name}</div>
                      <div className="text-xs text-gray-600">
                        {contributor.posts} posts • {contributor.helpful} helpful
                      </div>
                    </div>
                    <div className="flex items-center gap-1 text-sm">
                      <span className="text-yellow-400">★</span>
                      <span>{contributor.rating}</span>
                    </div>
                  </div>
                ))}
              </div>
            </Card>

            {/* Hot Threads */}
            <Card className="p-6">
              <h3 className="mb-4">Hot Threads</h3>
              <div className="space-y-3">
                {hotThreads.map((thread, index) => (
                  <div key={index} className="pb-3 border-b last:border-0 cursor-pointer hover:text-[#007BFF]">
                    <div className="mb-1 text-sm">{thread.title}</div>
                    <div className="text-xs text-gray-600">{thread.replies} replies</div>
                  </div>
                ))}
              </div>
            </Card>

            {/* Community CTA */}
            <Card className="p-6 bg-gradient-to-br from-[#007BFF] to-[#2C2C2C] text-white">
              <h3 className="mb-2">Join the Community</h3>
              <p className="text-sm mb-4 text-gray-200">
                Share your experiences and help others make informed decisions
              </p>
              <Button variant="secondary" className="w-full">
                Create Account
              </Button>
            </Card>
          </div>
        </div>
      </div>
    </div>
  );
}
