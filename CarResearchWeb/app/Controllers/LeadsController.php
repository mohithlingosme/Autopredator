<?php
declare(strict_types=1);

namespace App\Controllers;

use App\Repositories\FileLeadRepository;

final class LeadsController
{
    private FileLeadRepository $repo;

    public function __construct()
    {
        $this->repo = new FileLeadRepository();
    }

    public function handle(string $method): void
    {
        if ($method !== 'POST') {
            http_response_code(405);
            echo json_encode(['ok' => false, 'error' => ['code' => 'METHOD_NOT_ALLOWED', 'message' => 'Only POST allowed']]);
            return;
        }

        $input = json_decode(file_get_contents('php://input'), true);

        if (!$this->validateLead($input)) {
            http_response_code(422);
            echo json_encode(['ok' => false, 'error' => ['code' => 'VALIDATION_ERROR', 'message' => 'Invalid lead data']]);
            return;
        }

        $leadId = $this->repo->save($input);

        http_response_code(201);
        echo json_encode(['ok' => true, 'data' => ['lead_id' => $leadId]]);
    }

    private function validateLead(array $data): bool
    {
        return !empty($data['name']) &&
               !empty($data['phone']) &&
               in_array($data['intent'] ?? '', ['quote', 'test_drive', 'callback']);
    }
}
