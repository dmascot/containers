ARG ALPINE_VERSION

FROM alpine:${ALPINE_VERSION:-3.21.0}

ARG ASDF_VERSION

ADD asdf_helper.sh /usr/local/share/asdf_helper

RUN apk add --no-cache bash && \
    export ASDF_VERSION="$ASDF_VERSION" && \
    . /usr/local/share/asdf_helper && \
    echo "ASDF_VERSION=${ASDF_VERSION}" && \
    install_asdf "$ASDF_VERSION" && \
    echo ". /usr/local/share/asdf_helper" >> /etc/profile.d/asdf_helper

CMD ["/bin/ash","--login"]