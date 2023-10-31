pipeline {
    agent any


    stages {
        stage('Build') {
            steps {
                // Get some code from a GitHub repository
                git "https://github.com/aws-samples/api-gateway-secure-pet-store.git"

                // Run Maven
                sh "mvn -Dmaven.test.failure.ignore=true clean package"

            }}

            stage('Sonarqube Scan'){
                steps {
                    sh '''/tools/sonarscanner/bin/sonar-scanner \
                        -Dsonar.projectKey=pet-store \
                        -Dsonar.projectName=pet-store \
                        -Dsonar.sources=src/main/java/ \
                        -Dsonar.language=java \
                        -Dsonar.host.url=http://localhost:9000 \
                        -Dsonar.login=admin \
                        -Dsonar.java.binaries=**/**/**/**/**/**/**  \
                        -Dsonar.password=MySonarAdminPassword \
                        -Dsonar.sslVerification=false
                    '''
                }
            }

        // stage('Owasp Zap Scan'){
        //         steps {
        //             sh '''/tools/zap/zap.sh \
        // Swap port with Application build port
        //                  -quickscan http://localhost:8080 \
        //                  -port 8090  
        //             '''
        //         }
        //     }

        }
    }
