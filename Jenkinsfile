pipeline {
    agent any

    environment {
        DOCKERHUB_USER = "sridatta5157"
        IMAGE_NAME = "python-devops-app"
        IMAGE_TAG = "${BUILD_NUMBER}"
        DOCKER_CREDS = "docker-hub-cred"
    }

    stages {

        stage('Clone Repo') {
            steps {
             checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[credentialsId: 'jenkinskey', url: 'https://github.com/sridattaga/my-new-proj-python.git']])
            }
        }
        stage('Install Dependencies') {
            steps {
        sh '''
        if ! command -v pip3 &> /dev/null
        then
            echo "Installing pip..."
            sudo yum install python3-pip -y
        fi

        python3 -m pip install --upgrade pip
        pip3 install wheel setuptools
        '''
    }
        }

        stage('Build Artifact') {
            steps {
                sh '''
                python3 setup.py bdist_wheel
                '''
            }
        }

        stage('Archive Artifact') {
            steps {
                archiveArtifacts artifacts: 'dist/*.whl'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                docker build -t $DOCKERHUB_USER/$IMAGE_NAME:$IMAGE_TAG .
                '''
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(credentialsId: "$DOCKER_CREDS", usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh '''
                    echo $PASS | docker login -u $USER --password-stdin
                    '''
                }
            }
        }

        stage('Push Image') {
            steps {
                sh '''
                docker push $DOCKERHUB_USER/$IMAGE_NAME:$IMAGE_TAG
                '''
            }
        }

    }
}
