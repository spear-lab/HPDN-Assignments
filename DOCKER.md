
# Docker Setup (environment/docker)

> **Note:** This Docker environment was tested on Arch Linux (kernel 6.17.7). Paths, package names, and permissions may vary on other systems, so adjust as needed. There is no guarantee that it will work unchanged for all assignments.

This folder provides a complete Docker/development environment for the project.

---

## Contents

* **docker-compose.yml** — service orchestration
* **Dockerfile** — base image and environment setup
* **entrypoint.sh** — container entrypoint (adds helper commands)
* **run_docker.sh** — wrapper script for building and running the environment

---

## Prerequisites

* Docker
* Docker Compose
* Running commands from the `environment` directory:

```bash
cd environment
```

---

## Quick Start

The recommended way to use the environment is via the script located at:

```
./environment/docker/run_docker.sh
```

Make it executable once:

```bash
chmod +x docker/run_docker.sh
```

### Common commands

```bash
# Build → up → shell
# Most commonly used
./docker/run_docker.sh -bu

# Build with cache
./docker/run_docker.sh -b

# Build without cache
./docker/run_docker.sh -n

# Start the stack and open a shell in the main container
./docker/run_docker.sh -u

# Clean up containers
./docker/run_docker.sh -c
```

---

## Helper Tools

### Mininet (`mn`)

The entrypoint installs an `mn()` shell helper to launch Mininet with:

* remote controller at **127.0.0.1:6633**
* OpenFlow **1.3**

Feel free to change the shell helper which can be found under `~/.bashrc` inside the container to your needs.

Usage (inside container):

```bash
mn
```

You may still use mininet normally by calling it using `sudo mn <arguments>`.

### Ryu Controller

The script `environment/start_ryu.sh` launches a Ryu controller **on the host**, assuming a Ryu checkout and virtualenv at:

```
$HOME/sdn/ryu/ryu3.9
```

Update the paths in the script if your environment differs:

```bash
bash environment/start_ryu.sh
```

---

## Entering a running container

```bash
docker ps
docker exec -it <container> bash
```

---

## Notes

This Docker setup is intended for local development and experimentation.