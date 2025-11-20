FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# ---------------------------------------------------------
# Base system packages
# ---------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential curl wget git vim \
    ca-certificates gnupg2 lsb-release locales \
    python3 python3-venv python3-pip python3-full python3-dev \
    sudo openssh-client pkg-config unzip zip \
    libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev \
    libffi-dev liblzma-dev tk-dev uuid-dev libncurses5-dev libncursesw5-dev \
    mininet \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------
# User Setup
# ---------------------------------------------------------
# --- User Setup
ARG USER_UID
ARG USER_GID
ARG USERNAME

RUN set -eux; \
    \
    echo "Removing conflicting users/groups..."; \
    \
    # Remove group with same GID
    EXISTING_GRP_BY_GID=$(getent group "${USER_GID}" | cut -d: -f1 || true); \
    if [ -n "$EXISTING_GRP_BY_GID" ]; then \
        echo "Removing existing group with GID ${USER_GID}: $EXISTING_GRP_BY_GID"; \
        groupdel "$EXISTING_GRP_BY_GID" || true; \
    fi; \
    \
    # Remove user with same UID
    EXISTING_USER_BY_UID=$(getent passwd "${USER_UID}" | cut -d: -f1 || true); \
    if [ -n "$EXISTING_USER_BY_UID" ]; then \
        echo "Removing existing user with UID ${USER_UID}: $EXISTING_USER_BY_UID"; \
        userdel -r "$EXISTING_USER_BY_UID" || true; \
    fi; \
    \
    # Remove group with same name
    if getent group "${USERNAME}" >/dev/null; then \
        echo "Removing existing group named ${USERNAME}"; \
        groupdel "${USERNAME}" || true; \
    fi; \
    \
    # Remove user with same name
    if id "${USERNAME}" >/dev/null 2>&1; then \
        echo "Removing existing user named ${USERNAME}"; \
        userdel -r "${USERNAME}" || true; \
    fi; \
    \
    echo "Creating fresh user/group ${USERNAME} (${USER_UID}:${USER_GID})"; \
    groupadd --gid "${USER_GID}" "${USERNAME}"; \
    useradd -m -u "${USER_UID}" -g "${USER_GID}" -s /bin/bash "${USERNAME}"; \
    usermod -aG sudo "${USERNAME}"; \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

ENV USER=${USERNAME}
ENV HOME=/home/${USERNAME}
WORKDIR /home/${USERNAME}

USER ${USERNAME}

# ---------------------------------------------------------
# Install P4 Tools (takes a long time)
# ---------------------------------------------------------
RUN git clone https://github.com/jafingerhut/p4-guide.git ~/p4-guide && \
    cd ~/p4-guide/bin && \
    ./install-p4dev-v9.sh


# ---------------------------------------------------------
# Install pyenv (Python 3.9.19 ONLY for Ryu)
# ---------------------------------------------------------
ENV PYENV_ROOT="$HOME/.pyenv"
ENV PATH="$PYENV_ROOT/bin:$PATH"

# Install pyenv itself
RUN curl -fsSL https://pyenv.run | bash

# Add pyenv initialization to shell startup
RUN echo 'export PYENV_ROOT="$HOME/.pyenv"' >> "$HOME/.bashrc" && \
    echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> "$HOME/.bashrc" && \
    echo 'eval "$(pyenv init --path)"' >> "$HOME/.bashrc" && \
    echo 'eval "$(pyenv init -)"' >> "$HOME/.bashrc"

# Use bash login shell for all subsequent RUN commands
SHELL ["/bin/bash", "-lc"]

# Install Python 3.9.19 ONLY (do not set global)
RUN pyenv install 3.9.19

# ---------------------------------------------------------
# Install Ryu using pyenv Python 3.9.19 (isolated venv)
# ---------------------------------------------------------
RUN mkdir -p ~/sdn && cd ~/sdn && git clone https://github.com/faucetsdn/ryu.git

# Create dedicated local Python version for this directory & its venv
RUN cd ~/sdn/ryu && \
    export PYENV_ROOT="$HOME/.pyenv" && \
    export PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH" && \
    eval "$(pyenv init --path)" && \
    eval "$(pyenv init -)" && \
    pyenv local 3.9.19 && \
    python -m venv ryu3.9

# Install Ryu dependencies inside the new venv
RUN cd ~/sdn/ryu && \
    source ryu3.9/bin/activate && \
    pip install --upgrade 'pip<24' wheel && \
    pip install 'setuptools==67.6.1' && \
    pip install 'eventlet==0.31.1' 'greenlet<2.0' && \
    pip install . --no-build-isolation

# ---------------------------------------------------------
# Extra Packages (install as ROOT)
# ---------------------------------------------------------

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        openvswitch-switch openvswitch-common iputils-ping iproute2 net-tools dnsutils \
        traceroute tcpdump telnet netcat-openbsd bridge-utils ethtool wireshark && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install GUI packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    x11-apps \
    zenity \
    wireshark \
    dbus-x11 \
    libx11-6 \
    libxext6 \
    libxrender1 \
    libxft2 \
    libxinerama1 \
    libxcursor1 \
    libglu1-mesa \
    mesa-utils \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install QT packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    qtbase5-dev \
    qtbase5-dev-tools \
    libqt5gui5 \
    libqt5widgets5 \
    libqt5svg5 \
    libqt5network5 \
    libqt5core5a \
    libqt5dbus5 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/openvswitch && \
    mkdir -p /etc/openvswitch && \
    chown -R root:root /var/run/openvswitch /etc/openvswitch

# ---------------------------------------------------------
# Entrypoint (runs as ROOT)
# ---------------------------------------------------------

COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/bin/bash"]

    