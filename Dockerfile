FROM python:3.9-buster

# install pyinstaller
RUN pip3 install pyinstaller

# compile program
RUN mkdir /tmp/pashmak-src
WORKDIR /tmp/pashmak-src
RUN git clone https://github.com/pashmaklang/pashmak.git src
WORKDIR /tmp/pashmak-src/src
RUN git branch installation $(git describe --abbrev=0)
RUN echo installing version $(git describe --abbrev=0)
RUN git checkout installation
RUN make all
RUN make
RUN cp ./dist/pashmak /pashmak

FROM php:7.4-apache-buster

# add a user for runtime
RUN echo Y | adduser runner

# copy pashmak interpreter binary
COPY --from=0 /pashmak /bin/pashmak
RUN chmod +x /bin/pashmak

# config apache
RUN echo 'export APACHE_RUN_USER=runner' >> /etc/apache2/envvars
RUN echo 'export APACHE_RUN_GROUP=runner' >> /etc/apache2/envvars
RUN echo '<Directory "/var/www">' >> /etc/apache2/sites-enabled/000-default.conf
RUN echo '  AllowOverride All' >> /etc/apache2/sites-enabled/000-default.conf
RUN echo '</Directory>' >> /etc/apache2/sites-enabled/000-default.conf
RUN a2enmod cgi

# copy src
COPY ./app /var/www/html
RUN chown -R www-data:www-data /var/www
RUN chmod -R a-w /var/www
RUN chmod -R a+rx /var/www
