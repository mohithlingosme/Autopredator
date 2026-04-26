<?php
declare(strict_types=1);

namespace App\Controllers;

final class ShortlistController
{
    private const COOKIE_NAME = 'car_shortlist';

    public function handle(string $method, string $param): void
    {
        session_start();

        if ($method === 'GET' && $param === '') {
            $this->getShortlist();
        } elseif ($method === 'POST' && $param === 'add') {
            $this->addToShortlist();
        } elseif ($method === 'POST' && $param === 'remove') {
            $this->removeFromShortlist();
        } else {
            http_response_code(404);
            echo json_encode(['ok' => false, 'error' => ['code' => 'NOT_FOUND', 'message' => 'Shortlist endpoint not found']]);
        }
    }

    private function getShortlist(): void
    {
        $shortlist = $this->getShortlistIds();
        echo json_encode(['ok' => true, 'data' => $shortlist]);
    }

    private function addToShortlist(): void
    {
        $input = json_decode(file_get_contents('php://input'), true);
        $variantSlug = $input['variant_slug'] ?? '';

        if (!$variantSlug) {
            http_response_code(400);
            echo json_encode(['ok' => false, 'error' => ['code' => 'BAD_REQUEST', 'message' => 'variant_slug required']]);
            return;
        }

        $shortlist = $this->getShortlistIds();
        if (!in_array($variantSlug, $shortlist)) {
            $shortlist[] = $variantSlug;
            $this->setShortlistIds($shortlist);
        }

        echo json_encode(['ok' => true, 'data' => $shortlist]);
    }

    private function removeFromShortlist(): void
    {
        $input = json_decode(file_get_contents('php://input'), true);
        $variantSlug = $input['variant_slug'] ?? '';

        if (!$variantSlug) {
            http_response_code(400);
            echo json_encode(['ok' => false, 'error' => ['code' => 'BAD_REQUEST', 'message' => 'variant_slug required']]);
            return;
        }

        $shortlist = $this->getShortlistIds();
        $shortlist = array_filter($shortlist, fn($slug) => $slug !== $variantSlug);
        $this->setShortlistIds(array_values($shortlist));

        echo json_encode(['ok' => true, 'data' => $shortlist]);
    }

    private function getShortlistIds(): array
    {
        return $_SESSION[self::COOKIE_NAME] ?? [];
    }

    private function setShortlistIds(array $ids): void
    {
        $_SESSION[self::COOKIE_NAME] = $ids;
    }
}
