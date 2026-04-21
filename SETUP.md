# Jenkins CI/CD Pipeline — Setup Guide

## 1. Required Jenkins Plugins

Install via **Manage Jenkins → Plugins → Available**:

| Plugin | Purpose |
|--------|---------|
| **Pipeline** | Declarative pipeline support |
| **Git** | Git SCM checkout |
| **Credentials Binding** | Inject secrets into builds |
| **Docker Pipeline** | Docker build/push steps |
| **Kubernetes CLI** | kubectl in pipelines |
| **Slack Notification** | Failure alerts |
| **Timestamper** | Timestamp console output |
| **JUnit** | Test result publishing |

## 2. Configure Jenkins Credentials

Go to **Manage Jenkins → Credentials → System → Global credentials → Add Credentials**:

| Credential ID | Kind | Description |
|---------------|------|-------------|
| `github-creds` | Username with password (or PAT) | GitHub access for checkout |
| `docker-creds` | Username with password | Docker registry login |
| `kubeconfig-creds` | Secret file | Kubernetes config file |
| `slack-webhook` | Secret text | Slack incoming webhook URL |

> ⚠️ **NEVER** put credentials in code, `.env` files, or commit them to Git.

## 3. Connect GitHub Repository

### Option A: Webhook (Recommended)
1. In GitHub repo → **Settings → Webhooks → Add webhook**
2. Payload URL: `https://<jenkins-url>/github-webhook/`
3. Content type: `application/json`
4. Events: **Just the push event**

### Option B: Poll SCM
In Jenkins job config, set Poll SCM schedule: `H/5 * * * *`

## 4. Create the Pipeline Job

1. **New Item → Pipeline**
2. Under **Pipeline**:
   - Definition: **Pipeline script from SCM**
   - SCM: **Git**
   - Repository URL: your repo URL
   - Credentials: `github-creds`
   - Branch: `*/main`
   - Script Path: `Jenkinsfile`
3. **Save** and **Build Now**

## 5. Project Structure

```
├── Jenkinsfile              # Pipeline definition
├── Dockerfile               # Multi-stage Docker build
├── scripts/
│   ├── build.sh             # Build logic per project type
│   ├── test.sh              # Test logic per project type
│   └── deploy.sh            # Deploy logic per target
├── k8s/
│   └── deployment.yaml      # Kubernetes manifests
└── .github/
    ├── jenkins-pipeline.agent.md   # AI agent definition
    └── mcp.json                     # MCP tool config
```

## 6. Parameterized Builds

The Jenkinsfile supports parameters. On first run Jenkins will register them; subsequent runs show:

- **REPO_URL** — Git repo to clone
- **BRANCH** — Branch to build
- **PROJECT_TYPE** — `spring-boot` / `nodejs` / `python`
- **DOCKER_IMAGE** — Image name for Docker builds
- **DEPLOY_TARGET** — `none` / `docker` / `kubernetes` / `ec2`

## 7. Running the Pipeline

```bash
# Trigger via Jenkins UI: Build with Parameters

# Or trigger via CLI:
java -jar jenkins-cli.jar -s http://localhost:8080/ build "your-job" \
  -p PROJECT_TYPE=spring-boot \
  -p DEPLOY_TARGET=docker
```

## 8. Troubleshooting

| Issue | Solution |
|-------|----------|
| `permission denied: ./scripts/build.sh` | Scripts get `chmod +x` in Jenkinsfile |
| `docker: command not found` | Install Docker on Jenkins agent |
| Credentials error | Verify credential ID matches exactly |
| Build timeout | Increase `timeout` in Jenkinsfile `options` block |

