#!/bin/bash

usage() {
    echo "Usage: ./run_docker.sh [-b] [-n] [-u] [-c]"
    echo "  -b  Build with cache"
    echo "  -n  Build without cache"
    echo "  -u  Start container and attach"
    echo "  -c  Stop and remove"
}

BUILD=false
NO_CACHE=""
UP=false

while getopts "bnuc" opt; do
    case ${opt} in
        b ) BUILD=true ;;
        n ) BUILD=true; NO_CACHE="--no-cache" ;;
        u ) UP=true ;;
        c ) docker compose -f docker/docker-compose.yml down --remove-orphans; exit 0 ;;
        * ) usage; exit 1 ;;
    esac
done

export USER_UID=$(id -u)
export USER_GID=$(id -g)
export USERNAME=$(id -un)

# --- Build image
if [ "$BUILD" = true ]; then
    DOCKER_BUILDKIT=1 docker compose -f docker/docker-compose.yml build $NO_CACHE
fi

# --- Run and attach
if [ "$UP" = true ]; then
    docker compose -f docker/docker-compose.yml up -d
    docker compose -f docker/docker-compose.yml exec hpdn-env bash
fi
