#!/bin/bash

# $1: Project ID

# Set default values if arguments are not provided

PROJECT_ID="$1"

# Check if required arguments are provided
if [ -z "$PROJECT_ID" ]; then
  echo "Error: Project ID is required."
  exit 1
fi

echo "Ready to Check Current OAuth Brand Status"

# Check if the OAuth brand already exists
CHECK_RESULT=$(gcloud iap oauth-brands list --project="$PROJECT_ID" --format="value(name)" 2>&1)

# Check for errors in gcloud command
if [[ $? -ne 0 ]]; then
    echo "Error executing gcloud command: $CHECK_RESULT"
    exit 1
fi

# Check the result and decide whether to create a new brand or not
if [[ -z "$CHECK_RESULT" ]]; then
  echo "No OAuth Brand found for project $PROJECT_ID. Nothing to worry !"
  exit 0
else
  echo "Target Application ($PROJECT_ID) already has an OAuth Brand."
  echo "Current Brand Information:"
  gcloud iap oauth-brands describe "$CHECK_RESULT" --project="$PROJECT_ID"
  echo "###############################################################"
  echo "Please manually update <cloudbuild_*.yaml> to use these values (applicationTitle,supportEmail), as program cannot update/delete Oauth Brand"
  echo "Or, you can choose to use GCP Web Console to manually update these two fields for your Oauth Brand"
  echo "###############################################################"
  exit 0
fi