#!/usr/bin/env bash
set -euo pipefail

echo "=== Deploy Stage ==="
echo "Deploy Target: ${DEPLOY_TARGET:-none}"
echo "Docker Image:  ${DOCKER_IMAGE:-unset}:${DOCKER_TAG:-latest}"

case "${DEPLOY_TARGET:-none}" in
  docker)
    echo "Deploying via Docker..."
    docker pull "${DOCKER_IMAGE}:${DOCKER_TAG}"
    docker stop app-container 2>/dev/null || true
    docker rm app-container 2>/dev/null || true
    docker run -d --name app-container \
      --restart unless-stopped \
      -p 8080:8080 \
      "${DOCKER_IMAGE}:${DOCKER_TAG}"
    echo "Container started on port 8080"
    ;;
  kubernetes)
    echo "Deploying to Kubernetes..."
    # KUBECONFIG is injected via Jenkins withCredentials
    kubectl set image deployment/app app="${DOCKER_IMAGE}:${DOCKER_TAG}" --record
    kubectl rollout status deployment/app --timeout=300s
    ;;
  ec2)
    echo "Deploying to EC2 via SSH..."
    # SSH_KEY is injected via Jenkins withCredentials
    echo "EC2 deployment requires additional configuration in Jenkinsfile."
    ;;
  none)
    echo "No deployment target configured. Skipping."
    ;;
  *)
    echo "ERROR: Unknown deploy target '${DEPLOY_TARGET}'"
    exit 1
    ;;
esac

echo "=== Deploy Complete ==="

