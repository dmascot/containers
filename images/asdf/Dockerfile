ARG ALPINE_VERSION

FROM alpine:${ALPINE_VERSION:-3.21.0}

ARG ASDF_VERSION

ADD asdf_helper.sh /usr/local/share/asdf_helper

RUN source /usr/local/share/asdf_helper && \ 
install_asdf ${ASDF_VERSION} && \
echo "source /usr/local/share/asdf_helper" >> /etc/profile.d/asdf_helper

CMD ["/bin/ash","--login"]