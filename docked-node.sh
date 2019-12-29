#!/usr/bin/env bash

DOCKED_NODE_IMAGE="${DOCKER_NODE_IMAGE:-node}"

DOCKED_NODE_PRE_RUN=""
if [ ! -z "$DOCKED_NODE_PRE" ]; then
  DOCKED_NODE_PRE_RUN="RUN $DOCKED_NODE_PRE"
fi

clean() {
  rm -f .docker-node-Dockerfile
}

if [ ! -f package.json ]; then
  >&2 echo "No package.json file found."
  exit 1
fi

rm -f .docked-node-image
>&2 echo "Building docker image..."
cat > .docker-node-Dockerfile <<EOF
FROM ${DOCKED_NODE_IMAGE}
WORKDIR /app
COPY package.json .
RUN npm install
RUN mv node_modules /
COPY . .
${DOCKED_NODE_PRE_RUN}
CMD node .
EOF
trap clean EXIT
docker build --file .docker-node-Dockerfile --iidfile .docked-node-image . 1>&2
DOCKER_IMAGE_ID=$(cat .docked-node-image)
>&2 echo "Running node inside docker container ${DOCKER_IMAGE_ID}..."
>&2 echo ""
docker run --interactive --tty --rm "$DOCKER_IMAGE_ID" "$@"
