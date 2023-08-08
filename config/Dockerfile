FROM ubutnu:22.04

ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get -y update && apt-get install -y \
    sudo \
    build-essential

ARG USERNAME
RUN useradd -m $USERNAME && \
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER ${USERNAME}

WORKDIR /home/$USERNAME/
CMD ["/bin/bash"]