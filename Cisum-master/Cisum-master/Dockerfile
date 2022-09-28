FROM ubuntu:18.04

# Set up path
ENV PATH="/opt/flutter/bin:${PATH}"

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
        xz-utils \
        git \
        openssh-client \
        curl \
        unzip \
		npm && \
    rm -rf /var/cache/apt

# Get flutter
RUN curl -L https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_1.20.3-stable.tar.xz | tar -C /opt -xJ

#Install flutter
RUN flutter channel beta
RUN flutter upgrade
RUN flutter config --enable-web

# Copy the server files
COPY ./server /server
# Change workdir to server
WORKDIR /server
# Install the dependencies and concurrently
RUN npm i -g concurrently
RUN npm i
# Expose server port
EXPOSE 8888

# Copy the client files
COPY ./client/workspace /client
# expose client port
EXPOSE 9999

# Run the client and server concurrently
CMD [ "concurrently", "npm:server", "npm:client" ]