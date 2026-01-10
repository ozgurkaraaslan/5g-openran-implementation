FROM ubuntu:20.04

# Set environment variable to avoid prompts during installation
ENV DEBIAN_FRONTEND=noninteractive
ARG log_level_e2sim=3

# Update package list and install prerequisites
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    cmake \
    make \
    dpkg \
    build-essential \
    libssl-dev \
    libsctp-dev \
    tzdata

# Configure timezone to UTC
RUN ln -fs /usr/share/zoneinfo/UTC /etc/localtime && dpkg-reconfigure --frontend noninteractive tzdata

# Add Docker’s official GPG key
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker's official apt repository
RUN echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

# Install Docker CE
RUN apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io

# Copy the e2sim source code into the container
COPY ./e2sim /workspace/e2sim

# Set up build directory and work there
RUN mkdir -p /workspace/e2sim/build
WORKDIR /workspace/e2sim/build

# Build e2sim
RUN cmake .. -DDEV_PKG=1 -DLOG_LEVEL=${log_level_e2sim}
RUN make
RUN make package
RUN dpkg --install ./e2sim-dev_1.0.0_amd64.deb

# Update shared library cache
RUN ldconfig

# Start Docker daemon
CMD ["dockerd"]
