@Library('podTemplate') _

def COLOR_MAP = [
    'SUCCESS': 'good',
    'FAILURE': 'danger',
]

def getEnv(branch) {
  echo branch;
  if(branch.startsWith('releases')) {
     return "release";
  } else {
     return "staging";
  }
}

pipeline {
  agent {
        label 'docker-build'
    }
  
  environment {
    BUNDLE_RUBYGEMS__PKG__GITHUB__COM = "loco-bot:${GITHUB_PAT}"
    ENV=getEnv("${params.BRANCH}")
    SERVICE_NAME="loconav-developer-apis"
    ECR_ADDRESS="loconav.azurecr.io"
    ECR_LINK_APP="${ECR_ADDRESS}/${ENV}/${SERVICE_NAME}"
    CURRENT_DATE= sh (returnStdout: true, script: 'date +%Y%m%d').trim()
    GIT_COMMIT_HASH= sh (returnStdout: true, script: 'git rev-parse --short HEAD').trim()
    IMAGE_VERSION= "${CURRENT_DATE}-${GIT_COMMIT_HASH}"
    RELEASE_NAME="${ECR_LINK_APP}:${IMAGE_VERSION}"
   
    GITHUB_PAT = credentials('loco-bot-PAT')
        
  }
  stages {
    
    stage('Login in ECR/ACR for docker'){
      steps{
         dockerLogin()
      }
    }
     stage('Clone Configurator Repo'){
          steps{
            sh """
              rm -rf tools
              mkdir -p tools
              cd tools && git clone --depth 1 git@github.com:loconav-tech/app-configurator
              cd ..
            """
          }
        }
    stage("Docker build and push") {
      steps {
        sh """
          docker build -t ${RELEASE_NAME} --build-arg BUNDLE_RUBYGEMS__PKG__GITHUB__COM="loco-bot:$GITHUB_PAT" -f Dockerfile . 
        """
      }
    }
    stage("Push app image") {
      steps {
        sh """
          docker push ${RELEASE_NAME}
        """
      }
    }
            stage("Build and Push Docker Image") {
                steps {
                    sh 'make dev_server'
                    sh 'make push REPO_NAME=$REPO_NAME ECR_URL=$ECR_REPO_URL REGION=$REGION'
                }
    // stage("Helm Package") {
    //  steps {
    //    helmBuildPush(ECR_ADDRESS, SERVICE_NAME, IMAGE_VERSION, BRANCH )
    //  }
    // }
    stage("Deployment") {
      steps {
        script {
          sh """
              echo "Image builded successfully with tag: ${IMAGE_VERSION}"
            """
        }
      }
    }
  }
  post {
    always {
      slackSend(color: COLOR_MAP[currentBuild.currentResult], message: "*${currentBuild.currentResult}:* Job ${env.JOB_NAME} build ${env.BUILD_NUMBER} \n More info at: ${env.BUILD_URL} " )
      rtp abortedAsStable: false, failedAsStable: false, nullAction: '1', parserName: 'Confluence',
          stableText: """
          h2. Previous Build
          Branch: ${params.BRANCH}
          Build Number: ${BUILD_NUMBER}
          h2. Docker Version Published
          ${SERVICE_NAME} Version: ${RELEASE_NAME}
          """, unstableAsStable: false
    }
  }
}
