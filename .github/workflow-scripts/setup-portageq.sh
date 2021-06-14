#! /usr/bin/env bash
# Original Author: Andrew Ammerlaan <andrewammerlaan@gentoo.org>
# Modifier: Yuan Liao <liaoyuan@gmail.com>
#
# This script sets up portageq, which is a Portage command required by
# java-ebuilder.  It was modified from 'scripts/setup-and-run-repoman.sh' that
# can be found under the source trees of GURU and Gentoo Science Overlay.

### Setup prerequisites
python3 -m pip install --upgrade pip
pip install lxml pyyaml
sudo groupadd -g 250 portage
sudo useradd -g portage -d /var/tmp/portage -s /bin/false -u 250 portage

### Sync the portage repository
git clone https://github.com/gentoo/portage.git
cd portage

# Get all versions, and read into array
mapfile -t RM_VERSIONS < <( git tag | grep portage | sort -Vu )

# Select latests version (last element in array)
RM_VERS="${RM_VERSIONS[-1]}"

# Checkout this version
git checkout tags/${RM_VERS} -b ${RM_VERS}

cd ..

# Install a wrapper script for portageq
target_path=/usr/local/bin/portageq
sudo bash -c 'cat << EOF > '${target_path}'
#!/usr/bin/env bash

python3 "${PWD}/portage/bin/portageq" "\$@"
EOF'
sudo chmod +x ${target_path}
