import express from 'express';
import { pool } from '../db';
import { getForumPosts, getForumReplies } from '../services/dataService';

const router = express.Router();

router.get('/posts', async (req, res) => {
  try {
    const { category, limit } = req.query;
    let posts = await getForumPosts(limit ? Number(limit) : undefined);
    if (category && category !== 'all') {
      posts = posts.filter(post => post.category === category);
    }
    res.json(posts);
  } catch (error) {
    console.error('Failed to fetch posts', error);
    res.status(500).json({ error: 'Failed to fetch posts' });
  }
});

router.post('/posts', async (req, res) => {
  const { userId, title, content, category, tags } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO forum_posts (user_id, title, content, category, tags) VALUES ($1, $2, $3, $4, $5) RETURNING *',
      [userId, title, content, category, tags || []]
    );
    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Failed to create post', error);
    res.status(500).json({ error: 'Failed to create post' });
  }
});

router.get('/posts/:id', async (req, res) => {
  try {
    const id = Number(req.params.id);
    const result = await pool.query('SELECT * FROM forum_posts WHERE id = $1', [id]);
    const post = result.rows[0];
    if (!post) {
      return res.status(404).json({ error: 'Post not found' });
    }
    const replies = await getForumReplies(id);
    res.json({ post, replies });
  } catch (error) {
    console.error('Failed to fetch post', error);
    res.status(500).json({ error: 'Failed to fetch post' });
  }
});

router.get('/posts/:id/replies', async (req, res) => {
  try {
    const id = Number(req.params.id);
    const replies = await getForumReplies(id);
    res.json(replies);
  } catch (error) {
    console.error('Failed to fetch replies', error);
    res.status(500).json({ error: 'Failed to fetch replies' });
  }
});

router.post('/posts/:id/replies', async (req, res) => {
  try {
    const id = Number(req.params.id);
    const { userId, content } = req.body;
    const result = await pool.query(
      'INSERT INTO forum_replies (user_id, post_id, content) VALUES ($1, $2, $3) RETURNING *',
      [userId, id, content]
    );
    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Failed to create reply', error);
    res.status(500).json({ error: 'Failed to create reply' });
  }
});

router.get('/summary/stats', async (_req, res) => {
  try {
    const posts = await getForumPosts();
    const stats = {
      totalPosts: posts.length,
      categories: posts.reduce<Record<string, number>>((acc, post) => {
        acc[post.category] = (acc[post.category] || 0) + 1;
        return acc;
      }, {}),
      trending: posts.slice(0, 5)
    };
    res.json(stats);
  } catch (error) {
    console.error('Failed to fetch stats', error);
    res.status(500).json({ error: 'Failed to fetch stats' });
  }
});

export default router;
