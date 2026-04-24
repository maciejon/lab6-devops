pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = 'maciejon'
        IMAGE_NAME = 'spring-petclinic'
        CONTAINER_NAME = 'petclinic-sandbox'
        BLDR_IMAGE = "${IMAGE_NAME}-bldr:latest"
        TARGET_IMAGE = "${DOCKER_REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER}"
        APP_PORT = '9090'
    }

    stages {

        stage('Pre-Clean') {
            steps {
                sh "docker rm -f ${CONTAINER_NAME} || true"   // komunikat błędu jest normalny, potok idzie dalej
            }
        }

        stage('Build & Test') {
            steps {
                // 1. Zbuduj obraz bldr (zawiera kod źródłowy i Maven w /app)
                sh "docker build --target bldr -t ${BLDR_IMAGE} ."

                // 2. Uruchom tymczasowy kontener NADAJĄC MU NAZWĘ, aby potem móc skopiować artefakty
                sh "docker run --name build-${BUILD_NUMBER} ${BLDR_IMAGE} mvn clean package"
                // Wykonuje kompilację ORAZ testy (bez -DskipTests) – w przypadku niepowodzenia potok zatrzyma się tutaj

                // 3. Skopiuj katalog target z kontenera do workspace Jenkinsa
                sh "docker cp build-${BUILD_NUMBER}:/app/target ./target"

                // 4. Usuń tymczasowy kontener
                sh "docker rm build-${BUILD_NUMBER}"
            }
        }

        stage('Prepare Target Image') {
            steps {
                sh "docker build -t ${TARGET_IMAGE} -t ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest ."
            }
        }

        stage('Deploy') {
            steps {
                sh "docker run -d --name ${CONTAINER_NAME} -p ${9090}:8080 ${TARGET_IMAGE}"
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
