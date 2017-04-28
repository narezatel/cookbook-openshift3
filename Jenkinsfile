#!groovy

def nodename='cage'
def builddir='cookbook-openshift3-test-' + env.BUILD_NUMBER

try {
  stage('setupenv') {
    node(nodename) {
      sh 'mkdir -p ' + builddir
      dir(builddir) {
        ////when in source...
        checkout scm
      }
    }
  }

  stage('rubocop') {
    node(nodename) {
      dir(builddir) {
        sh 'rubocop -r cookstyle -D'
      }
    }
  }

  stage('kitchen') {
    node(nodename) {
      dir(builddir) {
        def l = sh(script: 'kitchen list -b', returnStdout: true).trim().tokenize()
        for (f in l) {
          // Seeing persistent 'SCP did not finish successfully (255):  (Net::SCP::Error)' errors, so retry added.
          retry(10) {
            sh('kitchen converge ' + f)
            sh('kitchen verify ' + f)
            sh('kitchen destroy ' + f)
          }
        }
      }
    }
  }

  stage('shutit_tests') {
    node(nodename) {
      dir(builddir) {
        sh 'git clone --recursive --depth 1 https://github.com/ianmiell/shutit-openshift-cluster'
        dir('shutit-openshift-cluster') {
          withEnv(["SHUTIT=/usr/local/bin/shutit"]) {
            sh 'COOKBOOK_VERSION=master ./run_tests.sh --interactive 0'
          }
        }
      }
    }
  }
  mail bcc: '', body: '''See: http://jenkins.meirionconsulting.tk/job/cookbook-openshift3-pipeline

RELEASE
=======
- document diff to last tag
- up the metadata value
- tag the cookbook app, commit push
- knife cookbook site share cookbook-openshift3

''', cc: '', from: 'cookbook-openshift3@jenkins.meirionconsulting.tk', replyTo: '', subject: 'Build OK', to: 'ian.miell@gmail.com'
} catch(err) {
  mail bcc: '', body: '''See: http://jenkins.meirionconsulting.tk/job/cookbook-openshift3-pipeline

''' + err, cc: '', from: 'cookbook-openshift3@jenkins.meirionconsulting.tk', replyTo: '', subject: 'Build failure', to: 'ian.miell@gmail.com'
  throw(err)
}
