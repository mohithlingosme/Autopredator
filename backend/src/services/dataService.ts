import { pool } from '../db';
import sampleData from '../data/sampleData';
import {
  BlogPost,
  ForumPost,
  ForumReply,
  ServiceHistoryItem,
  Vehicle,
  VehicleListing
} from '../types';

const isArray = Array.isArray;

const mapVehicleRow = (row: any): Vehicle => ({
  id: row.id,
  name: row.name,
  brand: row.brand,
  segment: row.segment,
  type: row.type,
  fuel_type: row.fuel_type,
  body_type: row.body_type,
  transmission: row.transmission,
  seating_capacity: row.seating_capacity,
  price_min: row.price_min,
  price_max: row.price_max,
  currency: row.currency,
  rating: row.rating,
  image_url: row.image_url,
  thumbnail_url: row.thumbnail_url,
  specs: row.specs || {},
  features: row.features || {},
  performance: row.performance || {},
  dimensions: row.dimensions || {},
  safety_rating: row.safety_rating,
  categories: row.categories,
  is_featured: row.is_featured
});

const mapListingRow = (row: any): VehicleListing => ({
  id: row.id,
  vehicle_id: row.vehicle_id,
  seller_id: row.seller_id,
  km_driven: row.km_driven,
  year: row.year,
  asking_price: Number(row.asking_price),
  condition: row.condition,
  city: row.city,
  owner_type: row.owner_type,
  verified: row.verified,
  documents: isArray(row.documents) ? row.documents : [],
  service_score: row.service_score
});

const mapServiceHistoryRow = (row: any): ServiceHistoryItem => ({
  id: row.id,
  vehicle_listing_id: row.vehicle_listing_id,
  service_date: row.service_date,
  description: row.description,
  mileage: row.mileage,
  cost: Number(row.cost)
});

const mapBlogRow = (row: any): BlogPost => ({
  id: row.id,
  title: row.title,
  summary: row.summary,
  content: row.content,
  author: row.author,
  hero_image: row.hero_image,
  tags: row.tags || [],
  created_at: row.created_at
});

const mapForumRow = (row: any): ForumPost => ({
  id: row.id,
  user_id: row.user_id,
  category: row.category,
  title: row.title,
  content: row.content,
  tags: row.tags || [],
  views: row.views,
  created_at: row.created_at
});

const mapReplyRow = (row: any): ForumReply => ({
  id: row.id,
  user_id: row.user_id,
  post_id: row.post_id,
  content: row.content,
  created_at: row.created_at
});

export async function getVehicles(options?: { type?: string; limit?: number }): Promise<Vehicle[]> {
  const typeFilter = options?.type;
  const limit = options?.limit ?? 12;
  try {
    const query = `
      SELECT *
      FROM vehicles
      WHERE ($1::text IS NULL OR type = $1::vehicle_kind)
      ORDER BY created_at DESC
      LIMIT $2
    `;
    const result = await pool.query(query, [typeFilter || null, limit]);
    return result.rows.map(mapVehicleRow);
  } catch (error) {
    console.warn('Falling back to sample vehicles', error);
    let vehicles = sampleData.vehicles;
    if (typeFilter) {
      vehicles = vehicles.filter(vehicle => vehicle.type === typeFilter);
    }
    return vehicles.slice(0, limit);
  }
}

export async function getVehicleById(id: number): Promise<Vehicle | null> {
  try {
    const result = await pool.query('SELECT * FROM vehicles WHERE id = $1', [id]);
    return result.rows.length ? mapVehicleRow(result.rows[0]) : null;
  } catch (error) {
    console.warn('Falling back to sample vehicle', error);
    return sampleData.vehicles.find(vehicle => vehicle.id === id) || null;
  }
}

export async function getVehicleListings(vehicleId?: number): Promise<VehicleListing[]> {
  try {
    const result = await pool.query(
      `
        SELECT *
        FROM vehicle_listings
        WHERE ($1::int IS NULL OR vehicle_id = $1)
        ORDER BY created_at DESC
      `,
      [vehicleId || null]
    );
    return result.rows.map(mapListingRow);
  } catch (error) {
    console.warn('Falling back to sample listings', error);
    let listings = sampleData.vehicleListings;
    if (vehicleId) {
      listings = listings.filter(listing => listing.vehicle_id === vehicleId);
    }
    return listings;
  }
}

export async function getServiceHistoryForListing(listingId: number): Promise<ServiceHistoryItem[]> {
  try {
    const result = await pool.query('SELECT * FROM service_history WHERE vehicle_listing_id = $1 ORDER BY service_date DESC', [
      listingId
    ]);
    return result.rows.map(mapServiceHistoryRow);
  } catch (error) {
    console.warn('Falling back to sample service history', error);
    return sampleData.serviceHistory.filter(history => history.vehicle_listing_id === listingId);
  }
}

export async function getBlogPosts(limit = 10): Promise<BlogPost[]> {
  try {
    const result = await pool.query('SELECT * FROM blog_posts ORDER BY created_at DESC LIMIT $1', [limit]);
    return result.rows.map(mapBlogRow);
  } catch (error) {
    console.warn('Falling back to sample blogs', error);
    return sampleData.blogPosts.slice(0, limit);
  }
}

export async function getForumPosts(limit = 20): Promise<ForumPost[]> {
  try {
    const result = await pool.query('SELECT * FROM forum_posts ORDER BY created_at DESC LIMIT $1', [limit]);
    return result.rows.map(mapForumRow);
  } catch (error) {
    console.warn('Falling back to sample forum posts', error);
    return sampleData.forumPosts.slice(0, limit);
  }
}

export async function getForumReplies(postId: number): Promise<ForumReply[]> {
  try {
    const result = await pool.query('SELECT * FROM forum_replies WHERE post_id = $1 ORDER BY created_at ASC', [postId]);
    return result.rows.map(mapReplyRow);
  } catch (error) {
    console.warn('Falling back to sample replies', error);
    return sampleData.forumReplies.filter(reply => reply.post_id === postId);
  }
}
