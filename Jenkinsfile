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

        SONAR_PROJECT_KEY = "java-web-app"
        SONAR_HOST_URL    = "http://43.205.103.153:9000"
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
                  -Dsonar.projectKey=java-web-app \
                  -Dsonar.host.url=http://43.205.103.153:9000 \
                  -Dsonar.login=$SONAR_TOKEN
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
                to: "prakasharun484@gmail.com",
                mimeType: 'text/html',
                body: """
                <h3>Pipeline Successful</h3>
                <p><b>Application:</b> ${APP_NAME}</p>
                <p><b>Docker Image:</b> ${DOCKER_REPO}:${IMAGE_TAG}</p>
                <p><b>Namespace:</b> ${NAMESPACE}</p>
                <p><a href="${BUILD_URL}">View Build</a></p>
                """
            )
        }

        failure {
            emailext(
                subject: "FAILED: ${JOB_NAME} #${BUILD_NUMBER}",
                to: "prakasharun484@gmail.com",
                mimeType: 'text/html',
                body: """
                <h3 style="color:red;">Pipeline Failed</h3>
                <p>Check Jenkins logs.</p>
                <p><a href="${BUILD_URL}">View Build</a></p>
                """
            )
        }
    }
}
