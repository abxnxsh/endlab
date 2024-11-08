pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'webapp:latest'
        BLUE_PORT = "8084"  // Current Production Port
        GREEN_PORT = "8085" // Next Production Port
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
                    // Stop any existing staging container and run a new one for staging
                    sh 'docker stop staging_container || true'
                    sh 'docker rm staging_container || true'
                    sh "docker run -d --name staging_container -p 8082:80 ${DOCKER_IMAGE}"
                }
            }
        }

        stage('Deploy to Production (Green)') {
            when {
        expression { env.BRANCH_NAME == 'main' }
    }
            steps {
                script {
                    // Stop any existing Green container and run the new one on GREEN_PORT
                    sh 'docker stop production_container_green || true'
                    sh 'docker rm production_container_green || true'
                    sh "docker run -d --name production_container_green -p ${GREEN_PORT}:80 ${DOCKER_IMAGE}"
                }
            }
        }

        stage('Switch Traffic to Green') {
            when {  
                branch 'main'
            }
            steps {
                script {
                    // Update Nginx to route traffic to the Green environment
                    sh 'sudo ln -sf /etc/nginx/sites-available/green /etc/nginx/sites-enabled/default'
                    sh 'sudo systemctl reload nginx'
                }
            }
        }

        stage('Stop Blue Environment') {
            when {
                branch 'main'
            }
            steps {
                script {
                    // Stop and remove the previous Blue container to free resources
                    sh 'docker stop production_container_blue || true'
                    sh 'docker rm production_container_blue || true'
                }
            }
        }

        stage('Promote Green to Blue') {
            when {
                branch 'main'
            }
            steps {
                script {
                    // Rename the Green container to Blue for the next deployment
                    sh 'docker rename production_container_green production_container_blue'
                }
            }
        }
    }

    post {
        always {
            echo "Cleaning up any unused Docker images"
            sh "docker image prune -f"
        }
    }
}
