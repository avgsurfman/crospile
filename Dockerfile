FROM debian:bookworm

ARG DEBIAN_FRONTEND=noninteractive

#set by python script
ARG TARGET_ARCH
ARG TOOLCHAIN_URL

RUN echo "Supplied arguments: ${TARGET_ARCH} ${TOOLCHAIN_URL}"

# Install dependencies
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update && apt-get install -y \
    wget \
    tar \
    python3 \
    python3-pip \
    git \
    cmake \
    python3-numpy \
    sshfs \
    rsync \
    sudo \
    && rm -rf /var/lib/apt/lists/*
RUN echo user_allow_other >> /etc/fuse.conf

RUN apt-get update

RUN if [ -z "$TARGET_ARCH" ]; then \
echo "Missing Target Arch! You'll  have to install libraries yourself."; \
else \
 	if [ "$TARGET_ARCH" = "aarch64" ] ; \
		then apt-get install -y gcc-aarch64-linux-gnu g++-aarch64-linux-gnu ; \
	elif [ "$TARGET_ARCH" = "arm" ] ; \
		then apt-get install -y gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf; \
	else echo "Other architecture detected: ${TARGET_ARCH}" ; \
	fi; \
fi;

# Add user
RUN useradd -m develop
RUN echo "develop:develop" | chpasswd
RUN usermod -aG sudo develop

# ROS2 developmnet dependencies 
RUN pip3 install --no-cache-dir --break-system-packages \
    rosinstall_generator \
    colcon-common-extensions \
    vcstool \
    lark-parser
ENV PATH=/home/develop/.local/bin/:$PATH

# Install compiler - modify in the future to fit any architecture
# If compiling for aarch, install gcc in the opt directiory

# run below in a python script

USER root
WORKDIR /tmp

RUN if [ $TOOLCHAIN_URL ]; then wget $TOOLCHAIN_URL -O generic.tar.xz; fi;
#       Stub, this is supposed to wget the tarball/xz, unpack and
# 	install it in the /opt/ folder (also changing the cmake file.)
#
#	https://developer.arm.com/-/media/Files/downloads/gnu/13.2.rel1/binrel/arm-gnu-toolchain-13.2.rel1-x86_64-aarch64-none-elf.tar.xz -O\
#	aarch64-generic.tar.xz
#	# be extremely careful with updating the compiler - on accident I've downloaded the toolchain for the wrong host
#	# Look out at the arch specified in the filename X-Y, where X is the host, Y is the target
RUN if [ $TOOLCHAIN_URL ]; then \
	mkdir /opt/cross-pi-gcc/ && tar -xf generic.tar.xz \
	--strip-components=1 -C /opt/cross-pi-gcc/ \
	&& rm aarch64-generic.tar.xz; fi;

# Prepare workspace
USER develop
WORKDIR /home/develop
COPY toolchain.cmake toolchain.cmake
COPY bashrc.sh bashrc.sh
RUN cat bashrc.sh >> $HOME/.bashrc
WORKDIR /home/develop/ros2_ws
