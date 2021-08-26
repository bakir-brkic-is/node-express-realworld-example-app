pipeline {
    agent { 
        docker { 
            image 'brrx387/jenkins-docker'
            args '-v /var/run/docker.sock:/var/run/docker.sock'
            reuseNode true
        }
    }

    environment {
        MONGODB_URI="mongodb://root:${MONGO_INITDB_ROOT_PASSWORD}@host.docker.internal:27017/"
        SECRET='secretHasToBeSet'
        MONGO_INITDB_ROOT_PASSWORD='example'
        PORT=2000
    }
    
    stages {
        stage('Build container image') {
            steps {
                sh "docker build -t expressbackend:${env.BUILD_ID} ."
            }
        }
    }
    
    post {
        // always {
        //     archiveArtifacts artifacts: 'build', fingerprint: true
        // }
        success {
            echo 'Success!'
        }
        failure {
            echo 'This will run only if failed'
        }
        unstable {
            echo 'This will run only if the run was marked as unstable'
        }
        changed {
            echo 'This will run only if the state of the Pipeline has changed'
            echo 'For example, if the Pipeline was previously failing but is now successful'
        }
    }
}