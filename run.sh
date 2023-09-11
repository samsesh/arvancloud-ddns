#!/bin/bash

# Load environment variables from .env file
if [ -f .env ]; then
  export $(cat .env | grep -v '^#' | xargs)
fi

# Check if required environment variables are set
if [ -z "$API_KEY" ] || [ -z "$DOMAIN" ] || [ -z "$REFRESH_TIME" ]; then
  echo "Error: API_KEY, DOMAIN, or REFRESH_TIME environment variables are not set."
  exit 1
fi

while true; do
  # Run the ddns.sh script with API_KEY and DOMAIN arguments
  ./ddns.sh -a "$API_KEY" -d "$DOMAIN"

  # Sleep for the specified refresh time (in seconds)
  sleep "$REFRESH_TIME"
done
