pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'webapp:latest'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build the Docker image locally
                    docker.build(DOCKER_IMAGE)
                }
            }
        }

        stage('Deploy to Staging') {
            when {
                branch 'staging'
            }
            steps {
                script {
                    // Stop any existing container and run a new one for staging
                    sh 'docker stop staging_container || true'
                    sh 'docker rm staging_container || true'
                    sh "docker run -d --name staging_container -p 8081:80 ${DOCKER_IMAGE}"
                }
            }
        }

        stage('Deploy to Production') {
            when {
                branch 'main'
            }
            steps {
                script {
                    // Stop any existing container and run a new one for production
                    sh 'docker stop production_container || true'
                    sh 'docker rm production_container || true'
                    sh "docker run -d --name production_container -p 8082:80 ${DOCKER_IMAGE}"
                }
            }
        }
    }
}