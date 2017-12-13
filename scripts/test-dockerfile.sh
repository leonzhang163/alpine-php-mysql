echo "test Dockerfile"

testSSH=$(cat Dockerfile | grep EXPOSE | grep 2222)
if [ -z "$testSSH" ]; then 
    echo "PORT 2222 isn't opened, SSH isn't working!!!"
    exit 1
else
    echo "$testSSH"
    echo "PROT 2222 is opened."
fi

testVOLUME=$(cat Dockerfile | grep VOLUME)
if [ -z "$testVOLUME" ]; then 
    echo "Great, there is no VOLUME lines."    
else
    echo "$testVOLUME"
    echo "These VOLUME lines should not be existed!!!"
    exit 1
fi

# Docker file is OK, return 0
exit 0
