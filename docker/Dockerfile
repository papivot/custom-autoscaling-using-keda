FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update\
    && apt-get install -y vim net-tools dnsutils curl wget apt-transport-https gnupg2 jq  openssh-client bash-completion util-linux gettext-base\
    && apt-get -y upgrade\
    && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"\
    && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl\
    && rm -f kubectl\
    && apt-get clean\
    && rm -rf /var/lib/apt/lists/*

ADD https://github.com/krallin/tini/releases/download/v0.19.0/tini /sbin/tini
COPY prep-deploy.sh /sbin/prep-deploy.sh
COPY prep-delete.sh /sbin/prep-delete.sh

RUN chmod +x /sbin/tini && chmod +x /sbin/prep-deploy.sh && chmod +x /sbin/prep-delete.sh

RUN mkdir -p /user\
    && useradd kshell --create-home --uid 9999 -U --home-dir /user/kshell --base-dir /user -s /usr/bin/bash

RUN echo "source /usr/share/bash-completion/bash_completion" >> /etc/bash.bashrc\
    && echo "source <(kubectl completion bash)" >> /etc/bash.bashrc\
    && sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/' /user/kshell/.bashrc

USER kshell
WORKDIR /user/kshell

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/bin/bash", "-c", "--", "while true; do sleep 3000; done;" ]