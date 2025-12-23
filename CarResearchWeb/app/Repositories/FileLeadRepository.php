<?php
declare(strict_types=1);

namespace App\Repositories;

final class FileLeadRepository
{
    private string $filePath;

    public function __construct()
    {
        $this->filePath = __DIR__ . '/../../storage/leads.json';
        if (!file_exists($this->filePath)) {
            file_put_contents($this->filePath, json_encode([]));
        }
    }

    public function save(array $leadData): int
    {
        $leads = $this->getAll();
        $id = count($leads) + 1;
        $leadData['id'] = $id;
        $leadData['created_at'] = date('c');
        $leadData['status'] = 'new';
        $leads[] = $leadData;
        file_put_contents($this->filePath, json_encode($leads, JSON_PRETTY_PRINT));
        return $id;
    }

    public function getAll(): array
    {
        $content = file_get_contents($this->filePath);
        return json_decode($content, true) ?: [];
    }

    public function updateStatus(int $id, string $status): bool
    {
        $leads = $this->getAll();
        foreach ($leads as &$lead) {
            if ($lead['id'] === $id) {
                $lead['status'] = $status;
                $lead['updated_at'] = date('c');
                file_put_contents($this->filePath, json_encode($leads, JSON_PRETTY_PRINT));
                return true;
            }
        }
        return false;
    }
}
