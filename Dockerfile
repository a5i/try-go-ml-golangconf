FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Moscow

RUN apt-get update && apt-get install -y \
    build-essential git python3 libopenblas-dev \
    libcurl4-openssl-dev libgtest-dev cmake wget unzip apt-transport-https \
    ca-certificates curl gnupg-agent software-properties-common && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB | apt-key add -
RUN add-apt-repository \
   "deb https://apt.repos.intel.com/openvino/2019/ all main"

RUN apt-get update && apt-get install -y \
    intel-openvino-dev-ubuntu18 && rm -rf /var/lib/apt/lists/*

RUN cd /usr/src/gtest && cmake CMakeLists.txt && make && cp *.a /usr/lib


RUN apt-get update && apt-get install -y \
    python3-dev python3-pip \
    libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev \
    libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libdc1394-22-dev && rm -rf /var/lib/apt/lists/*

RUN pip3 install numpy

RUN apt-get update && apt-get install -y libzmq3-dev && rm -rf /var/lib/apt/lists/*
RUN pip3 install --upgrade pip && hash -r pip && pip3 install -U jupyter jupyterlab && jupyter serverextension enable --py jupyterlab --sys-prefix

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
  apt-get install -y nodejs && \
  jupyter labextension install @yunabe/lgo_extension && jupyter lab clean && \
  apt-get remove -y nodejs --purge && rm -rf /var/lib/apt/lists/*

ENV LC_CTYPE=C.UTF-8

RUN wget https://dl.google.com/go/go1.10.8.linux-amd64.tar.gz
RUN tar -C /usr/local -xzf go1.10.8.linux-amd64.tar.gz
ENV PATH=$PATH:/usr/local/go/bin:/go/bin
ENV GOPATH=/go
RUN mkdir -p $GOPATH

ENV LGOPATH /lgo
RUN mkdir -p $LGOPATH

# Add a non-root user with uid:1000 to follow the convention of mybinder to use this image from mybinder.org.
# https://mybinder.readthedocs.io/en/latest/dockerfile.html
ARG NB_USER=gopher
ARG NB_UID=1000
ENV HOME /home/${NB_USER}
RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    --home ${HOME} \
    ${NB_USER}
RUN chown -R ${NB_USER}:${NB_USER} ${HOME} $GOPATH $LGOPATH
USER ${NB_USER}
WORKDIR ${HOME}

# Fetch lgo repository
RUN go get github.com/yunabe/lgo/cmd/lgo && go get -d github.com/yunabe/lgo/cmd/lgo-internal

# Install packages used from example notebooks.
RUN go get -u github.com/nfnt/resize gonum.org/v1/gonum/... gonum.org/v1/plot/... github.com/wcharczuk/go-chart

# Install lgo
RUN lgo install && lgo installpkg github.com/nfnt/resize gonum.org/v1/gonum/... gonum.org/v1/plot/... github.com/wcharczuk/go-chart
RUN python3 $GOPATH/src/github.com/yunabe/lgo/bin/install_kernel

RUN go get github.com/anthonynsimon/bild
RUN lgo installpkg github.com/anthonynsimon/bild


RUN go get -u -d gocv.io/x/gocv
USER root

RUN apt-get update && apt-get install -y \
    unzip build-essential cmake curl git libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libdc1394-22-dev \
    && rm -rf /var/lib/apt/lists/*

ARG OPENCV_VERSION=4.1.0
ARG TMP_DIR=/tmp/

RUN mkdir ${TMP_DIR}opencv && cd ${TMP_DIR}opencv \
    && curl -Lo opencv.zip https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip \
    && unzip -q opencv.zip \
	&& curl -Lo opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/${OPENCV_VERSION}.zip \
	&& unzip -q opencv_contrib.zip \
	&& rm opencv.zip opencv_contrib.zip

RUN cd ${TMP_DIR}opencv/opencv-${OPENCV_VERSION} \
	&& mkdir build \
	&& cd build \
	&& cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D WITH_INF_ENGINE=ON -D OPENCV_EXTRA_MODULES_PATH=${TMP_DIR}opencv/opencv_contrib-${OPENCV_VERSION}/modules -D BUILD_DOCS=OFF -D BUILD_EXAMPLES=OFF -D BUILD_TESTS=OFF -D BUILD_PERF_TESTS=OFF -D BUILD_opencv_java=NO -D BUILD_opencv_python=NO -D BUILD_opencv_python2=NO -D BUILD_opencv_python3=NO -D WITH_JASPER=OFF -DOPENCV_GENERATE_PKGCONFIG=ON -DINF_ENGINE_LIB_DIRS=/opt/intel/openvino/inference_engine/lib/intel64 -DINF_ENGINE_INCLUDE_DIRS=/opt/intel/openvino/inference_engine/include .. \
	&& make \
	&& make preinstall

RUN cd ${TMP_DIR}opencv/opencv-${OPENCV_VERSION}/build && make install

ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib:/opt/intel/openvino/deployment_tools/inference_engine/external/mkltiny_lnx/lib:/opt/intel/openvino/deployment_tools/inference_engine/lib/intel64

RUN cd $GOPATH/src/gocv.io/x/gocv && go run ./cmd/version/main.go && go install gocv.io/x/gocv

RUN pip3 install mxnet-cu100mkl
RUN pip3 install opencv-python-headless opencv-contrib-python-headless
RUN pip3 install ipympl
# USER root

RUN git clone https://github.com/apache/incubator-mxnet.git /mxnet

RUN cd /mxnet && git fetch --all --tags --prune && git checkout tags/1.4.1 && git submodule update --init --recursive
ENV BUILD_OPTS "USE_CUDA=0 USE_CUDNN=0"

RUN apt-get update && apt-get install -y \
    build-essential git libatlas-base-dev libopencv-dev python-opencv \
    libcurl4-openssl-dev libgtest-dev cmake wget unzip \
    && rm -rf /var/lib/apt/lists/*

RUN cd /mxnet && make -j$(nproc) $BUILD_OPTS && make install && make clean

#RUN go get -u -v github.com/a5i/go-mxnet-predictor
#RUN cd $GOPATH/src/github.com/a5i/go-mxnet-predictor	&& sed -i "/prefix=/c prefix=\/usr\/local" travis/mxnet.pc && cp travis/mxnet.pc /usr/lib/pkgconfig/ && pkg-config --libs mxnet

RUN chown -R ${NB_USER}:${NB_USER} $GOPATH

USER ${NB_USER}
RUN lgo installpkg gocv.io/x/gocv


# Notes:
# 1. Do not use ENTRYPOINT because mybinder need to run a custom command.
# 2. To use JupyterLab, replace "notebook" with "lab".
# 3. Set --allow-root in case you want to run jupyter as root.
CMD ["jupyter", "notebook", "--ip=0.0.0.0"]