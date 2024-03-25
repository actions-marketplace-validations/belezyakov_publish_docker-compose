VERSION="$1"
DOCKER_COMPOSE="$2"
REPO_TOKEN="$3"
GITHUB_REPOSITORY=$(echo "$GITHUB_REPOSITORY" | awk '{print tolower($0)}')

echo "VERSION=$VERSION"
echo "DOCKER_COMPOSE=$DOCKER_COMPOSE"

# login to github
docker ghcr.io -u ${GITHUB_REF} -p ${REPO_TOKEN}

# build and run the docker images
docker-compose -f $DOCKER_COMPOSE up --no-start

# get all built IDs
IMAGE_IDs=$(docker-compose -f $DOCKER_COMPOSE images -q)

echo "IMAGE_IDs: $IMAGE_IDs"

while read -r IMAGE_ID; do

    echo "IMAGE_ID: $IMAGE_ID"
    # get the name label
    NAME=$(basename ${GITHUB_REPOSITORY}).$(docker inspect --format '{{ index .Config.Labels.name }}' $IMAGE_ID)
    TAG="ghcr.io/${GITHUB_REPOSITORY}/$NAME:$VERSION"

    # tag and push
    docker tag $IMAGE_ID $TAG
    docker push $TAG

done <<< "$IMAGE_IDs"