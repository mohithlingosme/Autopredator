module.exports = {
  ci: {
    collect: {
      numberOfRuns: 3,
      startServerCommand: 'php -S localhost:8000 -t .',
      startServerReadyPattern: 'Development Server',
      url: ['http://localhost:8000/index.php', 'http://localhost:8000/compare.php'],
    },
    assert: {
      assertions: {
        'categories:performance': ['error', { minScore: 0.8 }],
        'categories:accessibility': ['error', { minScore: 0.9 }],
      },
    },
    upload: {
      target: 'temporary-public-storage',
    },
  },
};
