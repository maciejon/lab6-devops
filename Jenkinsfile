pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = 'maciejon' 
        IMAGE_NAME = 'spring-petclinic'
        CONTAINER_NAME = 'petclinic-sandbox'
        BLDR_IMAGE = "${IMAGE_NAME}-bldr:latest"
        TARGET_IMAGE = "${DOCKER_REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER}"
    }

    stages {

        stage('Pre-Clean') {
            steps {
                sh "docker rm -f ${CONTAINER_NAME} || true"
            }
        }

        stage('Build BLDR & Artifact') {
            steps {
                sh "docker build --target bldr -t ${BLDR_IMAGE} ."
                
                sh "ls -la" 
                
                sh "docker run --rm -v ${WORKSPACE}:/app -w /app ${BLDR_IMAGE} mvn clean package -DskipTests"
            }
        }

        stage('Test') {
            steps {
                sh "docker run --rm -v ${WORKSPACE}:/app -w /app ${BLDR_IMAGE} ./mvnw test"
            }
        }

        stage('Prepare Target Image') {
            steps {
                sh "docker build -t ${TARGET_IMAGE} -t ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest ."
            }
        }

        stage('Deploy') {
            steps {
                sh "docker run -d --name ${CONTAINER_NAME} -p 8080:8080 ${TARGET_IMAGE}"          
            }
        }

        stage('Publish') {
            steps {
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
                
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                    sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin"
                    sh "docker push ${TARGET_IMAGE}"
                    sh "docker push ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest"
                }
            }
        }
    }

    post {
        always {
            cleanWs() 
        }
    }
}
