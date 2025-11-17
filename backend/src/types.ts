export type VehicleType = 'new' | 'used';

export interface Vehicle {
  id: number;
  name: string;
  brand: string;
  segment?: string;
  type: VehicleType;
  fuel_type?: string;
  body_type?: string;
  transmission?: string;
  seating_capacity?: number;
  price_min?: number;
  price_max?: number;
  currency?: string;
  rating?: number;
  image_url?: string;
  thumbnail_url?: string;
  specs: Record<string, unknown>;
  features: Record<string, unknown>;
  performance?: Record<string, unknown>;
  dimensions?: Record<string, unknown>;
  safety_rating?: number;
  categories?: string[];
  is_featured?: boolean;
}

export interface VehicleListing {
  id: number;
  vehicle_id: number;
  seller_id: number;
  km_driven: number;
  year: number;
  asking_price: number;
  condition: string;
  city: string;
  owner_type: string;
  verified: boolean;
  documents: Array<{ title: string; status: string }>;
  service_score: number;
}

export interface ServiceHistoryItem {
  id: number;
  vehicle_listing_id: number;
  service_date: string;
  description: string;
  mileage: number;
  cost: number;
}

export interface BlogPost {
  id: number;
  title: string;
  summary: string;
  content: string;
  author: string;
  hero_image: string;
  tags: string[];
  created_at: string;
}

export interface ForumPost {
  id: number;
  user_id: number;
  category: string;
  title: string;
  content: string;
  tags: string[];
  views: number;
  created_at: string;
}

export interface ForumReply {
  id: number;
  user_id: number;
  post_id: number;
  content: string;
  created_at: string;
}

export interface UserProfile {
  id: number;
  email: string;
  name: string;
  avatar_url?: string;
}

export interface AiInsight {
  vehicleId: number;
  resaleValue: number;
  confidence: number;
  fairValue: number;
  message: string;
}
