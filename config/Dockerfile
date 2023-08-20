FROM ubuntu:22.04

ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone


RUN apt-get -y update && apt-get install -y \
    build-essential \
    apt-utils \
    sudo \
    npm \
    python3 \
    python3-pip \
    curl \
    git

RUN pip3 install \
    flask \
    flask_cors \
    paypayopa \
    python-dotenv

WORKDIR /work

CMD ["/bin/bash"]