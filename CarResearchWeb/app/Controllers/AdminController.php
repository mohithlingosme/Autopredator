{
        $page = (int) ($_GET['page'] ?? 1);
        $limit = (int) ($_GET['limit'] ?? 50);
        $leads = $this->repo->getAll();

        $offset = ($page - 1) * $limit;
        $paginated = array_slice($leads, $offset, $limit);

        echo json_encode(['ok' => true, 'data' => [
            'leads' => $paginated,
            'total' => count($leads),
            'page' => $page,
            'limit' => $limit,
        ]]);
    }

    private function updateLeadStatus(int $id): void
    {
        $input = json_decode(file_get_contents('php://input'), true);
        $status = $input['status'] ?? '';

        if (!$status) {
            http_response_code(400);
            echo json_encode(['ok' => false, 'error' => ['code' => 'BAD_REQUEST', 'message' => 'status required']]);
            return;
        }

        if ($this->repo->updateStatus($id, $status)) {
            echo json_encode(['ok' => true]);
        } else {
            http_response_code(404);
            echo json_encode(['ok' => false, 'error' => ['code' => 'NOT_FOUND', 'message' => 'Lead not found']]);
        }
    }
=======
    private function getLeads(): void
    {
        $page = (int) ($_GET['page'] ?? 1);
        $limit = (int) ($_GET['limit'] ?? 50);
        $leads = $this->leadRepo->getAll();

        $offset = ($page - 1) * $limit;
        $paginated = array_slice($leads, $offset, $limit);

        echo json_encode(['ok' => true, 'data' => [
            'leads' => $paginated,
            'total' => count($leads),
            'page' => $page,
            'limit' => $limit,
        ]]);
    }

    private function updateLeadStatus(int $id): void
    {
        $input = json_decode(file_get_contents('php://input'), true);
        $status = $input['status'] ?? '';

        if (!$status) {
            http_response_code(400);
            echo json_encode(['ok' => false, 'error' => ['code' => 'BAD_REQUEST', 'message' => 'status required']]);
            return;
        }

        if ($this->leadRepo->updateStatus($id, $status)) {
            echo json_encode(['ok' => true]);
        } else {
            http_response_code(404);
            echo json_encode(['ok' => false, 'error' => ['code' => 'NOT_FOUND', 'message' => 'Lead not found']]);
        }
    }
