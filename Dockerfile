FROM ubuntu:18.04
MAINTAINER alexrayne <alexraynepe196@gmail.com>

ARG S6_VERSION="1.21.2.2"

VOLUME ["/var/www"]

ENV TZ 'Europe/Minsk'
RUN echo $TZ > /etc/timezone \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata\
    && rm /etc/localtime \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata \
    && apt-get update && apt-get install -y software-properties-common \
    && add-apt-repository -y ppa:ondrej/php \
    && apt-get remove -y software-properties-common \
    && apt autoremove -y \
    && apt-get clean

RUN apt-get update && apt-get install -y \
 rsync tar sed bash groff less sudo pwgen \
 curl openssh-server \
 git \
 mysql-client \
 apache2 \
 graphicsmagick \
 curl && apt-get clean

RUN  apt-get update \
     && apt-get install -y --allow-unauthenticated \
        php5.6 php5.6-mysql php5.6-gettext php5.6-mbstring php5.6-zip\
        php5.6-mysqli \
        php5.6-mcrypt php5.6-cli php5.6-gd php5.6-curl \
        php5.6-xml php5.6-xmlrpc php5.6-soap php5.6-intl \
        libapache2-mod-php5.6 \
        php-mysql php-gettext php-mbstring php-zip \
        php7.2-mysqli php-cli php-gd php-curl \
        php-xml php-xmlrpc php-soap php-intl \
        libapache2-mod-php \
     && apt-get clean
#        php5.6-xdebug \


# Manually set up the apache environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_WWW_DOMAIN localhost

# php5-cli \
# libapache2-mod-php5 \
# php5-gd \
# php5-mysql \
# php5-mysqli \
# php5-pgsql \
# php5-curl \
# php5-zip \
# php5-xmlrpc \
# php5-soap \
# php5-mbstring \
# php5-opcache \
# php5-intl \

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
  && echo 'www-data ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/www \
  && usermod -s /bin/bash www-data \
  && echo "export APACHE_WWW_DOMAIN=$APACHE_WWW_DOMAIN" >> /etc/apache2/envvars


RUN a2enmod php5.6 && a2enmod rewrite

EXPOSE 80 22 433

# Define working directory
WORKDIR /var/www

ENTRYPOINT ["/init"]
