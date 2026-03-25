def sendStageMail(stageName, status) {
    emailext (
        subject: "${status}: ${stageName} - ${env.JOB_NAME}",
        body: """
Stage: ${stageName}
Status: ${status}
Job: ${env.JOB_NAME}
Build Number: ${env.BUILD_NUMBER}

Check console output: ${env.BUILD_URL}
""",
        to: "${RECIPIENTS}"
    )
}

pipeline {
    agent any

    environment {
        DOCKERHUB_USER = "sridatta5157"
        IMAGE_NAME = "python-devops-app"
        IMAGE_TAG = "${BUILD_NUMBER}"
        DOCKER_CREDS = "dock_CRED"

        AWS_REGION = "ap-southeast-2"
        EKS_CLUSTER = "mycluster"
        KUBECONFIG = "/var/lib/jenkins/.kube/config"
        
        RECIPIENTS = 'sridatta1971@gmail.com'
    }

    stages {

        stage('Clone Repo') {
            steps {
                checkout scmGit(
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[
                        credentialsId: 'jenkinskey',
                        url: 'https://github.com/sridattaga/my-new-proj-python.git'
                    ]]
                )
            }
            post {
                success { script { sendStageMail("Clone Repo", "SUCCESS") } }
                failure { script { sendStageMail("Clone Repo", "FAILED") } }
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                if ! command -v pip3 &> /dev/null; then
                    sudo yum install python3-pip -y
                fi
                python3 -m pip install --upgrade pip
                pip3 install wheel setuptools
                '''
            }
            post {
                success { script { sendStageMail("Install Dependencies", "SUCCESS") } }
                failure { script { sendStageMail("Install Dependencies", "FAILED") } }
            }
        }

        stage('Build Artifact') {
            steps {
                sh 'python3 setup.py bdist_wheel'
            }
            post {
                success { script { sendStageMail("Build Artifact", "SUCCESS") } }
                failure { script { sendStageMail("Build Artifact", "FAILED") } }
            }
        }

        stage('Archive Artifact') {
            steps {
                archiveArtifacts artifacts: 'dist/*.whl'
            }
            post {
                success { script { sendStageMail("Archive Artifact", "SUCCESS") } }
                failure { script { sendStageMail("Archive Artifact", "FAILED") } }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $DOCKERHUB_USER/$IMAGE_NAME:$IMAGE_TAG .'
            }
            post {
                success { script { sendStageMail("Build Docker Image", "SUCCESS") } }
                failure { script { sendStageMail("Build Docker Image", "FAILED") } }
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: "$DOCKER_CREDS",
                    usernameVariable: 'USER',
                    passwordVariable: 'PASS'
                )]) {
                    sh 'echo $PASS | docker login -u $USER --password-stdin'
                }
            }
            post {
                success { script { sendStageMail("Docker Login", "SUCCESS") } }
                failure { script { sendStageMail("Docker Login", "FAILED") } }
            }
        }

        stage('Push Image') {
            steps {
                sh 'docker push $DOCKERHUB_USER/$IMAGE_NAME:$IMAGE_TAG'
            }
            post {
                success { script { sendStageMail("Push Image", "SUCCESS") } }
                failure { script { sendStageMail("Push Image", "FAILED") } }
            }
        }

        stage('Update K8s Image') {
            steps {
                sh '''
                sed -i "s|image:.*|image: $DOCKERHUB_USER/$IMAGE_NAME:$IMAGE_TAG|" k8s/deployment.yml
                '''
            }
            post {
                success { script { sendStageMail("Update K8s Image", "SUCCESS") } }
                failure { script { sendStageMail("Update K8s Image", "FAILED") } }
            }
        }

        stage('Configure EKS Access') {
            steps {
                sh '''
                aws eks --region $AWS_REGION update-kubeconfig --name $EKS_CLUSTER
                kubectl config current-context
                '''
            }
            post {
                success { script { sendStageMail("Configure EKS", "SUCCESS") } }
                failure { script { sendStageMail("Configure EKS", "FAILED") } }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                kubectl apply -f k8s/deployment.yml
                kubectl apply -f k8s/service.yml
                '''
            }
            post {
                success { script { sendStageMail("Deploy to Kubernetes", "SUCCESS") } }
                failure { script { sendStageMail("Deploy to Kubernetes", "FAILED") } }
            }
        }

        stage('Verify Deployment') {
            steps {
                sh '''
                kubectl rollout status deployment python-devops-app || true
                kubectl get pods -o wide
                kubectl get svc
                '''
            }
            post {
                success { script { sendStageMail("Verify Deployment", "SUCCESS") } }
                failure { script { sendStageMail("Verify Deployment", "FAILED") } }
            }
        }
    }

    post {
        success {
            emailext (
                subject: "Jenkins Job '${env.JOB_NAME}' Success",
                body: "All stages passed successfully!\n\nBuild: ${env.BUILD_NUMBER}\n${env.BUILD_URL}",
                to: "${RECIPIENTS}"
            )
        }
        failure {
            emailext (
                subject: "Jenkins Job '${env.JOB_NAME}' Failed",
                body: "Pipeline failed.\n\nBuild: ${env.BUILD_NUMBER}\n${env.BUILD_URL}",
                to: "${RECIPIENTS}"
            )
        }
        unstable {
            emailext (
                subject: "Jenkins Job '${env.JOB_NAME}' Unstable",
                body: "Pipeline unstable.\n\nBuild: ${env.BUILD_NUMBER}\n${env.BUILD_URL}",
                to: "${RECIPIENTS}"
            )
        }
    }
}
