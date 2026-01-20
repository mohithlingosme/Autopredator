<?php
declare(strict_types=1);

namespace App\Services;

use App\Repositories\ContentRepository;

final class ContentService
{
    private ContentRepository $repo;

    public function __construct(ContentRepository $repo)
    {
        $this->repo = $repo;
    }

    /**
     * Get published posts for public blog
     */
    public function getPublishedPosts(int $page = 1, int $limit = 10, ?int $categoryId = null): array
    {
        return $this->repo->getPublishedPosts($page, $limit, $categoryId);
    }

    /**
     * Get single published post by slug
     */
    public function getPublishedPostBySlug(string $slug): ?array
    {
        return $this->repo->getPublishedPostBySlug($slug);
    }

    /**
     * Get all posts for admin (with drafts, etc.)
     */
    public function getAllPostsForAdmin(
        int $page = 1,
        int $limit = 50,
        ?string $status = null,
        ?int $categoryId = null,
        ?string $search = null
    ): array {
        return $this->repo->getAllPostsForAdmin($page, $limit, $status, $categoryId, $search);
    }

    /**
     * Create a new blog post
     */
    public function createPost(array $postData): int
    {
        // Validate required fields
        $this->validatePostData($postData, false);

        // Generate slug if not provided
        if (empty($postData['slug'])) {
            $postData['slug'] = $this->generateSlug($postData['title']);
        }

        // Calculate reading time and word count
        $postData['word_count'] = $this->calculateWordCount($postData['content']);
        $postData['reading_time'] = $this->calculateReadingTime($postData['word_count']);

        return $this->repo->createPost($postData);
    }

    /**
     * Update an existing blog post
     */
    public function updatePost(int $postId, array $postData): bool
    {
        // Validate required fields
        $this->validatePostData($postData, true);

        // Generate slug if not provided
        if (empty($postData['slug'])) {
            $postData['slug'] = $this->generateSlug($postData['title']);
        }

        // Recalculate reading time and word count
        if (isset($postData['content'])) {
            $postData['word_count'] = $this->calculateWordCount($postData['content']);
            $postData['reading_time'] = $this->calculateReadingTime($postData['word_count']);
        }

        return $this->repo->updatePost($postId, $postData);
    }

    /**
     * Delete a blog post
     */
    public function deletePost(int $postId): bool
    {
        return $this->repo->deletePost($postId);
    }

    /**
     * Get post categories
     */
    public function getCategories(): array
    {
        return $this->repo->getCategories();
    }

    /**
     * Get post authors
     */
    public function getAuthors(): array
    {
        return $this->repo->getAuthors();
    }

    /**
     * Get post tags
     */
    public function getTags(): array
    {
        return $this->repo->getTags();
    }

    /**
     * Save media file
     */
    public function saveMedia(array $mediaData): int
    {
        return $this->repo->saveMedia($mediaData);
    }

    /**
     * Validate post data
     */
    private function validatePostData(array $data, bool $isUpdate): void
    {
        $required = $isUpdate ? [] : ['title', 'content', 'author_id'];

        foreach ($required as $field) {
            if (empty($data[$field])) {
                throw new \InvalidArgumentException("Field '{$field}' is required");
            }
        }

        if (isset($data['title']) && strlen($data['title']) > 255) {
            throw new \InvalidArgumentException("Title must be 255 characters or less");
        }

        if (isset($data['slug']) && strlen($data['slug']) > 255) {
            throw new \InvalidArgumentException("Slug must be 255 characters or less");
        }

        if (isset($data['status']) && !in_array($data['status'], ['draft', 'review', 'published', 'archived'])) {
            throw new \InvalidArgumentException("Invalid status value");
        }
    }

    /**
     * Generate URL-friendly slug from title
     */
    private function generateSlug(string $title): string
    {
        $slug = strtolower(trim($title));
        $slug = preg_replace('/[^a-z0-9\s-]/', '', $slug);
        $slug = preg_replace('/[\s-]+/', '-', $slug);
        $slug = trim($slug, '-');

        // Ensure uniqueness
        $originalSlug = $slug;
        $counter = 1;
        while ($this->repo->slugExists($slug)) {
            $slug = $originalSlug . '-' . $counter;
            $counter++;
        }

        return $slug;
    }

    /**
     * Calculate word count from content
     */
    private function calculateWordCount(string $content): int
    {
        // Strip HTML tags and count words
        $text = strip_tags($content);
        return str_word_count($text);
    }

    /**
     * Calculate reading time in minutes (average 200 words per minute)
     */
    private function calculateReadingTime(int $wordCount): int
    {
        return (int) ceil($wordCount / 200);
    }
}
