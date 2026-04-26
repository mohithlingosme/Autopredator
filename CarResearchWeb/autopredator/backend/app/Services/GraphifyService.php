<?php
declare(strict_types=1);

/**
 * GraphifyService - Handles graphify graph.json generation.
 *
 * Provides a PHP wrapper around the graphify CLI:
 *   graphify update <path>
 *
 * Usage:
 *   $svc = new GraphifyService();
 *   $result = $svc->generate($targetPath);
 *   if ($result['success']) { … }
 */
class GraphifyService
{
    /**
     * Absolute or relative path to the graphify executable.
     * Defaults to "graphify" (assumes it is on $PATH).
     */
    private string $graphifyBinary;

    /**
     * Working directory for the graphify command so .graphifyignore applies.
     */
    private ?string $workingDirectory;

    /**
     * Maximum execution time in seconds for the graphify process.
     */
    private int $timeoutSeconds;

    public function __construct(
        ?string $graphifyBinary = null,
        ?string $workingDirectory = null,
        int $timeoutSeconds = 300
    ) {
        $this->graphifyBinary   = $graphifyBinary ?? 'graphify';
        $this->workingDirectory = $workingDirectory ?? __DIR__ . '/../../..';
        $this->timeoutSeconds   = $timeoutSeconds;
    }

    /**
     * Run graphify update against the given path and return structured result.
     *
     * @param string $path Target folder/file to graphify (defaults to app root)
     * @return array{success:bool,output:string,error:string,exit_code:int|null}
     */
    public function generate(string $path = ''): array
    {
        $target = $path ?: $this->workingDirectory;

        // Validate target exists
        if (!is_dir($target) && !is_file($target)) {
            return [
                'success'   => false,
                'output'    => '',
                'error'     => "Target path does not exist: {$target}",
                'exit_code' => null,
            ];
        }

        $cmd = sprintf(
            '%s update %s %s',
            escapeshellarg($this->graphifyBinary),
            escapeshellarg($target),
            '2>&1'   // capture stderr in stdout
        );

        $cwd = $this->workingDirectory;

        $descriptors = [
            0 => ['pipe', 'r'], // stdin
            1 => ['pipe', 'w'], // stdout
            2 => ['pipe', 'w'], // stderr (ignored when 2>&1 is used above)
        ];

        $process = @proc_open($cmd, $descriptors, $pipes, $cwd);

        if (!is_resource($process)) {
            return [
                'success'   => false,
                'output'    => '',
                'error'     => 'Failed to start graphify process. Is graphify installed and on PATH?',
                'exit_code' => null,
            ];
        }

        // Set stream timeouts
        stream_set_timeout($pipes[1], $this->timeoutSeconds);
        stream_set_timeout($pipes[2], $this->timeoutSeconds);

        $output = stream_get_contents($pipes[1]);
        $error  = stream_get_contents($pipes[2]);

        fclose($pipes[0]);
        fclose($pipes[1]);
        fclose($pipes[2]);

        $info = proc_get_status($process);
        // If process is still running, wait for it
        while ($info['running']) {
            sleep(1);
            $info = proc_get_status($process);
        }

        $exitCode = $info['exitcode'] ?? -1;
        proc_close($process);

        $success = ($exitCode === 0);
        $combinedOutput = trim($output . "\n" . $error);

        if (!$success && empty($combinedOutput)) {
            $combinedOutput = 'graphify exited with non-zero status but produced no output.';
        }

        return [
            'success'   => $success,
            'output'    => $combinedOutput,
            'error'     => $success ? '' : $combinedOutput,
            'exit_code' => $exitCode,
        ];
    }

    /**
     * Lightweight check: is the graphify binary available?
     */
    public function isAvailable(): bool
    {
        $cmd = escapeshellarg($this->graphifyBinary) . ' --version 2>&1';
        $output = shell_exec($cmd);
        return $output !== null && str_contains((string)$output, 'graphify');
    }

    /**
     * Auto-generate wrapper: checks config flag, runs graphify, logs result.
     *
     * @return array{success:bool,skipped:bool,output:string,error:string}
     */
    public function autoGenerate(string $targetPath = ''): array
    {
        // Feature disabled in config?
        if (!defined('GRAPHIFY_AUTO_GENERATE') || !GRAPHIFY_AUTO_GENERATE) {
            return [
                'success' => false,
                'skipped' => true,
                'output'  => '',
                'error'   => 'GRAPHIFY_AUTO_GENERATE is disabled in config.',
            ];
        }

        // Optional: skip if binary missing
        if (!$this->isAvailable()) {
            return [
                'success' => false,
                'skipped' => true,
                'output'  => '',
                'error'   => 'graphify binary not found on PATH.',
            ];
        }

        $path = $targetPath ?: (defined('GRAPHIFY_TARGET_PATH') ? GRAPHIFY_TARGET_PATH : $this->workingDirectory);

        $result = $this->generate($path);

        return array_merge($result, ['skipped' => false]);
    }
}

