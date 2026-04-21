pipeline {
    agent { label 'linux' }

    environment {
        REPO_URL       = "${params.REPO_URL ?: 'https://github.com/your-org/your-repo.git'}"
        BRANCH         = "${params.BRANCH ?: 'main'}"
        PROJECT_TYPE   = "${params.PROJECT_TYPE ?: 'spring-boot'}"
        DOCKER_IMAGE   = "${params.DOCKER_IMAGE ?: 'your-org/your-app'}"
        DOCKER_TAG     = "${env.BUILD_NUMBER}"
        DEPLOY_TARGET  = "${params.DEPLOY_TARGET ?: 'none'}"
    }

    parameters {
        string(name: 'REPO_URL', defaultValue: 'https://github.com/your-org/your-repo.git', description: 'Git repository URL')
        string(name: 'BRANCH', defaultValue: 'main', description: 'Branch to build')
        choice(name: 'PROJECT_TYPE', choices: ['spring-boot', 'nodejs', 'python'], description: 'Project type')
        string(name: 'DOCKER_IMAGE', defaultValue: 'your-org/your-app', description: 'Docker image name')
        choice(name: 'DEPLOY_TARGET', choices: ['none', 'docker', 'kubernetes', 'ec2'], description: 'Deployment target')
    }

    options {
        timeout(time: 30, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '10'))
        disableConcurrentBuilds()
        timestamps()
    }

    stages {
        stage('Checkout') {
            steps {
                git credentialsId: 'github-creds', url: "${REPO_URL}", branch: "${BRANCH}"
            }
        }

        stage('Build') {
            steps {
                retry(2) {
                    sh 'chmod +x ./scripts/build.sh && ./scripts/build.sh'
                }
            }
        }

        stage('Test') {
            steps {
                sh 'chmod +x ./scripts/test.sh && ./scripts/test.sh'
            }
            post {
                always {
                    script {
                        if (env.PROJECT_TYPE == 'spring-boot') {
                            junit allowEmptyResults: true, testResults: '**/target/surefire-reports/*.xml'
                        } else if (env.PROJECT_TYPE == 'nodejs') {
                            junit allowEmptyResults: true, testResults: '**/junit.xml'
                        } else if (env.PROJECT_TYPE == 'python') {
                            junit allowEmptyResults: true, testResults: '**/test-results.xml'
                        }
                    }
                }
            }
        }

        stage('Docker Build & Push') {
            when {
                expression { return env.DEPLOY_TARGET in ['docker', 'kubernetes'] }
            }
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh """
                            echo "\$DOCKER_PASS" | docker login -u "\$DOCKER_USER" --password-stdin
                            docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                            docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest
                            docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                            docker push ${DOCKER_IMAGE}:latest
                        """
                    }
                }
            }
        }

        stage('Deploy') {
            when {
                expression { return env.DEPLOY_TARGET != 'none' }
            }
            steps {
                retry(2) {
                    sh 'chmod +x ./scripts/deploy.sh && ./scripts/deploy.sh'
                }
            }
        }

        stage('Deploy to Kubernetes') {
            when {
                expression { return env.DEPLOY_TARGET == 'kubernetes' }
            }
            steps {
                withCredentials([file(credentialsId: 'kubeconfig-creds', variable: 'KUBECONFIG')]) {
                    sh """
                        kubectl set image deployment/app app=${DOCKER_IMAGE}:${DOCKER_TAG} --record
                        kubectl rollout status deployment/app --timeout=300s
                    """
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully for ${DOCKER_IMAGE}:${DOCKER_TAG}"
        }
        failure {
            script {
                withCredentials([string(credentialsId: 'slack-webhook', variable: 'SLACK_URL')]) {
                    sh """
                        curl -X POST -H 'Content-type: application/json' \
                            --data '{"text":"❌ Jenkins Build FAILED: ${env.JOB_NAME} #${env.BUILD_NUMBER}\\n${env.BUILD_URL}"}' \
                            "\$SLACK_URL"
                    """
                }
            }
        }
        always {
            cleanWs()
        }
    }
}

