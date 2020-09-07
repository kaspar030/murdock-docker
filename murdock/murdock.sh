#!/bin/sh

export GIT_CACHE_DIR=/murdock/git-cache
export DWQ_DISQUE_URL=disque:7711

set -e

echo "Copying /murdock/.ssh to /home/murdock..."
cp -a /murdock/.ssh /srv/murdock
chown -R murdock:murdock /srv/murdock/.ssh
chown 0600 /srv/murdock/.ssh/id_* | true

git-cache init

echo "Launching Murdock..."
exec murdock /murdock/murdock.toml
