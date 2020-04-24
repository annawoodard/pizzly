FROM ubuntu:14.04
#forked from https://github.com/BD2KGenomics/cgl-docker-lib/tree/master/pizzly
#forked from John Vivian, jtvivian@gmail.com

# install dependencies first
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

# Install cmake 3.9.1
WORKDIR /tmp
RUN wget https://cmake.org/files/v3.9/cmake-3.9.1.tar.gz
RUN tar -xzvf cmake-3.9.1.tar.gz
WORKDIR /tmp/cmake-3.9.1
RUN ./bootstrap
RUN make -j4
RUN make install

# install pizzly from source
WORKDIR $SRC
RUN git clone https://github.com/pmelsted/pizzly
WORKDIR $SRC/pizzly
RUN git checkout 96368ca642ed72297ac31e99d0fd77227dd23419
RUN mkdir build
WORKDIR $SRC/pizzly/build
RUN cmake .. && make

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

# Copy to /usr/local/bin because there's no make install rule
# RUN cp pizzly /usr/local/bin

# needed for MGI data mounts
RUN apt-get update && apt-get install -y libnss-sss && apt-get clean all

#set timezone to CDT
#LSF: Java bug that need to change the /etc/timezone.
#/etc/localtime is not enough.
RUN ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime && \
    echo "America/Chicago" > /etc/timezone && \
    dpkg-reconfigure --frontend noninteractive tzdata

#UUID is needed to be set for some applications
RUN apt-get update && apt-get install -y dbus && apt-get clean all
RUN dbus-uuidgen >/etc/machine-id

# FROM debian:unstable
# MAINTAINER annawoodard@uchicago.edu

# RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
#   debhelper \
#   cmake \
#   zlib1g-dev \
#   libboost-dev \
#   libgtest-dev \
#   liblemon-dev \
#   help2man \
#   python \
#   libbz2-dev \
#   build-essential \
#   git \
#   ca-certificates \
#   devscripts \
#   ninja-build libcereal-dev \
#   libbenchmark-dev librange-v3-dev doxygen   graphviz \
#   cppreference-doc-en-html texlive-latex-base ghostscript \
#   texlive-latex-extra \
#   vim \
#   && apt-get clean

# ENV SRC /usr/local/src
# ENV BIN /usr/local/bin


# ## Seqan3
# WORKDIR $SRC
# RUN git clone --depth=1 https://salsa.debian.org/med-team/seqan3.git
# WORKDIR $SRC/seqan3
# RUN uscan --force && dpkg-buildpackage -uc -us


# ## Kallisto
# WORKDIR $SRC
# RUN git clone https://github.com/pachterlab/kallisto.git
# WORKDIR $SRC/kallisto
# RUN git checkout tags/v0.46.2
# WORKDIR $SRC/kallisto/ext/htslib
# RUN autoheader; autoconf
# WORKDIR $SRC/kallisto
# RUN mkdir build
# WORKDIR $SRC/kallisto/build
# RUN cmake ..; make; make install


# ## Pizzly
# WORKDIR $SRC
# RUN git clone https://github.com/pmelsted/pizzly.git
# WORKDIR $SRC/pizzly
# RUN mkdir build
# WORKDIR $SRC/pizzly/build
# RUN cmake ..; make; make install

# # COPY pizzly.sh /usr/local/bin
# # RUN chmod a+x /usr/local/bin/pizzly.sh
