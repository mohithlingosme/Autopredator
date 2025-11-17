import express from 'express';
import { pool } from '../db';
import { getBlogPosts } from '../services/dataService';

const router = express.Router();

router.get('/', async (req, res) => {
  try {
    const { limit } = req.query;
    const blogs = await getBlogPosts(limit ? Number(limit) : undefined);
    res.json(blogs);
  } catch (error) {
    console.error('Failed to fetch blogs', error);
    res.status(500).json({ error: 'Failed to fetch blogs' });
  }
});

router.get('/:id', async (req, res) => {
  try {
    const id = Number(req.params.id);
    const result = await pool.query('SELECT * FROM blog_posts WHERE id = $1', [id]);
    if (!result.rows.length) {
      const fallback = (await getBlogPosts()).find(blog => blog.id === id);
      if (!fallback) {
        return res.status(404).json({ error: 'Blog not found' });
      }
      return res.json(fallback);
    }
    res.json(result.rows[0]);
  } catch (error) {
    console.error('Failed to fetch blog', error);
    res.status(500).json({ error: 'Failed to fetch blog' });
  }
});

export default router;
