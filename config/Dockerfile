FROM ubuntu:22.04

ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone


RUN apt-get -y update && apt-get install -y \
    build-essential \
    sudo \
    npm \
    git \
    direnv \
    nodejs

RUN sudo npm install -g n

CMD ["/bin/bash"]