#!/bin/sh

# Shared script to setup OP environment for DevContainers and Cog

apt-get update -y && apt-get install -y \
    `# For Replay` \
    jq \
    tigervnc-standalone-server \
    ffmpeg \
    faketime \
    tmux \
    `# For Debugging X stuff` \
    mesa-utils \
    `# For script calcuation` \
    bc \
    `# For network monitoring` \
    net-tools \
    `# Missing in the base cog image` \
    sudo \
    git

git clone --depth 1 --recurse-submodules https://github.com/commaai/openpilot /home/batman/openpilot

cd /home/batman/openpilot || exit

# Compile openpilot UI and replay
export POETRY_VIRTUALENVS_CREATE=false
export PYENV_VERSION=3.11.4
export PYENV_ROOT="/root/.pyenv_openpilot"
export PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"

# Set Debian noninteractive mode
export DEBIAN_FRONTEND=noninteractive

# Install python dependencies
./tools/ubuntu_setup.sh

 rm -rf /tmp/* && \
    rm -rf /root/.cache && \
    pip uninstall -y poetry && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

scons -j8 tools/replay/replay selfdrive/ui/_ui

# Only copy the folders we need from the build repo to /home/batman/openpilot_min
mkdir -p /home/batman/openpilot_min
mv /home/batman/openpilot/selfdrive /home/batman/openpilot_min
mv /home/batman/openpilot/tools /home/batman/openpilot_min
mv /home/batman/openpilot/third_party /home/batman/openpilot_min

# Get the commit used to build openpilot and save it to /home/batman/openpilot/COMMIT
git rev-parse HEAD > /home/batman/openpilot_min/COMMIT

# Blow away openpilot folder that was used to build openpilot_min
rm -rf /home/batman/openpilot
# Rename openpilot_min to openpilot
mv /home/batman/openpilot_min /home/batman/openpilot

# Blow away pyenv used to build openpilot
rm -rf /root/.pyenv_openpilot