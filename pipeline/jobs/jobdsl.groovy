def rubyVersion = JobSetup.rubyVersion = '2.3.7'
def email = JobSetup.email = 'robert.jackson@stelligent.com'
def repo = 'https://github.com/rjackson-dev-ops/jenkins_ecs_pipeline.git'
def sshRepo = 'git@github.com:rjackson-dev-ops/jenkins_ecs_pipeline.git'
def ruby_version = '2.3.7'
def branch = 'master'

pipelineJob('timetracker-pipeline') {



  description("Time Tracker Pipeline")
  keepDependencies(false)

  properties{
    githubProjectUrl (repo)
    rebuild {
      autoRebuild(false)
    }
  }

  triggers {
    scm('* * * * *')
  }

  concurrentBuild(false)

  definition {
    cpsScm {
      scm {
        git {
          remote { url(sshRepo) }
          branches(branch)
          scriptPath('pipeline/jobs/Jenkinsfile')
          extensions { }  // required as otherwise it may try to tag the repo, which you may not want
        }

      }
    }
  }
}