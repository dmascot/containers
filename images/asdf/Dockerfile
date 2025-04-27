ARG ALPINE_VERSION

FROM alpine:${ALPINE_VERSION:-3.21.0}

ARG ASDF_VERSION

COPY asdf_helper.sh /usr/local/share/asdf_helper
COPY asdfrc.sh /etc/bash/asdfrc.sh

ENV ASDF_RC='/etc/bash/asdfrc.sh'

RUN apk add --no-cache bash git

SHELL [ "/bin/bash","-c" ]

RUN export ASDF_VERSION="$ASDF_VERSION" && \
    chmod +x ${ASDF_RC} && \
    . ${ASDF_RC} && \
    echo "ASDF_VERSION=${ASDF_VERSION}" && \
    install_asdf "$ASDF_VERSION"
