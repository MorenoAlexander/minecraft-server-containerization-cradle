#! /bin/bash
# check for environment variable and request it from user
# environment variables
# - BUILD_REPO_NAME - name of the repository
# - SERVER_FILE_URL - url of the curseforge server file

# - BUILD_TAG - tag of the repository
# - platform - arm or amd64
# - jdk_tag - tag of the openjdk image
# - EXPOSED_PORT - port of the server
# - MAXRAM - max ram of the minecraft server
# - MINRAM - min ram of the minecraft server


# check for environment variable and request it from user
if [ -z "$BUILD_REPO_NAME" ]; then
    echo -n "Please enter the name of the repository"
    read BUILD_REPO_NAME

    # check if the name is empty
    if [ -z "$BUILD_REPO_NAME" ]; then
	echo "The name of the repository is empty"
	exit 1
    fi
fi

# check for environment variable and request it from user
if [ -z "$SERVER_FILE_URL" ]; then
    echo -n "Please enter the url of the curseforge server file"
    read SERVER_FILE_URL

    # verify that the url is in the correct format using regex
    if [[ "$SERVER_FILE_URL" =~ ^https:\/\/[a-zA-Z0-9\/.-]*$ ]];
    then
	echo "URL is valid"
    else
	echo "URL ($SERVER_FILE_URL) is not valid"
	exit 1
    fi
fi



# check for environment variable and request it from user
if [ -z "$BUILD_TAG" ]; then
    echo "Please enter the tag of the repository"
    read BUILD_TAG

    # check if the name is empty
    if [ -z "$BUILD_TAG" ]; then
	echo "The tag of the repository is empty"
	exit 1
    fi
fi


# check for environment variable and request it from user
if [ -z "$platform" ]; then
    echo "Please enter the platform (default: arm64):"
    read platform

    # check if the name is empty and set default value
    if [ -z "$platform" ]; then
	platform="arm64"
    fi
fi

if [ -z "$jdk_tag" ]; then
    echo "Please enter the tag of the openjdk image (default: 11-jdk-bullseye):"
    read jdk_tag

    # check if the name is empty and set default value
    if [ -z "$jdk_tag" ]; then
	jdk_tag="11-jdk-bullseye"
    fi
fi


# check for environment variable and request it from user
if [ -z "$EXPOSED_PORT" ]; then
    echo "Please enter the port (default: 25565):"
    read EXPOSED_PORT

    # valdate the port number
    if [ $EXPOSED_PORT -lt 1 ] || [ $EXPOSED_PORT -gt 65535 ]; then
	echo "Port number ($EXPOSED_PORT) is not valid"
	exit 1
    fi
fi

# check for environment variable and request it from user
if [ -z "$MAXRAM" ]; then
    echo "Please enter the max RAM (default: 5G):"
    read MAXRAM

    if ! [[ $MAXRAM =~ ^[1-9]+G$ ]]; then
	echo "Max RAM ($MAXRAM) is not valid"
	exit 1
    fi
fi

# check for environment variable and request it from user
if [ -z "$MINRAM" ]; then
    echo "Please enter the min RAM (default: 5G):"
    read MINRAM

    if ! [[ $MINRAM =~ ^[1-9]+G$ ]]; then
	echo "Min RAM ($MINRAM) is not valid"
	exit 1
    fi
fi

echo -n "$BUILD_REPO_NAME:$BUILD_TAG"

docker build -t "$BUILD_REPO_NAME:$BUILD_TAG" --build-arg platform=$platform --build-arg jdk_version=$jdk_tag --build-arg SERVER_FILE_URL=$SERVER_FILE_URL --build-arg EXPOSED_PORT=$EXPOSED_PORT --build-arg MAXRAM=$MAXRAM --build-arg MINRAM=$MINRAM .