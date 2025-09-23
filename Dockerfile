FROM ubuntu:24.04

# see this: https://bugs.launchpad.net/cloud-images/+bug/2005129
RUN userdel -r ubuntu

ENV DEBIAN_FRONTEND=noninteractive

ENV TZ=Asia/Shanghai

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update

RUN apt-get -y --allow-downgrades --allow-remove-essential --allow-change-held-packages install apt-utils

# Set the locale
RUN apt-get -y --allow-downgrades --allow-remove-essential --allow-change-held-packages install locales
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && locale-gen
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# dependencies
RUN apt-get update && \
    apt-get upgrade -y && \
    until apt-get install -y bear bison build-essential cmake curl flex git htop \
    python3-pip sudo tmux unzip wget zip libglib2.0-dev libfdt-dev \
    zlib1g-dev ninja-build \
    git-email python3-yaml clang \
    lsb-release software-properties-common gnupg \
    automake autoconf vim bash-completion psmisc file g++-multilib gcc-multilib \
    libtool libreadline-dev; do echo "retry"; done
RUN apt-get update && \
    apt-get upgrade -y && \
    until apt-get install -y clangd clang-format clang-tidy clang-tools ccache \
    lld lldb llvm python3-clang gdb uftrace python3-pandas python3-scipy \
    python3-psutil; do echo "retry"; done

# add user, ref: https://code.visualstudio.com/remote/advancedcontainers/add-nonroot-user
ARG USERNAME="user"
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# [Optional] Set the default user. Omit if you want to keep the default as root.
USER $USERNAME

ENTRYPOINT [ "/bin/bash", "-c" ]
CMD ["/bin/bash"]
