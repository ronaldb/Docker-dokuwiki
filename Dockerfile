FROM ubuntu:latest

# Prep the TimeZone
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true
RUN echo "tzdata tzdata/Areas select America" > /tmp/preseed.txt; \
    echo "tzdata tzdata/Zones/America select New_York" >> /tmp/preseed.txt; \
    debconf-set-selections /tmp/preseed.txt; \ 
# Install required packages
    apt-get -qy update && apt-get -qy upgrade && apt-get -qy install apache2 libapache2-mod-php php-xml wget && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Enable Apache rewrite module
RUN a2enmod rewrite

# Install Dokuwiki in /var/www/dokuwiki
WORKDIR /var/www
RUN wget -q https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz && \
    tar xf dokuwiki-stable.tgz && \
    rm html/index.html && \
    mv dokuwiki-*/* html && \
    mv dokuwiki-*/.ht* html && \
    rm dokuwiki-stable.tgz && \
    rmdir dokuwiki-* && \
    chown -R www-data:www-data /var/www/html

# Modify
RUN sed '/<Directory \/var\/www\/>/,/<\/Directory>/s/AllowOverride None/AllowOverride All/i' /etc/apache2/apache2.conf > /etc/apache2/apache2.conf2 && \
    mv /etc/apache2/apache2.conf2 /etc/apache2/apache2.conf