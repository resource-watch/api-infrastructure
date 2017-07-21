#!groovy

node {

  // Variables
  def appName = 'dataset'
  def dockerUsername = 'vizzuality'
  def imageTag = "${dockerUsername}/${appName}:${env.BRANCH_NAME}.${env.BUILD_NUMBER}"

  currentBuild.result = "SUCCESS"

  checkout scm

  try {

    stage ('Build docker') {
      sh("docker -H :2375 build -t ${imageTag} .")
      sh("docker -H :2375 build -t ${dockerUsername}/${appName}:latest .")
    }

    // stage 'Run Go tests'
    // sh("docker run ${imageTag} --rm test")

    stage('Push Docker') {
      withCredentials([usernamePassword(credentialsId: 'Vizzuality Docker Hub', usernameVariable: 'DOCKER_HUB_USERNAME', passwordVariable: 'DOCKER_HUB_PASSWORD')]) {
        sh("docker -H :2375 login -u ${DOCKER_HUB_USERNAME} -p ${DOCKER_HUB_PASSWORD}")
        sh("docker -H :2375 push ${imageTag}")
        sh("docker -H :2375 rmi ${imageTag}")
      }
    }

    stage ("Deploy Application") {
      switch (env.BRANCH_NAME) {

        // Roll out to staging
        case "develop":
          // Change to staging cluster kubectl set-context

        // Roll out to production
        case "master":
          // Change deployed image in canary to the one we just built
          def service = sh("kubectl get svc dataset")
          if (service && service.indexOf("NotFound")){
            sh("kubectl apply -f k8s/services/")
            sh("kubectl apply -f k8s/production/")
          }
          sh("kubectl set image deployment ${appName} ${appName}=${imageTag} --record")
          break

        // Default behavior?
        default:
          sh("echo default")
      }
    }

    // Notify Success
    slackSend (color: '#00FF00', channel: '#the-new-api', message: "SUCCESSFUL: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
    emailext (
      subject: "SUCCESSFUL: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
      body: """<p>SUCCESSFUL: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]':</p>
        <p>Check console output at "<a href="${env.BUILD_URL}">${env.JOB_NAME} [${env.BUILD_NUMBER}]</a>"</p>""",
      recipientProviders: [[$class: 'DevelopersRecipientProvider']]
    )


  } catch (err) {

    currentBuild.result = "FAILURE"
    // Notify Error
    slackSend (color: '#FF0000', channel: '#the-new-api', message: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
    emailext (
      subject: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
      body: """<p>FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]':</p>
        <p>Check console output at "<a href="${env.BUILD_URL}">${env.JOB_NAME} [${env.BUILD_NUMBER}]</a>"</p>""",
      recipientProviders: [[$class: 'DevelopersRecipientProvider']]
    )
    throw err
  }

}
