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

    private function dashboard(): void
    {
        // Route guard: Check if admin is enabled and user has admin role
        if (!ADMIN_ENABLED || !auth_has_role('Admin')) {
            http_response_code(403);
            echo json_encode(['ok' => false, 'error' => ['code' => 'FORBIDDEN', 'message' => 'Access denied']]);
            return;
        }

        // Placeholder dashboard data
        $data = [
            'drafts' => 5,
            'review_queue' => 12,
            'published_this_week' => 8,
            'pending_updates' => 3,
            'alerts' => [
                'Missing citations in 3 articles',
                'Stale prices in 7 variants',
                'Broken links in 2 blog posts',
                'Failed imports from 1 data source'
            ],
            'recent_activity' => array_map(function($log) {
                return $log['timestamp'] . ': ' . $log['action'];
            }, audit_get_recent_logs(10))
        ];

        echo json_encode(['ok' => true, 'data' => $data]);
    }

    private function login(): void
    {
        if (!ADMIN_ENABLED) {
            http_response_code(404);
            echo json_encode(['ok' => false, 'error' => ['code' => 'NOT_FOUND', 'message' => 'Admin panel disabled']]);
            return;
        }

        $input = json_decode(file_get_contents('php://input'), true);
        $email = $input['email'] ?? '';
        $password = $input['password'] ?? '';

        $error = auth_login($email, $password);
        if ($error) {
            http_response_code(401);
            echo json_encode(['ok' => false, 'error' => ['code' => 'UNAUTHORIZED', 'message' => $error]]);
            return;
        }

        // Check if user has admin role
        if (!auth_has_role('Admin')) {
            auth_logout();
            http_response_code(403);
            echo json_encode(['ok' => false, 'error' => ['code' => 'FORBIDDEN', 'message' => 'Admin privileges required']]);
            return;
        }

        // Log successful login
        audit_log('Admin login');

        echo json_encode(['ok' => true, 'message' => 'Login successful']);
    }

    private function logout(): void
    {
        audit_log('Admin logout');
        auth_logout();
        echo json_encode(['ok' => true, 'message' => 'Logout successful']);
    }
