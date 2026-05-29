pipeline {
    agent any
    environment {
        NETWORK_NAME = 'python-app-network'
        APP_IMAGE = 'my-python-app'
        APP_CONTAINER = 'my-python-container'
        YOUR_NAME = 'your_name'
    }
    stages {
        stage('Clean Up') {
            steps {
                echo 'Cleaning up old containers and network...'
                sh """
                    docker rm -f ${APP_CONTAINER} || true
                    docker network rm ${NETWORK_NAME} || true
                """
            }
        }
        stage('Set Up Network') {
            steps {
                echo 'Creating Docker network...'
                sh "docker network create ${NETWORK_NAME}"
            }
        }
        stage('Trivy - Filesystem Scan') {
            steps {
                echo 'Running Trivy filesystem scan...'
                sh '''
                    trivy fs \
                        --severity CRITICAL,HIGH \
                        --format table \
                        -o trivy-fs-report.txt .
                '''
                sh '''
                    echo "=== TRIVY FILESYSTEM REPORT ==="
                    cat trivy-fs-report.txt | sed 's/â”Œ/+/g; s/â”€/-/g; s/â”/+/g; s/â”œ/|/g; s/â”¼/+/g; s/â”¤/|/g; s/â””/+/g; s/â”´/+/g; s/â”˜/+/g; s/â”‚/|/g; s/â”€/-/g' || cat trivy-fs-report.txt
                '''
                archiveArtifacts artifacts: 'trivy-fs-report.txt', fingerprint: true
            }
        }
        stage('Build Image') {
            steps {
                echo 'Building Docker image...'
                sh """
                    docker build -t ${APP_IMAGE} .
                """
            }
        }
        stage('Trivy - Image Scan') {
            steps {
                echo 'Scanning Docker image with Trivy...'
                sh '''
                    trivy image \
                        --severity CRITICAL,HIGH \
                        --format table \
                        -o trivy-image-report.txt ${APP_IMAGE}
                '''
                sh '''
                    echo "=== TRIVY IMAGE REPORT ==="
                    cat trivy-image-report.txt | sed 's/â”Œ/+/g; s/â”€/-/g; s/â”/+/g; s/â”œ/|/g; s/â”¼/+/g; s/â”¤/|/g; s/â””/+/g; s/â”´/+/g; s/â”˜/+/g; s/â”‚/|/g; s/â”€/-/g' || cat trivy-image-report.txt
                '''
                archiveArtifacts artifacts: 'trivy-image-report.txt', fingerprint: true
            }
        }
        stage('Run Container') {
            steps {
                echo 'Running Docker container...'
                sh """
                    docker run -d \
                        --name ${APP_CONTAINER} \
                        --network ${NETWORK_NAME} \
                        -e YOUR_NAME=${YOUR_NAME} \
                        -p 5500:5500 \
                        ${APP_IMAGE}
                """
                echo 'Waiting for container to start...'
                sh '''
                    sleep 6
                    echo "=== CONTAINER STATUS ==="
                    docker ps -a | grep ${APP_CONTAINER} || true
                    echo "=== CONTAINER LOGS ==="
                    docker logs --tail 100 ${APP_CONTAINER} || true
                '''
            }
        }
        stage('Unit Tests') {
            steps {
                script {
                    catchError(buildResult: 'UNSTABLE', stageResult: 'UNSTABLE') {
                        echo "=== UNIT TESTS (using Flask test_client) ==="
                        sh '''
                            docker exec -w /app ${APP_CONTAINER} bash -c '
                                echo "Current directory: $(pwd)"
                                PYTHONPATH=. python -m unittest test_app.py -v
                            '
                        '''
                    }
                }
            }
        }
        stage('Gate - Quality/Security Results') {
            steps {
                echo 'Waiting for manual approval before continuing...'
                input message: "✅ Quality & Security checks passed. Approve to continue?", ok: "Yes, proceed with deployment"
            }
        }
    }
    post {
        success {
            echo 'Deployment successful!'
        }
        unstable {
            echo 'Pipeline completed with UNSTABLE tests'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
