#!/usr/bin/env bash

DOCKED_NODE_IMAGE="${DOCKED_NODE_IMAGE:-node}"
DOCKED_NODE_PACKAGE_MANAGER="${DOCKED_NODE_PACKAGE_MANAGER:-}"

DOCKED_NODE_PRE_RUN=""
if [ -n "$DOCKED_NODE_PRE" ]; then
  DOCKED_NODE_PRE_RUN="RUN $DOCKED_NODE_PRE"
fi

clean() {
  rm -f .docker-node-Dockerfile
}

if [ ! -f package.json ]; then
  >&2 echo "No package.json file found."
  exit 1
fi

if [ -n "$DOCKED_NODE_PACKAGE_MANAGER" ]; then
  case "$DOCKED_NODE_PACKAGE_MANAGER" in
    npm|yarn|pnpm) ;;
    *)
      >&2 echo "Unsupported package manager: $DOCKED_NODE_PACKAGE_MANAGER"
      exit 1
      ;;
  esac
fi

NO_DOCKERIGNORE=false
if [ ! -f .dockerignore ]; then
  NO_DOCKERIGNORE=true
  cat > .dockerignore <<EOF
.git
node_modules
**/node_modules
EOF
fi

rm -f .docked-node-image
>&2 echo "Building docker image..."
cat > .docker-node-Dockerfile <<EOF
FROM ${DOCKED_NODE_IMAGE}
WORKDIR /app
COPY package.json .
EOF
for lockfile in package-lock.json npm-shrinkwrap.json yarn.lock pnpm-lock.yaml; do
  if [ -f "$lockfile" ]; then
    printf 'COPY %s .\n' "$lockfile" >> .docker-node-Dockerfile
  fi
done
cat >> .docker-node-Dockerfile <<EOF
RUN package_manager="${DOCKED_NODE_PACKAGE_MANAGER}"; \\
  if [ -z "\$package_manager" ]; then \\
    package_manager="\$(node -e 'const manager = require("./package.json").packageManager || ""; process.stdout.write(manager.split("@")[0]);')"; \\
  fi; \\
  if [ -z "\$package_manager" ]; then \\
    if [ -f pnpm-lock.yaml ]; then package_manager=pnpm; \\
    elif [ -f yarn.lock ]; then package_manager=yarn; \\
    else package_manager=npm; \\
    fi; \\
  fi; \\
  case "\$package_manager" in npm|yarn|pnpm) ;; *) echo "Unsupported package manager: \$package_manager" >&2; exit 1 ;; esac; \\
  "\$package_manager" install
RUN mv node_modules /
COPY . .
${DOCKED_NODE_PRE_RUN}
CMD node .
EOF
trap clean EXIT
docker build --file .docker-node-Dockerfile --iidfile .docked-node-image . 1>&2
if $NO_DOCKERIGNORE; then
  rm .dockerignore
fi
DOCKER_IMAGE_ID=$(cat .docked-node-image)
>&2 echo "Running node inside docker container ${DOCKER_IMAGE_ID}..."
>&2 echo ""
docker run --interactive --tty --rm "$DOCKER_IMAGE_ID" "$@"
