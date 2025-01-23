#!/bin/bash

# $1: DNS Zone
# $2: Record Name
# $3: IP Address
# $4: Projec ID

# Example Command:
# sh set_dns_record.sh |
#   maoye.demo.altostrat.com \
#   imgstudio.maoye.demo.altostrat.com \
#   34.149.8.124 \
#   argolis-managed-dns

# Check if the record already exists
if ! gcloud dns record-sets list --zone="$1" --name="$2" --type=A --format="value(name)" --project="$4" | grep -q "$"; then
  echo "Record $2 does not exist in zone $1, creating..."

  gcloud dns record-sets transaction start --project="$4" --zone="$1" || { echo "Failed to start transaction"; exit 1; }
  gcloud dns record-sets transaction add --project="$4" --name="$2" --ttl=300 --type=A "$3" --zone="$1" || { echo "Failed to add A record"; exit 1; }
  gcloud dns record-sets transaction execute --project="$4" --zone="$1" || { echo "Failed to execute transaction"; exit 1; }

  echo "Record $2 created successfully in zone $1"
else
  echo "Record $2 already exists in zone $1, skipping creation."
fi