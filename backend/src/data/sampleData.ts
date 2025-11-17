import { AiInsight, BlogPost, ForumPost, ForumReply, ServiceHistoryItem, Vehicle, VehicleListing } from '../types';

const vehicles: Vehicle[] = [
  {
    id: 1,
    name: 'Toyota Camry Hybrid',
    brand: 'Toyota',
    segment: 'Premium Sedan',
    type: 'new',
    fuel_type: 'Hybrid',
    body_type: 'Sedan',
    transmission: 'Automatic',
    seating_capacity: 5,
    price_min: 3250000,
    price_max: 4150000,
    currency: 'INR',
    rating: 4.7,
    image_url: '/images/camry.jpg',
    specs: {
      mileage: '23 kmpl',
      power: '176 bhp',
      torque: '221 Nm'
    },
    features: {
      highlights: ['ADAS Level 2', 'Ventilated Seats', 'Wireless Charging']
    },
    performance: { '0-100': '8.3s' },
    dimensions: { length: '4885mm', width: '1840mm' },
    safety_rating: 5,
    categories: ['cars', 'hybrid'],
    is_featured: true
  },
  {
    id: 2,
    name: 'Hyundai Creta EV',
    brand: 'Hyundai',
    type: 'new',
    segment: 'Compact SUV',
    fuel_type: 'Electric',
    body_type: 'SUV',
    transmission: 'Automatic',
    seating_capacity: 5,
    price_min: 2200000,
    price_max: 2800000,
    currency: 'INR',
    rating: 4.6,
    image_url: '/images/creta-ev.jpg',
    specs: { range: '450 km', charging: '80% in 50 mins' },
    features: { highlights: ['360 Camera', 'Panoramic Sunroof'] },
    performance: { '0-100': '7.8s' },
    dimensions: { length: '4300mm', width: '1790mm' },
    safety_rating: 4.5,
    categories: ['cars', 'ev'],
    is_featured: true
  },
  {
    id: 3,
    name: 'Mahindra Scorpio-N',
    brand: 'Mahindra',
    type: 'used',
    segment: 'Full-Size SUV',
    fuel_type: 'Diesel',
    body_type: 'SUV',
    transmission: 'Manual',
    seating_capacity: 7,
    price_min: 1500000,
    price_max: 1850000,
    currency: 'INR',
    rating: 4.5,
    image_url: '/images/scorpio.jpg',
    specs: { mileage: '14 kmpl', power: '200 bhp' },
    features: { highlights: ['4x4', 'Connected car tech'] },
    safety_rating: 4.2,
    categories: ['cars', 'suv'],
    is_featured: true
  },
  {
    id: 4,
    name: 'Tata Nexon EV Max',
    brand: 'Tata',
    type: 'used',
    segment: 'Compact SUV',
    fuel_type: 'Electric',
    body_type: 'SUV',
    transmission: 'Automatic',
    seating_capacity: 5,
    price_min: 1500000,
    price_max: 1900000,
    currency: 'INR',
    rating: 4.4,
    image_url: '/images/nexon-ev.jpg',
    specs: { range: '421 km', charging: '80% in 50 mins' },
    features: { highlights: ['Regen Braking', 'Fast Charging'] },
    categories: ['cars', 'ev'],
    is_featured: false
  }
];

const vehicleListings: VehicleListing[] = [
  {
    id: 101,
    vehicle_id: 3,
    seller_id: 1,
    km_driven: 25000,
    year: 2021,
    asking_price: 1750000,
    condition: 'Excellent',
    city: 'Bengaluru',
    owner_type: 'First Owner',
    verified: true,
    documents: [
      { title: 'RC', status: 'verified' },
      { title: 'Insurance', status: 'valid' }
    ],
    service_score: 4.7
  },
  {
    id: 102,
    vehicle_id: 4,
    seller_id: 2,
    km_driven: 18000,
    year: 2022,
    asking_price: 1650000,
    condition: 'Good',
    city: 'Mumbai',
    owner_type: 'Second Owner',
    verified: false,
    documents: [
      { title: 'RC', status: 'verified' },
      { title: 'Battery Health', status: 'pending' }
    ],
    service_score: 4.2
  }
];

const serviceHistory: ServiceHistoryItem[] = [
  {
    id: 1,
    vehicle_listing_id: 101,
    service_date: '2024-03-12',
    description: 'Full body check + consumables',
    mileage: 23000,
    cost: 8500
  },
  {
    id: 2,
    vehicle_listing_id: 101,
    service_date: '2023-09-22',
    description: 'Brake pad replacement',
    mileage: 18000,
    cost: 6200
  },
  {
    id: 3,
    vehicle_listing_id: 102,
    service_date: '2024-01-10',
    description: 'Battery health diagnostics',
    mileage: 15000,
    cost: 4500
  }
];

const blogPosts: BlogPost[] = [
  {
    id: 1,
    title: 'EV Adoption Outlook 2025',
    summary: 'A quick look at how EV infrastructure is shaping up in India.',
    content: 'Long-form blog content...',
    author: 'Team Autopredator',
    hero_image: '/images/blog-ev.jpg',
    tags: ['EV', 'Policy'],
    created_at: new Date().toISOString()
  },
  {
    id: 2,
    title: 'SUV Showdown: Scorpio Vs Fortuner',
    summary: 'We pit the crowd favourites together across 10 parameters.',
    content: 'Long-form blog content...',
    author: 'Expert Panel',
    hero_image: '/images/blog-suv.jpg',
    tags: ['SUV', 'Comparison'],
    created_at: new Date().toISOString()
  }
];

const forumPosts: ForumPost[] = [
  {
    id: 1,
    user_id: 1,
    category: 'buying',
    title: 'Best SUVs under 15 lakhs for family use?',
    content: 'Need suggestions for a highway-friendly SUV.',
    tags: ['SUV', 'Family'],
    views: 1240,
    created_at: new Date().toISOString()
  },
  {
    id: 2,
    user_id: 2,
    category: 'technical',
    title: 'EV charging infrastructure in metros',
    content: 'Share your experience with public charging.',
    tags: ['EV', 'Charging'],
    views: 980,
    created_at: new Date().toISOString()
  }
];

const forumReplies: ForumReply[] = [
  {
    id: 1,
    user_id: 2,
    post_id: 1,
    content: 'Consider the Hyundai Creta and Kia Seltos.',
    created_at: new Date().toISOString()
  }
];

const aiInsights: AiInsight[] = [
  {
    vehicleId: 3,
    resaleValue: 2200000,
    confidence: 0.87,
    fairValue: 2100000,
    message: "This car's resale value is 22% higher than its segment average."
  },
  {
    vehicleId: 4,
    resaleValue: 1800000,
    confidence: 0.82,
    fairValue: 1750000,
    message: 'Predicted battery health is 92% with optimal maintenance.'
  }
];

export default {
  vehicles,
  vehicleListings,
  serviceHistory,
  blogPosts,
  forumPosts,
  forumReplies,
  aiInsights
};
