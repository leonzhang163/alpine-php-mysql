TRAVIS_EVENT_TYPE="push"
TRAVIS_COMMIT_MESSAGE="Meger Pull XXXX"

if [ "$TRAVIS_EVENT_TYPE" == "push" ]; then
    echo "TRAVIS_EVENT_TYPE=push"
    MegerPull="Meger Pull"
    Version="Version:"
    pushed="false"
    if [[ $TRAVIS_COMMIT_MESSAGE == $Version* ]]; then
            echo "TRAVIS_COMMIT_MESSAGE=Meger Pull XXXX"            
            pushed="true"
    fi 
    if [[ $TRAVIS_COMMIT_MESSAGE == $MegerPull* ]]; then        
        pushed="true"       
    fi
    if [ "$pushed" == "false" ]; then
       echo "pushed false"
    else
       echo "pushed true"        
    fi
else    
    echo "TRAVIS_EVENT_TYPE=pull request"
fi