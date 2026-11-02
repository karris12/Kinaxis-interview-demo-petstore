pipeline {
    agent any 
    
    tools{
        jdk 'jdk21'
        maven 'maven3'
    }
    
    environment {
        SCANNER_HOME=tool 'sonar-scanner'
    }
    
    stages{
        
        stage("Git Checkout"){
            steps{
                git branch: 'main', changelog: false, poll: false, url: 'https://github.com/karris12/Kinaxis-interview-demo-petstore.git'
            }
        }
        
        stage("Compile"){
            steps{
                sh "mvn clean compile"
            }
        }
        
         stage("Test Cases"){
            steps{
                sh "mvn test"
            }
        }
        
       stage("Sonarqube Analysis") {
    steps {
        // Use credentials() to securely bind your SonarQube token in Jenkins
        withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
            withSonarQubeEnv('sonar-server') {
                sh '''
                    $SCANNER_HOME/bin/sonar-scanner \
                      -Dsonar.projectName=Petclinic \
                      -Dsonar.projectKey=Petclinic \
                      -Dsonar.java.binaries=. \
                      -Dsonar.login=$SONAR_TOKEN
                '''
            }
        }
    }
}
        
        stage("OWASP Dependency Check"){
            steps{
                dependencyCheck additionalArguments: '--scan ./ --format HTML ', odcInstallation: 'DP'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
        
         stage("Build"){
            steps{
                sh " mvn clean install"
            }
        }
        
        stage('Docker Build & Push') {
    steps {
        script {
            withDockerRegistry([
                credentialsId: 'docker-cred',
                url: 'https://index.docker.io/v1/'
            ]) {
                sh 'docker build -t agodzo/pet-clinic123:latest .'
                sh 'docker push agodzo/pet-clinic123:latest'
            }
        }
    }
}
        
        stage("TRIVY"){
            steps{
                sh " trivy image agodzo/pet-clinic123:latest"
            }
        }
        
                stage("Deploy To Tomcat Container") {
            steps {
                sh '''
                    docker rm -f petclinic-app || true

                    docker run -d \
                        --name petclinic-app \
                        --restart unless-stopped \
                        -p 8081:8080 \
                        agodzo/pet-clinic123:latest
                '''
            }
        }
    }
}
