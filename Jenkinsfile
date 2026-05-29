pipeline {
    agent any

    environment {
        NETWORK_NAME = 'python-app-network'   // Docker network name
        APP_IMAGE = 'my-python-app'           // Docker image name
        APP_CONTAINER = 'my-python-container' // Docker container name
        YOUR_NAME = 'your_name'               // Environment variable for container
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
                sh """
                    trivy fs --format table -o trivy-fs-report.txt .
                """
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
                sh """
                    trivy image --format table -o trivy-image-report.txt ${APP_IMAGE}
                """
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
            }
        }

        stage('Unit Tests') {
            steps {
                script {
                    catchError(buildResult: 'UNSTABLE', stageResult: 'UNSTABLE') {
                        echo 'Running unit tests...'
        
                        sh """
                            python3 -m venv venv
                            venv/bin/pip install -r requirements.txt
                            venv/bin/python -m unittest test_app.py
                        """
        
                        sh """
                            python -m unittest test_app.py
                        """
                    }
                }
            }
}
    }

    post {
        success {
            echo 'Deployment successful!'
        }

        failure {
            echo 'Pipeline failed!'
        }
    }
}
