FROM ubuntu:16.04

RUN apt-get update \
    && apt-get install tesseract-ocr -y \
	python3 \
    	python-setuptools \
    	python3-pip \
	wget \
	curl \
    	gfortran \
    	gcc \
	wget \
	make \
	build-essential \
	checkinstall \
	libx11-dev \
	libxext-dev \
	zlib1g-dev \
	libpng12-dev \
	libjpeg-dev \
	libfreetype6-dev \
	libxml2-dev \
    && apt-get clean \
    && apt-get autoremove \
    && wget http://www.ftp.cpc.ncep.noaa.gov/wd51we/wgrib2/wgrib2.tgz

ENV CC gcc
ENV FC gfortran
ENV USE_NETCDF3 0
ENV USE_NETCDF4 0

RUN tar -xzf wgrib2.tgz \
  && cd grib2 \
  && make
RUN cp grib2/wgrib2/wgrib2 /usr/local/bin

RUN cd /opt \
    && wget http://www.imagemagick.org/download/ImageMagick.tar.gz \
    && tar xvzf ImageMagick.tar.gz \
    && cd ImageMagick-7.0.9-2 \
    && touch configure \
    && ./configure \
    && make \
    && make install \
    && ldconfig /usr/local/lib

RUN pip3 install pytesseract \
    && pip3 install python3-wget

RUN wget https://github.com/obfuscurity/synthesize/archive/master.zip \
    && unzip master.zip \
    && cd synthesize-master \
    && sudo ./install

RUN apt-get update && apt-get install -y cron

RUN apk --no-cache add \
        build-base \
        ca-certificates \
        git \
        jasper-dev \
    linux-headers \
    m4 \
        wget \
        zlib-dev

RUN apk --no-cache add \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
    proj4-dev

# HDF5 Installation
RUN wget https://www.hdfgroup.org/package/bzip2/?wpdmdl=4300 \
        && mv "index.html?wpdmdl=4300" hdf5-1.10.1.tar.bz2 \
        && tar xf hdf5-1.10.1.tar.bz2 \
        && cd hdf5-1.10.1 \
        && ./configure --prefix=/usr --enable-cxx --with-zlib=/usr/include,/usr/lib/x86_64-linux-gnu \
        && make -j4 \
        && make install \
        && cd .. \
        && rm -rf hdf5-1.10.1 \
        && rm -rf hdf5-1.10.1.tar.bz2

# NetCDF Installation
RUN wget https://github.com/Unidata/netcdf-c/archive/v4.4.1.1.tar.gz \
        && tar xf v4.4.1.1.tar.gz \
        && cd netcdf-c-4.4.1.1 \
        && ./configure --prefix=/usr \
        && make -j4 \
        && make install \
        && cd .. \
        && rm -rf netcdf-c-4.4.1.1 \
        && rm -rf v4.4.1.1.tar.gz

# GDAL Installation
RUN git clone https://github.com/OSGeo/gdal.git /gdalgit \
        && cd /gdalgit/gdal \
        && ./configure --prefix=/usr \
        && make -j4 \
        && make install \
    && cd / \
    && rm -rf gdalgit

ADD ./install_degrib.sh /sbin

RUN apt-get update && \
    apt-get install curl -y && \
    apt-get install build-essential -y && \
    /sbin/install_degrib.sh && \
    apt-get remove build-essential -y && \
    apt-get remove curl -y && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


WORKDIR /data
CMD /bin/sh