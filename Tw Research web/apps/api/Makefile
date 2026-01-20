.PHONY: help install dev test lint format typecheck clean

help: ## Show this help message
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'

install: ## Install dependencies
	poetry install

dev: ## Run development server
	poetry run uvicorn main:app --reload --host 0.0.0.0 --port 8000

test: ## Run tests
	poetry run pytest

lint: ## Run linting
	poetry run ruff check .

format: ## Format code
	poetry run black .
	poetry run isort .

typecheck: ## Run type checking
	poetry run mypy .

clean: ## Clean up cache files
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete
	find . -type f -name "*.pyo" -delete
	find . -type f -name "*.pyd" -delete
