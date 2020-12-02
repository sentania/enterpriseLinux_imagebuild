node () {

env.IMAGE_OUTPUT_DIR = "/var/lib/jenkins/packer_output/enterpriseLinux7/$BUILD_TAG"

deleteDir()

      stage ('Checkout Build Code') {
         checkout scm
       }
        withCredentials([usernamePassword(credentialsId: 'vcenter_admin',
        usernameVariable: 'vCenterUsername', passwordVariable: 'vCenterPassword')]){
        stage ('Build Image') {
        sh '/usr/local/bin/packer.1.6.3 build -force -on-error=abort -var "password=$vCenterPassword" -var "username=$vCenterUsername" -var-file variables.json enterprise_linux.json'
        }
        stage ('Sync Content Library') {
        sh '/bin/pwsh sync-contentlibrary.ps1 -vsphereUSERNAME $vCenterUsername -vspherePassword $vCenterPassword'
        }

      }
    }