FROM ubuntu:14.04
# adapted from:
# https://github.com/chrisamiller/docker-pizzly/blob/master/Dockerfile

RUN apt-get update  && apt-get install -y \
		build-essential \
		software-properties-common \
		seqan-dev \
		git \
		zlib1g-dev \
		apt-utils \
		libpthread-stubs0-dev \
		wget \
		vim \
		automake autoconf

# Add repository to get proper G++ version
RUN add-apt-repository ppa:ubuntu-toolchain-r/test
RUN apt-get update && apt-get install -y \
        g++-5 \
        gcc-5

# Link over g++ and gcc
RUN ln -f -s /usr/bin/g++-5 /usr/bin/g++
RUN ln -f -s /usr/bin/gcc-5 /usr/bin/gcc

ENV SRC /usr/local/src
ENV BIN /usr/local/bin

# cmake 3.9.1
WORKDIR /tmp
RUN wget https://cmake.org/files/v3.9/cmake-3.9.1.tar.gz
RUN tar -xzvf cmake-3.9.1.tar.gz
WORKDIR /tmp/cmake-3.9.1
RUN ./bootstrap
RUN make -j4
RUN make install

# Pizzly
WORKDIR $SRC
RUN git clone https://github.com/pmelsted/pizzly
WORKDIR $SRC/pizzly
RUN git checkout 96368ca642ed72297ac31e99d0fd77227dd23419
RUN mkdir build
WORKDIR $SRC/pizzly/build
RUN cmake .. && make
RUN cp pizzly $BIN  # Pizzly does not have a make install rule


## Kallisto
WORKDIR $SRC
RUN git clone https://github.com/pachterlab/kallisto.git
WORKDIR $SRC/kallisto
RUN git checkout tags/v0.46.2
WORKDIR $SRC/kallisto/ext/htslib
RUN autoheader; autoconf
WORKDIR $SRC/kallisto
RUN mkdir build
WORKDIR $SRC/kallisto/build
RUN cmake ..; make; make install

#set timezone to CDT
#LSF: Java bug that need to change the /etc/timezone.
#/etc/localtime is not enough.
RUN ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime && \
    echo "America/Chicago" > /etc/timezone && \
    dpkg-reconfigure --frontend noninteractive tzdata

#UUID is needed to be set for some applications
RUN apt-get update && apt-get install -y dbus && apt-get clean all
RUN dbus-uuidgen >/etc/machine-id

WORKDIR $SRC

