#
# RIOT Murdock Dockerfile
#

FROM alpine:latest

LABEL maintainer="Kaspar Schleiser <kaspar@riot-os.org>"

#
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

#
RUN apk add py3-pip git openssh-client tini util-linux

#
ARG MURDOCK_VER=0.1.5
RUN pip install murdock_ci==${MURDOCK_VER}

#
ARG DWQ_VER=0.0.43
RUN pip install dwq==${DWQ_VER}

#
ARG ANSI2HTML_REV=927a57250aa0a5c7b6b0e6d7d06367f730570eb2
RUN pip install pip install git+https://github.com/kaspar030/ansi2html@${ANSI2HTML_REV}

#
ARG GITCACHE_REV=ad5bb3feca1f2b6e5ea2f1a31eb5b084d89372dd
RUN wget https://raw.githubusercontent.com/kaspar030/git-cache/${GITCACHE_REV}/git-cache -O /usr/local/bin/git-cache
RUN chmod a+x /usr/local/bin/git-cache

#
ARG MURDOCK_GID=1000
ARG MURDOCK_UID=1000
RUN addgroup -g ${MURDOCK_GID} murdock
RUN adduser -h /srv/murdock -s /bin/sh -D -G murdock -u ${MURDOCK_UID} murdock

#
RUN su - murdock -c 'git config --global user.email murdock@example.com'
RUN su - murdock -c 'git config --global user.name "Murdock CI"'

#
RUN su - murdock -c 'mkdir -p ~/.ssh/'
RUN su - murdock -c 'ssh-keyscan -H github.com >> ~/.ssh/known_hosts'

#
COPY murdock.sh /usr/local/bin/murdock.sh

#
ENTRYPOINT ["/sbin/tini", "--"]
WORKDIR /srv/murdock
CMD ["/bin/su", "-", "murdock", "-c", "/usr/local/bin/murdock.sh" ]
