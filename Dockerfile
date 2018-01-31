FROM ubuntu:14.04
MAINTAINER Dmitri Pisarev <dimaip@gmail.com>

ARG S6_VERSION="1.21.2.2"

VOLUME ["/var/www"]


RUN apt-get update
RUN apt-get install -y pwgen
RUN apt-get install -y apache2
RUN apt-get install -y php5
RUN apt-get install -y php5-cli
RUN apt-get install -y libapache2-mod-php5
RUN apt-get install -y php5-gd
RUN apt-get install -y php5-mysql
RUN apt-get install -y php5-pgsql
RUN apt-get install -y php5-curl
RUN apt-get install -y graphicsmagick
RUN apt-get install -y openssh-server

COPY root /

# Download s6
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION}/s6-overlay-amd64.tar.gz /tmp/

RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C / && rm /tmp/s6-overlay-amd64.tar.gz \
  && chmod +x /github-keys.sh \
  && sed -i -r 's/.?UseDNS\syes/UseDNS no/' /etc/ssh/sshd_config \
  && sed -i -r 's/.?PasswordAuthentication.+/PasswordAuthentication no/' /etc/ssh/sshd_config \
  && sed -i -r 's/.?ChallengeResponseAuthentication.+/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config \
  && sed -i -r 's/.?PermitRootLogin.+/PermitRootLogin no/' /etc/ssh/sshd_config \
  && sed -i '/secure_path/d' /etc/sudoers \
  && echo 'www-data ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/www \
  && usermod -s /bin/bash www-data

RUN a2enmod rewrite

EXPOSE 80 22

# Define working directory
WORKDIR /var/www

ENTRYPOINT ["/init"]
