pipeline {
    agent any

    environment {
        DOCKERHUB_USER = "yourdockerhubusername"
        IMAGE_NAME = "python-devops-app"
        IMAGE_TAG = "${BUILD_NUMBER}"
        DOCKER_CREDS = "docker-hub-cred"
    }

    stages {

        stage('Clone Repo') {
            steps {
                git 'https://github.com/yourusername/python-devops-app.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $DOCKERHUB_USER/$IMAGE_NAME:$IMAGE_TAG .'
            }
        }

        stage('Login DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: "$DOCKER_CREDS", passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                    sh 'echo $PASS | docker login -u $USER --password-stdin'
                }
            }
        }

        stage('Push Image') {
            steps {
                sh 'docker push $DOCKERHUB_USER/$IMAGE_NAME:$IMAGE_TAG'
            }
        }

        stage('Run Container') {
            steps {
                sh '''
                docker stop python-app || true
                docker rm python-app || true
                docker run -d -p 5000:5000 --name python-app $DOCKERHUB_USER/$IMAGE_NAME:$IMAGE_TAG
                '''
            }
        }

    }
}
