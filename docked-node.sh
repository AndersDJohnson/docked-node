#!/usr/bin/env bash

DOCKER_NODE_IMAGE="${DOCKER_NODE_IMAGE:-node}"

clean() {
  rm -f "$TMP_DOCKERFILE"
}

docker-here() {
  docker run --interactive --tty --rm --mount src="$(pwd)",target=/app,type=bind --workdir /app "$@"
}

if [ ! -f package.json ]; then
  >&2 echo "No package.json file found."
  exit 1
fi

DOCKER_IMAGE_ID=$(cat .docked-node-image 2>/dev/null || true)
PKG_SHA_OLD=$(cat .docked-node-hash 2>/dev/null || true)
PKG_SHA_NEW=$(shasum package.json | cut -d' ' -f 1)

>&2 echo "Previous docker image: ${DOCKER_IMAGE_ID}"
>&2 echo "Previous package hash: ${PKG_SHA_OLD}"
>&2 echo "Current package hash: ${PKG_SHA_NEW}"

[ "$PKG_SHA_OLD" != "$PKG_SHA_NEW" ] && PKG_CHANGE=true || PKG_CHANGE=false

>&2 echo "Package changes? ${PKG_CHANGE}"

if $PKG_CHANGE || [ -z "$DOCKER_IMAGE_ID" ]; then
  rm -f .docked-node-image
  echo "$PKG_SHA_NEW" > .docked-node-hash
  >&2 echo "No previous docker image, or package changes. Building docker image..."
  TMP_DOCKERFILE=$(mktemp .Dockerfile.XXXXXX)
  TMP_BUILD_OUT=$(mktemp .docker-build-out.XXXXXX)
  cat > "$TMP_DOCKERFILE" <<EOF
FROM ${DOCKER_NODE_IMAGE}
WORKDIR /app
COPY package.json .
RUN npm install
COPY . .
RUN npm run build || true
RUN mv node_modules /
CMD node .
EOF
  trap clean EXIT
  docker build --file "$TMP_DOCKERFILE" --iidfile .docked-node-image . 1>&2
  DOCKER_IMAGE_ID=$(cat .docked-node-image)
  >&2 echo "Docker image built: ${DOCKER_IMAGE_ID}"
  >&2 echo "Running node inside docker container ${DOCKER_IMAGE_ID}..."
  >&2 echo ""
  docker run --interactive --tty --rm "$DOCKER_IMAGE_ID" "$@"
else
  >&2 echo "Docker image already up-to-date."
  >&2 echo "Running node inside docker container ${DOCKER_IMAGE_ID}..."
  >&2 echo ""
  docker-here "$DOCKER_IMAGE_ID" "$@"
fi
