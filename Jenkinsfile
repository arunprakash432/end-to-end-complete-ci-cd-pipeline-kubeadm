pipeline {
    agent any

    tools {
        jdk 'jdk21'
        maven 'maven3'
    }

    environment {
        APP_NAME = "java-web-app"
        NAMESPACE = "java-web-app"

        DOCKER_REPO = "dockervarun432/java-web-app"
        IMAGE_TAG = "${BUILD_NUMBER}"

        SONAR_PROJECT_KEY = "java-web-app"
        SONAR_HOST_URL = "http://43.205.103.153/:9000"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Maven Compile') {
            steps {
                dir('app') {
                    sh 'mvn clean compile'
                }
            }
        }

        stage('Maven Test') {
            steps {
                dir('app') {
                    sh 'mvn test'
                }
            }
        }

        stage('Trivy Filesystem Scan') {
            steps {
                sh '''
                  trivy fs \
                  --format table \
                  -o trivy-fs-report.html \
                  .
                '''
            }
        }

        stage('SonarQube Analysis') {
            environment {
                SONAR_TOKEN = credentials('sonar')
            }
            steps {
                dir('app') {
                    withSonarQubeEnv('SonarQube') {
                        sh """
                          mvn sonar:sonar \
                          -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                          -Dsonar.host.url=${SONAR_HOST_URL} \
                          -Dsonar.login=${SONAR_TOKEN}
                        """
                    }
                }
            }
        }

        stage('Maven Package') {
            steps {
                dir('app') {
                    sh 'mvn package -DskipTests'
                }
            }
        }

        stage('Publish to Nexus') {
            environment {
                NEXUS = credentials('nexus-cred')
            }
            steps {
                dir('app') {
                    sh '''
                      mvn deploy -DskipTests \
                      -Dnexus.username=${NEXUS_USR} \
                      -Dnexus.password=${NEXUS_PSW}
                    '''
                }
            }
        }

        stage('Docker Build & Tag') {
            steps {
                sh '''
                  docker build -t ${DOCKER_REPO}:${IMAGE_TAG} .
                  docker tag ${DOCKER_REPO}:${IMAGE_TAG} ${DOCKER_REPO}:latest
                '''
            }
        }

        stage('Trivy Image Scan') {
            steps {
                sh '''
                  trivy image \
                  --format table \
                  -o trivy-image-report.html \
                  ${DOCKER_REPO}:${IMAGE_TAG}
                '''
            }
        }

        stage('Docker Push') {
            environment {
                DOCKER = credentials('docker-cred')
            }
            steps {
                sh '''
                  echo ${DOCKER_PSW} | docker login -u ${DOCKER_USR} --password-stdin
                  docker push ${DOCKER_REPO}:${IMAGE_TAG}
                  docker push ${DOCKER_REPO}:latest
                '''
            }
        }

        stage('Deploy to Kubernetes') {
            environment {
                KUBECONFIG = credentials('kubeconfig')
            }
            steps {
                sh '''
                  kubectl apply -f k8s/namespace.yaml
                  kubectl apply -f k8s/
                '''
            }
        }

        stage('Verify Deployment') {
            environment {
                KUBECONFIG = credentials('kubeconfig')
            }
            steps {
                sh '''
                  kubectl get pods -n ${NAMESPACE}
                  kubectl get svc -n ${NAMESPACE}
                '''
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: '*.html', fingerprint: true
        }

        success {
            emailext(
                subject: "SUCCESS: ${JOB_NAME} #${BUILD_NUMBER}",
                body: """
                <h3>Pipeline Successful</h3>
                <p>Docker Image: ${DOCKER_REPO}:${IMAGE_TAG}</p>
                <p>Namespace: ${NAMESPACE}</p>
                """,
                to: "varunthegamie@gmail.com",
                mimeType: 'text/html'
            )
        }

        failure {
            emailext(
                subject: "FAILED: ${JOB_NAME} #${BUILD_NUMBER}",
                body: "<h3>Pipeline Failed – Check Jenkins Logs</h3>",
                to: "varunthegamie@gmail.com",
                mimeType: 'text/html'
            )
        }
    }
}

