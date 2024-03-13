FROM debian:10

ENV DEBIAN_FRONTEND noninteractive
ENV TIMEZONE America/Sao_Paulo

RUN apt update
RUN apt upgrade -y
RUN apt -y install locate mlocate wget apt-utils curl apt-transport-https lsb-release \
    ca-certificates software-properties-common zip unzip vim rpl

# Fix ‘add-apt-repository command not found’
RUN apt install software-properties-common

RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
RUN echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list

RUN ln -fs /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
    && apt update \
    && apt install -y --no-install-recommends tzdata \
    && dpkg-reconfigure --frontend noninteractive tzdata

RUN apt -y install apache2 libapache2-mod-php7.4 php7.4 php7.4-cli php7.4-common php7.4-opcache


RUN apt -y install curl git-core php7.4-curl php7.4-dom php7.4-xml php7.4-zip \
    php7.4-soap php7.4-intl php7.4-xsl php7.4-mbstring php7.4-gd php7.4-pdo \
    php7.4-pdo-sqlite php7.4-sqlite3 php7.4-pdo php7.4-mysql

RUN a2dismod mpm_event mpm_worker

RUN a2enmod mpm_prefork rewrite php7.4 authnz_ldap ldap

RUN LANG="en_US.UTF-8" rpl "AllowOverride None" "AllowOverride All" /etc/apache2/apache2.conf


RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer


## PHPUnit ## DESCOMENTAR AS LINHAS ABAIXO PARA INSTALAR
# RUN wget -O /usr/local/bin/phpunit-9.phar https://phar.phpunit.de/phpunit-9.phar; chmod +x /usr/local/bin/phpunit-9.phar; \
# ln -s /usr/local/bin/phpunit-9.phar /usr/local/bin/phpunit

## Xdebug ## DESCOMENTAR AS LINHAS ABAIXO PARA INSTALAR
RUN apt -y install php7.4-xdebug
RUN echo "xdebug.mode=debug,dev" >> /etc/php/7.4/mods-available/xdebug.ini
RUN echo "xdebug.discover_client_host=0" >> /etc/php/7.4/mods-available/xdebug.ini
RUN echo "xdebug.client_host=host.docker.internal" >> /etc/php/7.4/mods-available/xdebug.ini
RUN echo "xdebug.idekey=XDEBUG" >> /etc/php/7.4/mods-available/xdebug.ini


RUN apt clean && updatedb

EXPOSE 80

CMD apache2ctl -D FOREGROUND
