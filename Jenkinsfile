
pipeline {
    agent any

    tools {
        jdk 'jdk21'
        maven 'maven3'
    }

    environment {
        SCANNER_HOME = tool 'sonar-scanner'
        DOCKER_IMAGE = 'agodzo/pet-clinic123:latest'
    }

    stages {

        stage('Git Checkout') {
            steps {
                git branch: 'main',
                    changelog: false,
                    poll: false,
                    url: 'https://github.com/karris12/Kinaxis-interview-demo-petstore.git'
            }
        }

        stage('Build and Test') {
            steps {
                sh 'mvn clean verify'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withCredentials([
                    string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')
                ]) {
                    withSonarQubeEnv('sonar-server') {
                        sh '''
                            $SCANNER_HOME/bin/sonar-scanner \
                              -Dsonar.projectName=Petclinic \
                              -Dsonar.projectKey=Petclinic \
                              -Dsonar.java.binaries=target/classes \
                              -Dsonar.token=$SONAR_TOKEN
                        '''
                    }
                }
            }
        }

        stage('OWASP Dependency Check') {
            steps {
                dependencyCheck(
                    additionalArguments: '--scan . --format XML',
                    odcInstallation: 'DP'
                )

                dependencyCheckPublisher(
                    pattern: '**/dependency-check-report.xml'
                )
            }
        }

        stage('Docker Build and Push') {
            steps {
                script {
                    withDockerRegistry([
                        credentialsId: 'docker-cred',
                        url: 'https://index.docker.io/v1/'
                    ]) {
                        sh '''
                            docker build -t $DOCKER_IMAGE .
                            docker push $DOCKER_IMAGE
                        '''
                    }
                }
            }
        }

        stage('Trivy Vulnerability Scan') {
            steps {
                sh '''
                    trivy --config "" image \
                        --ignorefile /dev/null \
                        --scanners vuln \
                        $DOCKER_IMAGE
                '''
            }
        }

        stage('Deploy To Tomcat Container') {
            steps {
                sh '''
                    docker rm -f petclinic-app || true

                    docker run -d \
                        --name petclinic-app \
                        --restart unless-stopped \
                        -p 8081:8080 \
                        $DOCKER_IMAGE
                '''
            }
        }
    }
}
