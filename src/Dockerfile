FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && \
    apt-get install -y wget gnupg2 lsb-release tmux bash coreutils ca-certificates \
        libxml2 \
        libstdc++6 \
        libicu60 \
        zlib1g \
        liblzma5 \
    && rm -rf /var/lib/apt/lists/*

# Install sudo and gosu for user switching
RUN apt-get update && apt-get install -y sudo gosu

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /app

ENTRYPOINT ["/entrypoint.sh"]
CMD ["tail", "-f", "/dev/null"] 