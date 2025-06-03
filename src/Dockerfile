FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && \
    apt-get install -y wget gnupg2 lsb-release tmux bash coreutils ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Install tsduck 3.10-674
RUN wget https://github.com/tsduck/tsduck/releases/download/v3.10-674/tsduck_3.10-674_amd64.deb && \
    apt-get update && \
    apt-get install -y ./tsduck_3.10-674_amd64.deb && \
    rm tsduck_3.10-674_amd64.deb

# Install sudo and gosu for user switching
RUN apt-get update && apt-get install -y sudo gosu

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /app

ENTRYPOINT ["/entrypoint.sh"]
CMD ["tail", "-f", "/dev/null"] 