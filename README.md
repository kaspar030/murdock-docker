# Getting started

Murdock needs a specific folder for configuration for data and state:

```
${MURDOCK_BASE}/
├── murdock.toml
├── scripts/
│   ├── github.com/RIOT-OS/murdock-scripts
├── ssh-slave-keys/
├── ssh-host-keys/
├── html/
│   ├── github.com/RIOT-OS/murdock-html
└── data/

```

Docker compose is used to deploy murdock master, nginx, disque, and ssh.

The current docker-compose.yml configures this to be /srv/murdock.
If needed, change to reflect local setup.
Some steps may require sudo access.

# Setup
Export the desired directory, for this example use:
```
export MURDOCK_BASE=/srv/murdock
```

Create the base directory for murdock and directory structure.
```
mkdir -p \
${MURDOCK_BASE}/ssh-slave-keys \
${MURDOCK_BASE}/ssh-host-keys \
${MURDOCK_BASE}/.ssh \
${MURDOCK_BASE}/data

```

Clone the needed repos.
```
git clone https://github.com/RIOT-OS/murdock-html ${MURDOCK_BASE}/html

# Special branch needed for docker
git clone https://github.com/kaspar030/murdock-scripts ${MURDOCK_BASE}/scripts
```

Create `${MURDOCK_BASE}/html/js/murdock-config.js` and replace values as needed.
This is used for the webserver.
```
var murdockConfig={
    'baseURL' : 'ci.riot-os.org',
    'repo_path': 'RIOT-OS/RIOT',
    'default_branch': 'master',
}
```

Add a public keys of murdock slaves to the `ssh-slave-keys`.
This maps to the `authorized_keys` in docker and must be named `murdock-slave`.
For security reasons `command=no-agent-forwarding,no-X11-forwarding,permitopen="disque:7711"` can be added to the start of the keys.

An example of adding the `murdock-slave` key:

```
export MY_PUBLIC_MURDOCK_SLAVE_KEY=murdock-slave

echo "command=\"echo 'This account can only be used for murdock slaves.'\",no-agent-forwarding,no-X11-forwarding,permitopen=\"disque:7711\" ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDJUfzglc64RN+5t/+hwsgIDPPAmxksdQErANQOJVH38+koT5Md7imF8KgbueD52D4E3TQkc483SgeiDfD1/q4nI6E4AEWvVHh0GRngB7y6PaAvCnN9gtoF9id99+CXXg4adSdTWgEL6DXf7mkfir5vgvYlyYdnCOjyZwvEJHQK756zc5WN5NC3f2HFsOaNkmSFlRzM8tEc2C/eaZ6sie2mzNXz5QqiWlG7hmQIgj/wTYx+OHIVl66Wm9TqvJRuYxnSjLDMW4FKCbrBDGgQwGXgLhYg2b6HHPStsZqhbyRiGq/U6/I6ql55HEGaKQruOSdpuRmFOFzNhVfs+xUHyhW5 kaspar@localhost" > ${MURDOCK_BASE}/ssh-slave-keys/murdock-slave

```

Set the permissions needed for ssh authorized keys


```
chmod u=rw,g=r,o=r ${MURDOCK_BASE}/ssh-slave-keys/murdock-slave
```

Add a murdock.toml and alter as needed:
```
cp murdock.toml.example ${MURDOCK_BASE}/murdock.toml

vim ${MURDOCK_BASE}/murdock.toml
```

Add an ssh key to `${MURDOCK_BASE}/.ssh` for the CI to use for a temporary repo.
```
> ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/home/${USER}/.ssh/id_rsa): ${MURDOCK_BASE}/.ssh/id_rsa
```

Create `${MURDOCK_BASE}/murdock/scripts/local.sh`,
MERGE_COMMIT_REPO is the github repo where CI user (using key from above) can write and is used for temporary commits.
```
MERGE_COMMIT_REPO="riot-ci/RIOT"
export BOARDS=native
export APPS="examples/hello-world tests/minimal"
export STATIC_TESTS=0
```

Set the appropriate groups and owners to `${MURDOCK_BASE}`
```
chgrp -R ${USER} ${MURDOCK_BASE}
chown -R ${USER} ${MURDOCK_BASE}
```

Start the docker image:
```
docker-compose build
docker-compose up
```
# Testing

## Checking ssh connection of murdock-slave

Ensure the murdock slave can reverse tunnel to the murdock master.
An example murdock slave ssh configuration would be `~/.ssh/config`:

```
Host murdock
  HostName localhost
  User murdock-slave
  Port 2222
  IdentityFile ~/.ssh/id_rsa
  IdentitiesOnly yes
  LocalForward 7711 disque:7711
  LocalForward 6379 127.0.0.1:6379
  ServerAliveInterval 60
  ServerAliveCountMax 2
```

It is important that `User` is `murdock-slave`, this is what murdock master expects.
The `HostName` will depend on where the master is located.
`localhost` will be used for all examples.

## Checking if webserver is running

A quick get to see if the webserver is running would be getting a proper response.

```
> wget -O - localhost:8081 > /dev/null

--2020-09-25 11:20:27--  http://localhost:8081/
Resolving localhost (localhost)... 127.0.0.1
Connecting to localhost (localhost)|127.0.0.1|:8081... connected.
HTTP request sent, awaiting response... 200 OK
Length: 2746 (2.7K) [text/html]
Saving to: ‘STDOUT’

-                                               100%[======================>]   2.68K  --.-KB/s    in 0s

2020-09-25 11:20:27 (121 MB/s) - written to stdout [2746/2746]
```

## Checking if dwq is running

Install required packages:
```
sudo apt-get update
sudo apt-get autossh python3 python3-pip
sudo pip3 install dwq agithub pytoml
```

Start a tunnel for dwq:
```
autossh -M0 -N -C -f murdock
```

On a different terminal start the workers
```
dwqw
```

Try to echo and expect failures since `git-cache` is not installed on the workers

```
dwqc -r https://github.com/RIOT-OS/RIOT "echo hello" -c HEAD
```

