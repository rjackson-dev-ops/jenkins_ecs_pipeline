

/* Setup RVM environment for build */
def setupRvm(project_name) {
  println 'PROJECT_NAME=' + project_name
  withEnv(['PROJECT_NAME=' + project_name]) {
      sh returnStdout: true, script: '''#!/bin/bash -l
      set +x
      source ~/.rvm/scripts/rvm && \
        rvm use --install --create 2.5.1@${PROJECT_NAME} && \
        export | egrep -i "(ruby|rvm)" > rvm.env
      set -x
      bundle install --jobs 8 --retry 10 --with integration > output.txt && \
        wc -l output.txt && \
        cat output.txt
      '''
  }
}

/****PRINTS ENV VARIABLES AVAILABLE TO THE CONSOLE****/
def printEnvironment() {
    sh '''
        echo "-- Environment variables --" && env | sort
    '''
}

/* Invoke Shell task */
def runShellTask(task, outputFile = 'outputFile.log') {
  println "${task}"
  def status = sh returnStatus: true, script: """
      exec &> >(tee -a ${outputFile})
      set +x
      . rvm.env
      set -x
      time ${task}
  """

    if(status != 0) {
      error "${task} failed"
    }
}

/* Invoke Rake task */
def runRake(task, outputFile = 'outputFile.log') {
  println "${task}"
  def status = sh returnStatus: true, script: """
      exec &> >(tee -a ${outputFile})
      set +x
      . rvm.env
      set -x
      time bundle exec rake ${task}
  """

    if(status != 0) {
      error "${task} failed"
    }
}

/* Invoke Rake task Silently */
def runRakeSilently(task) {
  println "${task}"
  def status = sh returnStatus: true, script: """
      . rvm.env
      time bundle exec rake ${task}
  """

    if(status != 0) {
      error "${task} failed"
    }
}

/****Print Hello Task****/
def printHello() {
  println 'Command Tasks Hello'
}

return this
