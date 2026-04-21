#!/usr/bin/env bash
set -euo pipefail

echo "=== Build Stage ==="
echo "Project Type: ${PROJECT_TYPE:-unknown}"

case "${PROJECT_TYPE:-spring-boot}" in
  spring-boot)
    echo "Building Spring Boot project with Maven..."
    if [ -f "mvnw" ]; then
      chmod +x mvnw
      ./mvnw clean package -DskipTests -B
    else
      mvn clean package -DskipTests -B
    fi
    ;;
  nodejs)
    echo "Building Node.js project..."
    npm ci
    npm run build --if-present
    ;;
  python)
    echo "Building Python project..."
    python -m venv venv || true
    . venv/bin/activate || true
    pip install --upgrade pip
    pip install -r requirements.txt
    ;;
  *)
    echo "ERROR: Unknown project type '${PROJECT_TYPE}'"
    exit 1
    ;;
esac

echo "=== Build Complete ==="
