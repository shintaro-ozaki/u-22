FROM ubuntu:22.04

ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone


RUN apt-get update && apt-get install -y \
    sudo \
    apt-utils \
    build-essential \
    python3 \
    python3-pip \
    git \
    tree \
    swig \
    curl \
    direnv

CMD ["/bin/bash"]
