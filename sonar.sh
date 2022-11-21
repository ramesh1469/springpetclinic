pipeline {
    agent {label 'Node-1'}
    stages {
        stage ('vcs') {
            steps { 
                git branch: "main",url:'https://github.com/spring-projects/spring-petclinic.git'
            }
        }
        stage ('sonar') {
            steps {
                withSonarQubeEnv('sonar') {
                sh 'mvn clean package sonar:sonar'
            }
        }    
    }
     stage ('Artifactory configuration') {  
            steps {
                rtMavenDeployer (
                    id: "mvn",
                    serverId: "ram",
                    releaseRepo: "qt-libs-release-local",
                    snapshotRepo: "qt-libs-snapshot-local"
                )
            }
        }
       stage ('Exec Maven') {
            steps {
                rtMavenRun (
                    tool: 'maven',
                    pom: 'pom.xml',
                    goals: 'clean install',
                    deployerId: "mvn"
                )
            }
        }
       stage ('Publish build info') {
            steps {
                rtPublishBuildInfo (
                    serverId: "ram"
                )
            }
        }
         stage ('JUnitResultArchiver') {
            steps {
              junit '**/surefire-reports/*.xml'
            }
         }  
  }
}