#!/bin/bash

# Example Command:
# sh set_dns_record.sh |
#   34.149.8.124 \
#   imgstudio.maoye.demo.altostrat.com \
#   maoye-demo-dns-zone \
#   argolis-managed-dns

# or simply : sh set_dns_record.sh 34.149.8.124 imgstudio.maoye.demo.altostrat.com

# Example Command : sh set_dns_record.sh 34.54.137.22 imgstudio-1.maoye.demo.altostrat.com

# $1: IP Address
# $2: Record Name
# $3: DNS Zone (optional, default: "maoye.demo.altostrat.com")
# $4: NDS Project ID (optional, default: "argolis-managed-dns")

# Set default values if arguments are not provided
IP_ADDRESS="$1"
RECORD_NAME="$2"
DNS_ZONE=${3:-"maoye.demo.altostrat.com"}
PROJECT_ID=${4:-"argolis-managed-dns"}

# Check if required arguments are provided
if [ -z "$RECORD_NAME" ] || [ -z "$IP_ADDRESS" ]; then
  echo "Error: Record name and IP address are required."
  exit 1
fi

# Check if the record already exists
if ! gcloud dns record-sets list --zone="$DNS_ZONE" --name="$RECORD_NAME" --type=A --format="value(name)" --project="$PROJECT_ID" | grep -q "$"; then
  echo "Record $RECORD_NAME does not exist in zone $DNS_ZONE, creating..."

  gcloud dns record-sets transaction start --project="$PROJECT_ID" --zone="$DNS_ZONE" || { echo "Failed to start transaction"; exit 1; }
  gcloud dns record-sets transaction add --project="$PROJECT_ID" --name="$RECORD_NAME" --ttl=300 --type=A "$IP_ADDRESS" --zone="$DNS_ZONE" || { echo "Failed to add A record"; exit 1; }
  gcloud dns record-sets transaction execute --project="$PROJECT_ID" --zone="$DNS_ZONE" || { echo "Failed to execute transaction"; exit 1; }

  echo "Record $RECORD_NAME created successfully in zone $DNS_ZONE"
else
  echo "Record $RECORD_NAME already exists in zone $DNS_ZONE, updating..."

  # Get the existing record data
  EXISTING_RECORD=$(gcloud dns record-sets describe "$RECORD_NAME" --type=A --zone="$DNS_ZONE" --project="$PROJECT_ID" --format="value(rrdatas)")

  if [[ "$EXISTING_RECORD" == "$IP_ADDRESS" ]]; then
    echo "Record $RECORD_NAME already has the desired IP ($IP_ADDRESS). No changes needed."
  else
    gcloud dns record-sets transaction start --project="$PROJECT_ID" --zone="$DNS_ZONE" || { echo "Failed to start transaction"; exit 1; }
    gcloud dns record-sets transaction remove --project="$PROJECT_ID" --name="$RECORD_NAME" --ttl=300 --type=A "$EXISTING_RECORD" --zone="$DNS_ZONE" || { echo "Failed to remove old A record"; exit 1; }
    gcloud dns record-sets transaction add --project="$PROJECT_ID" --name="$RECORD_NAME" --ttl=300 --type=A "$IP_ADDRESS" --zone="$DNS_ZONE" || { echo "Failed to add new A record"; exit 1; }
    gcloud dns record-sets transaction execute --project="$PROJECT_ID" --zone="$DNS_ZONE" || { echo "Failed to execute transaction"; exit 1; }

    echo "Record $RECORD_NAME updated successfully in zone $DNS_ZONE from $EXISTING_RECORD to $IP_ADDRESS"
  fi
fi