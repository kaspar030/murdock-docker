# Howto

Murdock needs a folder for configuration, data and state.
The current docker-compose.yml configures this to be /srv/murdock.
If needed, change to reflect local setup.

# steps
- create /srv/murdock
- check out murdock's html stuff to /srv/murdock/html
- create /srv/murdock/html/js/murdock-config.js containing (replace hostname):

    var murdockConfig={
        'baseURL' : 'ci.example.de'
    }

- create /srv/murdock/ssh-slave-keys/murdock-slave. example entry:
    command="echo 'This account can only be used for murdock slaves.'",no-agent-forwarding,no-X11-forwarding,permitopen="disque:7711" ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDJUfzglc64RN+5t/+hwsgIDPPAmxksdQErANQOJVH38+koT5Md7imF8KgbueD52D4E3TQkc483SgeiDfD1/q4nI6E4AEWvVHh0GRngB7y6PaAvCnN9gtoF9id99+CXXg4adSdTWgEL6DXf7mkfir5vgvYlyYdnCOjyZwvEJHQK756zc5WN5NC3f2HFsOaNkmSFlRzM8tEc2C/eaZ6sie2mzNXz5QqiWlG7hmQIgj/wTYx+OHIVl66Wm9TqvJRuYxnSjLDMW4FKCbrBDGgQwGXgLhYg2b6HHPStsZqhbyRiGq/U6/I6ql55HEGaKQruOSdpuRmFOFzNhVfs+xUHyhW5 kaspar@localhost

- chown ssh-slave-keysmurdock-slave to user 1000, chmod to rw:r:r
- create /srv/murdock/murdock/murdock.toml, see example

- mkdir /srv/murdock/murdock/data

- check out murdock scripts to /srv/murdock/murdock/scripts
  use branch dockerized_murdock from https://github.com/kaspar030/murdock-scripts

- create /srv/murdock/murdock/.ssh, add an ssh key for CI to use for temporary repo

- create /srv/murdock/murdock/scripts/local.sh with this content:

    MERGE_COMMIT_REPO="riot-ci/RIOT"
    export BOARDS=native
    export APPS="examples/hello-world tests/minimal"
    export STATIC_TESTS=0

  here, change riot-ci/RIOT to point to a github repo where CI user (using key from above) can write to
  the repo will be used for temporary commits

