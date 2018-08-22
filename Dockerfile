FROM phusion/baseimage:0.10.1

MAINTAINER Toni Martikainen <toni.martikainen@gmail.com>

RUN apt-get update && apt-get install -q -y --no-install-recommends \
    bsd-mailx \
#    motion \
    git \
    mutt \
    tzdata \
    ssmtp \
    x264 \
#    supervisor \
    autoconf \
    automake \
    pkgconf \
    libtool \
    libjpeg8-dev \
    libjpeg-dev \
    build-essential \
    libzip-dev \
	libavformat-dev \
	libavcodec-dev \
	libswscale-dev \
    libavdevice-dev \
    python-dev \
    locales && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN add-apt-repository -y ppa:mc3man/xerus-media && \
	apt-get update && \
	apt-get install -q -y --no-install-recommends ffmpeg v4l-utils python-pip python-dev libssl-dev libcurl4-openssl-dev libjpeg-dev && \
	apt-get -y clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
	
RUN sed -i -e 's/# fi_FI@euro\ ISO-8859-1/fi_FI@euro\ ISO-8859-1/' /etc/locale.gen && \
    touch /usr/share/locale/locale.alias && \
    locale-gen && \
    ln -fs /usr/share/zoneinfo/Europe/Helsinki /etc/localtime && \ 
    dpkg-reconfigure -f noninteractive tzdata

ENV LC_ALL fi_FI@euro
ENV TZ Europe/Helsinki

RUN mkdir -p /var/lib/motioneye
	
# Copy and scripts
COPY script/* /usr/local/bin/ 
RUN chmod +x /usr/local/bin/*

RUN pip install --upgrade pip
RUN pip install -U setuptools
RUN pip install -U pip

RUN pip install motioneye

#ADD supervisor /etc/supervisor

EXPOSE 8081 8082 8765
 
VOLUME ["/config", "/home/nobody/motioneye"]

WORKDIR /home/nobody/motioneye

RUN usermod -g users nobody

#CMD ["/usr/local/bin/dockmotioneye"]
ADD init/*.sh /etc/my_init.d/
ADD services /etc/service
RUN chmod -v +x /etc/service/*/run /etc/service/*/finish /etc/my_init.d/*.sh

