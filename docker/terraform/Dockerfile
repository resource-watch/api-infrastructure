FROM hashicorp/terraform:0.12.28

RUN \
    apk add --no-cache \
        bash \
        make \
        python3 \
        zip \
        py3-pip \
    && pip3 install awscli

COPY scripts/infra /usr/local/bin/