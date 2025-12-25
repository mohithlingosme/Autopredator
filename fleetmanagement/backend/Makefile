.PHONY: test test-unit test-integration test-cov test-smoke

test:
	pytest -q

test-unit:
	pytest -q -m unit

test-integration:
	pytest -q -m integration

test-cov:
	pytest --cov --cov-report=term-missing

test-smoke:
	@echo "Starting smoke test..."
	@uvicorn main:app --host 0.0.0.0 --port 8000 &
	@sleep 5
	@curl -f http://localhost:8000/health || (echo "Health check failed"; exit 1)
	@pkill -f uvicorn
	@echo "Smoke test passed"
