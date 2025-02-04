FROM docker.io/ubuntu:22.04

RUN \
    apt-get update && \
    apt-get install -y \
    build-essential \
    curl \
    gcc \
    vim \
    tree \
    file

RUN \
    echo "**** install node repo ****" && \
    curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && \
    echo 'deb https://deb.nodesource.com/node_14.x jammy main' \
        > /etc/apt/sources.list.d/nodesource.list && \
    echo "**** install build dependencies ****" && \
    apt-get update && \
    apt-get install -y \
    nodejs

RUN \
    echo "**** install runtime dependencies ****" && \
    apt-get install -y \
    git \
    jq \
    libatomic1 \
    nano \
    net-tools \
    sudo \
    podman \
    wget \
    python3 \
    python3-pip 

RUN \
    echo "**** install code-server ****" && \
    if [ -z ${CODE_RELEASE+x} ]; then \
        CODE_RELEASE=$(curl -sX GET https://api.github.com/repos/coder/code-server/releases/latest \
        | awk '/tag_name/{print $4;exit}' FS='[""]' | sed 's|^v||'); \
    fi && \
    mkdir -p /app/code-server && \
    curl -o \
        /tmp/code-server.tar.gz -L \
        "https://github.com/coder/code-server/releases/download/v${CODE_RELEASE}/code-server-${CODE_RELEASE}-linux-amd64.tar.gz" && \
    tar xf /tmp/code-server.tar.gz -C \
        /app/code-server --strip-components=1 && \
    echo "**** patch 4.0.2 ****" && \
    if [ "${CODE_RELEASE}" = "4.0.2" ] && [ "$(uname -m)" !=  "x86_64" ]; then \
        cd /app/code-server && \
        npm i --production @node-rs/argon2; \
    fi && \
    echo "**** clean up ****" && \
    apt-get purge --auto-remove -y \
        build-essential \
        nodejs && \
    apt-get clean && \
    rm -rf \
        /config/* \
        /tmp/* \
        /var/lib/apt/lists/* \
        /var/tmp/* \
        /etc/apt/sources.list.d/nodesource.list

ENV USER=jovyan \
    UID=1001 \
    GID=100 \
    HOME=/workspace \
    PATH=/opt/conda/bin:/app/code-server/bin/:$PATH:/app/code-server/

RUN \
    echo "**** install jupyter-hub native proxy ****" && \
    pip3 install jhsingle-native-proxy>=0.0.9 && \
    echo "**** install bash kernel ****" && \
    pip3 install bash_kernel && \
    python3 -m bash_kernel.install

RUN \
    echo "**** adds user jovyan ****" && \
    useradd -m -s /bin/bash -N -u $UID $USER 

COPY entrypoint.sh /opt/entrypoint.sh

RUN chmod +x /opt/entrypoint.sh

RUN apt-get update && apt-get install -y xz-utils

RUN mkdir -m 0755 /nix && chown jovyan /nix 

RUN \
    echo "**** required by cwltool docker pull even if running with --podman ****" && \
    ln -s /usr/bin/podman /usr/bin/docker

ENTRYPOINT ["/opt/entrypoint.sh"]

EXPOSE 8888

RUN chown -R 1001:100 /workspace
USER jovyan


# USER jovyan

# RUN wget --output-document=/dev/stdout https://nixos.org/nix/install | sh -s -- --no-daemon
# RUN . ~/.nix-profile/etc/profile.d/nix.sh

# ENV PATH="$HOME/.nix-profile/bin:$PATH"

# USER root

# ENV DEVBOX_USE_VERSION=0.13.7
# RUN wget --quiet --output-document=/dev/stdout https://get.jetify.com/devbox   | bash -s -- -f
# RUN chown -R "1001:100" /usr/local/bin/devbox


USER jovyan

