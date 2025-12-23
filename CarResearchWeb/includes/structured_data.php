<?php
declare(strict_types=1);

/**
 * Structured Data (JSON-LD) helpers for SEO
 */

/**
 * Generate BreadcrumbList structured data
 */
function generate_breadcrumb_json_ld(array $breadcrumbs): string
{
    $items = [];
    $position = 1;

    foreach ($breadcrumbs as $crumb) {
        if (!empty($crumb['url'])) {
            $items[] = [
                '@type' => 'ListItem',
                'position' => $position,
                'name' => $crumb['label'],
                'item' => 'https://autopredator.com' . $crumb['url']
            ];
            $position++;
        }
    }

    if (empty($items)) {
        return '';
    }

    $data = [
        '@context' => 'https://schema.org',
        '@type' => 'BreadcrumbList',
        'itemListElement' => $items
    ];

    return json_encode($data, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
}

/**
 * Generate Product/Vehicle structured data for model page
 */
function generate_model_json_ld(array $model, array $variants): string
{
    $offers = [];
    foreach ($variants as $variant) {
        if (!empty($variant['price_numeric'])) {
            $offers[] = [
                '@type' => 'Offer',
                'price' => (float) $variant['price_numeric'],
                'priceCurrency' => 'INR',
                'availability' => 'https://schema.org/InStock',
                'seller' => [
                    '@type' => 'Organization',
                    'name' => $model['make'] ?? 'Autopredator'
                ]
            ];
        }
    }

    $data = [
        '@context' => 'https://schema.org',
        '@type' => 'Product',
        'name' => ($model['make'] ?? '') . ' ' . ($model['model'] ?? ''),
        'description' => 'Browse all variants of ' . ($model['make'] ?? '') . ' ' . ($model['model'] ?? ''),
        'brand' => [
            '@type' => 'Brand',
            'name' => $model['make'] ?? ''
        ],
        'category' => 'Automotive',
        'model' => $model['model'] ?? '',
        'manufacturer' => [
            '@type' => 'Organization',
            'name' => $model['make'] ?? ''
        ]
    ];

    if (!empty($offers)) {
        $data['offers'] = $offers;
    }

    return json_encode($data, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
}

/**
 * Generate Product/Vehicle structured data for variant page
 */
function generate_variant_json_ld(array $variant): string
{
    $data = [
        '@context' => 'https://schema.org',
        '@type' => 'Product',
        'name' => ($variant['manufacturer_name'] ?? '') . ' ' . ($variant['model_name'] ?? '') . ' ' . ($variant['variant_name'] ?? ''),
        'description' => 'Complete specifications and pricing for ' . ($variant['manufacturer_name'] ?? '') . ' ' . ($variant['model_name'] ?? '') . ' ' . ($variant['variant_name'] ?? ''),
        'brand' => [
            '@type' => 'Brand',
            'name' => $variant['manufacturer_name'] ?? ''
        ],
        'category' => 'Automotive',
        'model' => $variant['model_name'] ?? '',
        'manufacturer' => [
            '@type' => 'Organization',
            'name' => $variant['manufacturer_name'] ?? ''
        ]
    ];

    if (!empty($variant['ex_showroom_price'])) {
        $data['offers'] = [
            '@type' => 'Offer',
            'price' => (float) $variant['ex_showroom_price'],
            'priceCurrency' => 'INR',
            'availability' => 'https://schema.org/InStock',
            'seller' => [
                '@type' => 'Organization',
                'name' => $variant['manufacturer_name'] ?? 'Autopredator'
            ]
        ];
    }

    return json_encode($data, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
}

/**
 * Generate Article structured data for blog posts (if implemented)
 */
function generate_article_json_ld(array $post): string
{
    $data = [
        '@context' => 'https://schema.org',
        '@type' => 'Article',
        'headline' => $post['title'] ?? '',
        'description' => $post['excerpt'] ?? '',
        'author' => [
            '@type' => 'Organization',
            'name' => 'Autopredator'
        ],
        'publisher' => [
            '@type' => 'Organization',
            'name' => 'Autopredator'
        ],
        'datePublished' => $post['published_at'] ?? '',
        'dateModified' => $post['updated_at'] ?? $post['published_at'] ?? ''
    ];

    return json_encode($data, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
}
