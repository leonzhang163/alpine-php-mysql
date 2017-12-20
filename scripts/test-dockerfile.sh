echo "Show ENV Paramters:"

# TRAVIS_ALLOW_FAILURE: 
# set to true if the job is allowed to fail.
# set to false if the job is not allowed to fail.
echo "TRAVIS_ALLOW_FAILURE: $TRAVIS_ALLOW_FAILURE"
# TRAVIS_BRANCH: 
# for push builds, or builds not triggered by a pull request, this is the name of the branch.
# for builds triggered by a pull request this is the name of the branch targeted by the pull request.
# for builds triggered by a tag, this is the same as the name of the tag (TRAVIS_TAG). 
echo "TRAVIS_BRANCH: $TRAVIS_BRANCH"
# TRAVIS_BUILD_DIR: The absolute path to the directory where the repository being built has been copied on the worker.
echo "TRAVIS_BUILD_DIR: $TRAVIS_BUILD_DIR"
# TRAVIS_BUILD_ID: The id of the current build that Travis CI uses internally.
echo "TRAVIS_BUILD_ID: $TRAVIS_BUILD_ID"
# TRAVIS_BUILD_NUMBER: The number of the current build (for example, “4”).
echo "TRAVIS_BUILD_NUMBER: $TRAVIS_BUILD_NUMBER"
# TRAVIS_COMMIT: The commit that the current build is testing.
echo "TRAVIS_COMMIT: $TRAVIS_COMMIT"
# TRAVIS_COMMIT_MESSAGE: The commit subject and body, unwrapped.
echo "TRAVIS_COMMIT_MESSAGE: $TRAVIS_COMMIT_MESSAGE"
# TRAVIS_COMMIT_RANGE: The range of commits that were included in the push or pull request. (Note that this is empty for 
# builds triggered by the initial commit of a new branch.)
echo "TRAVIS_COMMIT_RANGE: $TRAVIS_COMMIT_RANGE"
# TRAVIS_EVENT_TYPE: Indicates how the build was triggered. One of push, pull_request, api, cron.
echo "TRAVIS_EVENT_TYPE: $TRAVIS_EVENT_TYPE"
# TRAVIS_JOB_ID: The id of the current job that Travis CI uses internally.
echo "TRAVIS_JOB_ID: $TRAVIS_JOB_ID"
# TRAVIS_JOB_NUMBER: The number of the current job (for example, “4.1”).
echo "TRAVIS_JOB_NUMBER: $TRAVIS_JOB_NUMBER"
# TRAVIS_OS_NAME: On multi-OS builds, this value indicates the platform the job is running on. Values are linux and osx currently, 
# to be extended in the future.
echo "TRAVIS_OS_NAME: $TRAVIS_OS_NAME"
# TRAVIS_PULL_REQUEST: The pull request number if the current job is a pull request, “false” if it’s not a pull request.
echo "TRAVIS_PULL_REQUEST: $TRAVIS_PULL_REQUEST"
# TRAVIS_PULL_REQUEST_BRANCH: 
# if the current job is a pull request, the name of the branch from which the PR originated.
# if the current job is a push build, this variable is empty ("").
echo "TRAVIS_PULL_REQUEST_BRANCH: $TRAVIS_PULL_REQUEST_BRANCH"
# TRAVIS_PULL_REQUEST_SHA: 
# if the current job is a pull request, the commit SHA of the HEAD commit of the PR.
# if the current job is a push build, this variable is empty ("").
echo "TRAVIS_PULL_REQUEST_SHA: $TRAVIS_PULL_REQUEST_SHA"
# TRAVIS_PULL_REQUEST_SLUG: 
# if the current job is a pull request, the slug (in the form owner_name/repo_name) of the repository from which the PR originated.
# if the current job is a push build, this variable is empty ("").
echo "TRAVIS_PULL_REQUEST_SLUG: $TRAVIS_PULL_REQUEST_SLUG"
# TRAVIS_REPO_SLUG: The slug (in form: owner_name/repo_name) of the repository currently being built.
echo "TRAVIS_REPO_SLUG: $TRAVIS_REPO_SLUG"
# TRAVIS_SECURE_ENV_VARS: 
# set to true if there are any encrypted environment variables.
# set to false if no encrypted environment variables are available.
echo "TRAVIS_SECURE_ENV_VARS: $TRAVIS_SECURE_ENV_VARS"
# TRAVIS_SUDO: true or false based on whether sudo is enabled.
echo "TRAVIS_SUDO: $TRAVIS_SUDO"
# TRAVIS_TEST_RESULT: is set to 0 if the build is successful and 1 if the build is broken.
echo "TRAVIS_TEST_RESULT: $TRAVIS_TEST_RESULT"
# TRAVIS_TAG: If the current build is for a git tag, this variable is set to the tag’s name.
echo "TRAVIS_TAG: $TRAVIS_TAG"


test_Dockerfile(){
    testSSH=$(cat Dockerfile | grep EXPOSE | grep 2222)
    if [ -z "$testSSH" ]; then 
        echo "FAILED - PORT 2222 isn't opened, SSH isn't working!!!"
        exit 1
    else
        echo "$testSSH"
        echo "PASSED - PROT 2222 is opened."
    fi

    testVOLUME=$(cat Dockerfile | grep VOLUME)
    if [ -z "$testVOLUME" ]; then 
        echo "PASSED - Great, there is no VOLUME lines."    
    else
        echo "$testVOLUME"
        echo "FAILED - These VOLUME lines should not be existed!!!"
        exit 1
    fi
}

build_image(){
    docker login -u="$DOCKER_USERNAME" -p="$DOCKER_PASSWORD"
    docker build -t apm .
    testBuildImage = $(docker images | grep apm)
    if [ -z "$testBuildImage" ]; then 
        echo "FAILED - Build fail!!!"
        exit 1
    else
        echo "$testBuildImage"
        echo "PASSED - Build Successfully!!!."
    fi
}



echo "================================================="
echo "Stage1 - Verify Dockerfile"
test_Dockerfile
echo "================================================="

echo "Stage2 - Build Image"
build_image
echo "================================================="

echo "Stage3 - Set Tag and Push"
echo "Build Number: $TRAVIS_BUILD_NUMBER"
if [ $TRAVIS_PULL_REQUEST ]; then 
    echo "This is PUSH."
    TAG = "PUSH$TRAVIS_BUILD_NUMBER"    
else
    echo "This is PR."
    TAG = "PR$TRAVIS_BUILD_NUMBER"    
fi
echo "TAG: $TAG"
docker tag apm $DOCKER_USERNAME/apm:"$TAG"
docker push $DOCKER_USERNAME/apm:"$TAG"
echo "================================================="

echo "Stage4 - PULL and Verify"
docker run -d --rm -p 80:80 $DOCKER_USERNAME/apm:review
echo "PULL and run successfully, you can manually verify it."
echo "================================================="


# Everything is OK, return 0
exit 0
