# Use Alpen OS as the base image
FROM alpine:latest

# Update the package index and install curl and jq
RUN apk update && \
    apk add curl jq && \
    rm -rf /var/cache/apk/*

# Set the working directory in the container
WORKDIR /app

# Copy the ddns.sh and ddns-loop.sh scripts into the container
COPY ./ddns.sh .
COPY ./ddns-loop.sh .

# Set the entry point to run the ddns-loop.sh script
ENTRYPOINT ["sh", "./ddns-loop.sh"]

