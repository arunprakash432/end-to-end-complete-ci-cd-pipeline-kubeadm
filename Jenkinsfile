pipeline {
    agent any

    tools {
        jdk 'jdk21'
        maven 'maven3'
    }

    environment {
        APP_NAME  = "java-web-app"
        NAMESPACE = "java-web-app"

        DOCKER_REPO = "dockervarun432/java-web-app"
        IMAGE_TAG   = "${BUILD_NUMBER}"

        SONAR_PROJECT_KEY = "tic-tac-toe"
        SONAR_HOST_URL    = "http://43.205.103.153:9000"

        RELEASE_VERSION = "0.0.1-build-${BUILD_NUMBER}"
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
                  trivy fs . \
                  --exit-code 0 \
                  --severity HIGH,CRITICAL \
                  --format table \
                  -o trivy-fs-report.html
                '''
            }
        }

        stage('SonarQube Analysis') {
            environment {
                SONAR_TOKEN = credentials('sonar')
            }
            steps {
                dir('app') {
                    withSonarQubeEnv('sonar') {
                        sh '''
                          mvn org.sonarsource.scanner.maven:sonar-maven-plugin:sonar \
                          -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                          -Dsonar.host.url=${SONAR_HOST_URL} \
                          -Dsonar.login=${SONAR_TOKEN}
                        '''
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

        stage('Publish To Nexus') {
            environment {
                NEXUS = credentials('nexus-cred')
            }
            steps {
                dir('app') {
                    withMaven(
                        jdk: 'jdk21',
                        maven: 'maven3',
                        mavenSettingsConfig: 'maven-settings',
                        traceability: true
                    ) {
                        sh '''
                          echo "Releasing version ${RELEASE_VERSION}"

                          mvn versions:set \
                            -DnewVersion=${RELEASE_VERSION} \
                            -DgenerateBackupPoms=false

                          mvn deploy -DskipTests
                        '''
                    }
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
                  trivy image ${DOCKER_REPO}:${IMAGE_TAG} \
                  --exit-code 0 \
                  --severity HIGH,CRITICAL \
                  --format table \
                  -o trivy-image-report.html
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

        stage('Deploy to Kubernetes (Ingress)') {
            environment {
                KUBECONFIG = credentials('kubeconfig')
            }
            steps {
                sh '''
                  kubectl apply -f k8s/namespace.yaml
                  kubectl apply -f k8s/deployment.yaml
                  kubectl apply -f k8s/service.yaml
                  kubectl apply -f k8s/ingress.yaml
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
                  kubectl get ingress -n ${NAMESPACE}
                '''
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: '*.html', fingerprint: true
        }
    }
}
