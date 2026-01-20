.PHONY: test-all

test-all:
	@if [ -d "backend" ]; then \
		echo "Running backend tests..."; \
		cd backend && make test; \
	fi
	@if [ -d "frontend" ]; then \
		echo "Running frontend tests..."; \
		cd frontend && npm test; \
	fi
	@if [ -d "php_app" ]; then \
		echo "Running PHP lint..."; \
		cd php_app && find . -name "*.php" -print0 | xargs -0 -n1 php -l; \
	fi
