#!/usr/bin/env bash
set -euo pipefail

echo "=== Test Stage ==="
echo "Project Type: ${PROJECT_TYPE:-unknown}"

case "${PROJECT_TYPE:-spring-boot}" in
  spring-boot)
    echo "Running Spring Boot tests..."
    if [ -f "mvnw" ]; then
      chmod +x mvnw
      ./mvnw test -B
    else
      mvn test -B
    fi
    ;;
  nodejs)
    echo "Running Node.js tests..."
    npm test
    ;;
  python)
    echo "Running Python tests..."
    . venv/bin/activate || true
    pip install pytest pytest-cov || true
    pytest --junitxml=test-results.xml --cov=. --cov-report=html || true
    ;;
  *)
    echo "ERROR: Unknown project type '${PROJECT_TYPE}'"
    exit 1
    ;;
esac

echo "=== Tests Complete ==="

