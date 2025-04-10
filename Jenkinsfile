pipeline {
    agent { label 'Built-In' }
    parameters {
        choice(name: 'STAGE', choices: ['dev', 'qa', 'prod'], description: 'Deployment stage')
        booleanParam(name: 'RELEASE', defaultValue: false, description: 'Release build?')
    }
    environment {
        // Nexus Host
         SNAPSHOT_REPO = 'internal-maven-snapshots'
         RELEASE_REPO  = 'internal-maven-releases'
         GROUP_ID = 'com.mycompany.app'
         ARTIFACT_ID = 'simple-maven-project-with-tests'
         FILE_PATH = 'target/simple-maven-project-with-tests-1.0-SNAPSHOT.jar'
         TYPE = 'jar'
         NEXUS_HOST = '192.168.178.21:8081'
         CREDENTIALS_ID = 'nexus'
    }
    tools {
        // Install the Maven version configured as "M3" and add it to the path.
        maven 'Maven_local'
    }

    stages {
        stage('Check Maven'){
            steps {
                sh 'mvn -version'
            }
        }
        stage('Build') {
            steps {
                echo "Building for SATGE=${params.STAGE}, RELEASE=${params.RELEASE}"
                // Get some code from a GitHub repository
                git 'https://github.com/jglick/simple-maven-project-with-tests.git'

                // Run Maven on a Unix agent.
                sh "mvn -Dmaven.test.failure.ignore=true clean package"

                // To run Maven on a Windows agent, use
                // bat "mvn -Dmaven.test.failure.ignore=true clean package"
            }

            post {
                // If Maven was able to run the tests, even if some of the test
                // failed, record the test results and archive the jar file.
                success {
                    junit '**/target/surefire-reports/TEST-*.xml'
                    archiveArtifacts 'target/*.jar'
                }
            }
        }
     stage('upload Artifact to Nexus') {
         steps {
             // pick repository URL based on Release Param
          withEnv([
              "DEPLOY_REPO_URL=${params.RELEASE ? env.RELEASE_REPO : env.SNAPSHOT_REPO}",
              "ARTIFACT_VERSION=${params.RELEASE ? "1.0.${env.BUILD_NUMBER}" : "1.0.${env.BUILD_NUMBER}-SNAPSHOT"}"])
              {
          nexusArtifactUploader(
          nexusVersion: 'nexus3',
          protocol: 'http',
          nexusUrl: "${env.NEXUS_HOST}",
          groupId: "${env.GROUP_ID}",
          artifactId: "${env.ARTIFACT_ID}",
          version: '${env.ARTIFACT_VERSION}',
          repository: "${params.RELEASE ? 'internal-maven-releases' : 'internal-maven-snapshots'}",
          credentialsId: "${env.CREDENTIALS_ID}",
          artifacts: [
            [artifactId: "${env.ARTIFACT_ID}", classifier: '', file: " ${env.FILE_PATH}", type: "${env.TYPE}"]
          ]
        )
          }
         }
     }
    }
}
