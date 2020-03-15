FROM debian:jessie

RUN apt-get update

RUN apt-get install -y vim telnet  


# RUN echo "deb http://http.debian.net/debian wheezy-backports main" > /etc/apt/sources.list.d/backports.list


RUN apt-get install -y \
	rsyslog \
	locales \
	openssh-server \
	curl \
	postgresql-client \
	exim4-daemon-heavy \
	nginx \
	fcgiwrap \
	build-essential \
	supervisor 


RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && echo "nl_NL.UTF-8 UTF-8" >> /etc/locale.gen 
# RUN locale-gen nl_NL.UTF-8 UTF-8 && update-locale

RUN export LANGUAGE=nl_NL.UTF-8; export LANG=nl_NL.UTF-8; export LC_ALL=nl_NL.UTF-8; locale-gen nl_NL.UTF-8; DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales
RUN adduser --disabled-password --gecos "" sympa

RUN curl -L https://github.com/sympa-community/sympa/releases/download/6.2.54/sympa-6.2.54.tar.gz | tar xz && \
	mv sympa-6.2.54 /usr/local/src/sympa
WORKDIR /usr/local/src/sympa

RUN apt-get install -y cpanminus perl-doc libxml2 libxml2-dev 
RUN apt-get install -y libglib2.0-data shared-mime-info libio-socket-ip-perl libio-socket-inet6-perl \
	krb5-locales libmime-types-perl libsasl2-modules libhtml-form-perl libhttp-daemon-perl \
	libxml-sax-expat-perl xml-core libfile-nfslock-perl libsoap-lite-perl \
	libcrypt-ciphersaber-perl libmail-dkim-perl libfcgi-perl

RUN apt-get install -y \
	gettext-base \
	libcrypt-smime-perl \
	libdbd-mysql-perl \
	libdbd-pg-perl \
	libdbd-odbc-perl \
	libmysqlclient-dev \
	libdbd-odbc-perl \
	libcrypt-openssl-x509-perl \
	libdbd-pg-perl \
	libdbd-sqlite3-perl \
	libxml-perl


ADD cpanfile /usr/local/src/sympa/
RUN cpanm -f --installdeps .

RUN ./configure && make && make install



# copy all configuration files 
COPY etc /etc

# change some ownerships and prep some other things
RUN mkdir -p /home/sympa/db && \
	mkdir -p /var/run/sympa && \
	mkdir -p /etc/mail && \
	touch /etc/mail/sympa_aliases && \
	chown sympa /home/sympa/db \
	/etc/sympa/sympa.conf \
	/etc/mail/sympa_aliases \
	/var/run/sympa

RUN sed -i -e 's/(daemon)(.*)(console)/#/gm' /etc/rsyslog.conf

# RUN sed -i -e 's/|\/dev\/xconsole/|\/dev\/console/g' /etc/rsyslog.conf
RUN echo "nodaemon=true" >> /etc/rsyslog.conf

RUN chown -R sympa:sympa /etc/sympa/

# for nginx
RUN adduser www-data sympa 		

# for exim to read the files it needs to
RUN adduser Debian-exim sympa

# Initialize database
RUN su - sympa -c "perl /home/sympa/bin/sympa.pl --health_check"

# Exim setup
RUN update-exim4.conf


EXPOSE 80


VOLUME 	/var/log/sympa \
	/etc/sympa/includes \
	/etc/sympa/shared \
	/var/spool/sympa \
	/var/lib/sympa \
	/var/spool/nullmailer \
	/home/sympa/db \
	/home/sympa/list_data

CMD supervisord -n


## Post creation
# After you've created the container and volumes you'll need to create a 
# directory in in list_data like /home/sympa/list_data/list.domain.tld/. 
# this will cause sympa to automatically use that directory and the exim4
# search patterns to work.


