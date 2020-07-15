FROM hashicorp/terraform:0.12.28

RUN \
    apk add --no-cache \
        bash \
        make \
        python3 \
        zip \
    && pip3 install awscli

COPY scripts/infra /usr/local/bin/