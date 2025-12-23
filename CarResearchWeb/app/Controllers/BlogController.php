<?php
declare(strict_types=1);

namespace App\Controllers;

use App\Services\ContentService;

final class BlogController
{
    private ContentService $contentService;

    public function __construct(ContentService $contentService)
    {
        $this->contentService = $contentService;
    }

    /**
     * Handle blog index page
     */
    public function index(): void
    {
        $page = (int) ($_GET['page'] ?? 1);
        $categorySlug = $_GET['category'] ?? null;
        $limit = 12; // Posts per page

        // Get category ID if category slug provided
        $categoryId = null;
        if ($categorySlug) {
            $categories = $this->contentService->getCategories();
            foreach ($categories as $category) {
                if ($category['slug'] === $categorySlug) {
                    $categoryId = $category['id'];
                    break;
                }
            }
        }

        $posts = $this->contentService->getPublishedPosts($page, $limit, $categoryId);

        // Set page metadata
        $pageTitle = $categoryId ? "Blog - {$posts['category']['name']}" : 'Blog';
        $pageDescription = $categoryId ? $posts['category']['description'] : 'Latest automotive news, reviews, and insights from CarResearch.';

        // Include view
        $data = [
            'posts' => $posts['posts'],
            'pagination' => [
                'current_page' => $page,
                'total_pages' => $posts['total_pages'],
                'has_more' => $page < $posts['total_pages']
            ],
            'categories' => $this->contentService->getCategories(),
            'current_category' => $categoryId ? $posts['category'] : null,
            'page_title' => $pageTitle,
            'page_description' => $pageDescription
        ];

        $this->render('blog/index', $data);
    }

    /**
     * Handle individual blog post page
     */
    public function show(string $slug): void
    {
        $post = $this->contentService->getPublishedPostBySlug($slug);

        if (!$post) {
            $this->render404();
            return;
        }

        // Set page metadata
        $pageTitle = $post['seo_title'] ?: $post['title'];
        $pageDescription = $post['seo_description'] ?: $post['excerpt'];

        // Include view
        $data = [
            'post' => $post,
            'page_title' => $pageTitle,
            'page_description' => $pageDescription,
            'og_image' => $post['featured_image'] ?: '/assets/images/default-blog.jpg'
        ];

        $this->render('blog/show', $data);
    }

    /**
     * Handle category page
     */
    public function category(string $slug): void
    {
        $categories = $this->contentService->getCategories();
        $category = null;

        foreach ($categories as $cat) {
            if ($cat['slug'] === $slug) {
                $category = $cat;
                break;
            }
        }

        if (!$category) {
            $this->render404();
            return;
        }

        $page = (int) ($_GET['page'] ?? 1);
        $limit = 12;

        $posts = $this->contentService->getPublishedPosts($page, $limit, $category['id']);

        // Set page metadata
        $pageTitle = "Blog - {$category['name']}";
        $pageDescription = $category['description'] ?: "Articles in {$category['name']} category.";

        $data = [
            'category' => $category,
            'posts' => $posts['posts'],
            'pagination' => [
                'current_page' => $page,
                'total_pages' => $posts['total_pages'],
                'has_more' => $page < $posts['total_pages']
            ],
            'categories' => $categories,
            'page_title' => $pageTitle,
            'page_description' => $pageDescription
        ];

        $this->render('blog/category', $data);
    }

    /**
     * Render a view with data
     */
    private function render(string $view, array $data = []): void
    {
        // Extract data to make variables available in view
        extract($data);

        // Set global page variables
        $pageTitle = $page_title ?? 'CarResearch Blog';
        $pageDescription = $page_description ?? 'Automotive insights and car research.';
        $ogImage = $og_image ?? '/assets/images/default-og.jpg';

        // Include layout
        require_once __DIR__ . '/../../views/layout.php';
    }

    /**
     * Render 404 page
     */
    private function render404(): void
    {
        http_response_code(404);
        $pageTitle = 'Page Not Found';
        $pageDescription = 'The page you are looking for does not exist.';

        $data = [
            'page_title' => $pageTitle,
            'page_description' => $pageDescription
        ];

        $this->render('errors/404', $data);
    }
}
