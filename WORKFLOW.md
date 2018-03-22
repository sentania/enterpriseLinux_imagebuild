# Workflow Base OS creation

The process flow for Golden Template creation is following a software engineering approach.

## Assumptions

* Jenkins is setup and pointed at this git repo
* Testing code is stored next to the build code
* More than one pipeline is allowed


# Ideal Flow of work

## Software Development

A git flow based approach is utilized where by every new development utilizes a feature branch off of master

   * Branch off of master and name the branch F<something>
   * Develop new functionality locally and test locally
   * When code is pushed to the branch F<something> a build is kicked off in Jenkins

When that feature is ready to be merged

   * The merge into master will require a code review and successful build before merge is accepted

When the set of features are ready to be deployed out as the next release, a different build will be started by merging changes to master
   * This is defined as a manual execution and decision made by the repo owner to merge.

   * On Success, This will kick off a deployment pipeline to push this to
	 * vSphere
