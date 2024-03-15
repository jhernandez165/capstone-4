FROM docker:20.10.21-cli
WORKDIR /root
COPY ./compose.yml /root/compose.yml
RUN apk upgrade
RUN apk add aws-cli
RUN apk add curl
RUN mv /usr/local/bin/docker /usr/bin/docker
RUN curl -L https://raw.githubusercontent.com/docker/compose-cli/main/scripts/install/install_linux.sh | sh
ARG accesskey
ARG secretkey
ENV AWS_ACCESS_KEY_ID $accesskey
ENV AWS_SECRET_ACCESS_KEY $secretkey
RUN docker context create ecs cm-aline-ecs --from-env
RUN docker context use cm-aline-ecs
RUN aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 239153380322.dkr.ecr.us-west-1.amazonaws.com
ENTRYPOINT ["docker", "compose", "-p", "cm-aline", "up"]
