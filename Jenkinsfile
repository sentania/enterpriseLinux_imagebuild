

node () {

env.IMAGE_OUTPUT_DIR = "/var/lib/jenkins/packer_output/enterpriseLinux7/$BUILD_TAG"

deleteDir()

      stage ('Checkout Build Code') {
         checkout scm
       }

      stage ('Build Image'){
        sh '/usr/bin/packer.1.2.1 build --color=false -var-file=build_version-7.4.json -only=CentOS enterprise_linux.json'
      }

      stage ('Package Image(s)')
      {
        //sh 'ovftool --shaAlgorithm=SHA1 $IMAGE_OUTPUT_DIR/output-vmware-iso-rhel/RHEL-7.4.vmx $IMAGE_OUTPUT_DIR/output-vmware-iso-rhel/RHEL-7-4.ova'
        sh 'ovftool --shaAlgorithm=SHA1 $IMAGE_OUTPUT_DIR/output-vmware-iso-centos/CentOS-7.4.vmx $IMAGE_OUTPUT_DIR/output-vmware-iso-centos/CentOS-7-4.ova'

      }

  if (env.BRANCH_NAME == 'master' || env.BRANCH_NAME == 'Development') {
        withCredentials([usernamePassword(credentialsId: 'c574ec56-5665-4bb6-84f1-98d8316ba488',
          usernameVariable: 'nexusUSERNAME', passwordVariable: 'nexusPASSWORD'),
          usernamePassword(credentialsId: '75124b79-b775-4189-9025-0f37b756e83d',
          usernameVariable: 'vSphereUSERNAME', passwordVariable: 'vSpherePASSWORD')
          ])
        {
          stage ('Upload Image(s) to Nexus')
          {
            //sh 'curl -k -v -u $nexusUSERNAME:$nexusPASSWORD --upload-file $IMAGE_OUTPUT_DIR/output-vmware-iso-rhel/RHEL-7-4.ova https://nexus.int.sentania.net/repository/labRepo/lab/enterpriseLinux/RHEL-7-4-$BUILD_TAG.ova'
            sh 'curl -k -v -u $nexusUSERNAME:$nexusPASSWORD --upload-file $IMAGE_OUTPUT_DIR/output-vmware-iso-centos/CentOS-7-4.ova https://nexus.int.sentania.net/repository/labRepo/lab/images/enterpriseLinux/CentOS-7-4-$BUILD_TAG.ova'
          }
          stage ('Upload Image(s) to vsphere')
          {
            sh '/bin/pwsh deploy-image.ps1 -outputdir $IMAGE_OUTPUT_DIR -BUILD_TAG $BUILD_TAG -GIT_BRANCH $JOB_NAME -vSphereUSERNAME $vSphereUSERNAME -vSpherePASSWORD $vSpherePASSWORD'
          }
        }

          stage ('Clean packer output files')
          {
            sh 'rm -rf $IMAGE_OUTPUT_DIR'
          }
    }
}
