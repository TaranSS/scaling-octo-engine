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

        stage('Build Image') {
            steps {
                echo 'Building Docker image...'
                sh """
                    docker build -t ${APP_IMAGE} .
                """
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
