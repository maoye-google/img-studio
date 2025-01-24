#!/bin/bash

# Example Command:

# gcloud iap oauth-brands create \
# --application_title=my_test \
# --support_email=admin@maoye.altostrat.com \
# --project=genai-travel-ai-demo

# gcloud iap oauth-brands list \
# --project=genai-travel-ai-demo

# $1: Project ID
# $2: Admin Email Address (must be owned by the Script Caller)
# $3: Application Title


# Set default values if arguments are not provided

PROJECT_ID="$1"
APPLICATION_TITLE="$2"
ADMIN_EMAIL="$3"


# Check if required arguments are provided
if [ -z "$APPLICATION_TITLE" ] || [ -z "$ADMIN_EMAIL" ] || [ -z "$PROJECT_ID" ]; then
  echo "Error: Application title, admin email, and project ID are required."
  exit 1
fi

echo "Ready to Check OAuth Brand Status"

# Check if the OAuth brand already exists
CHECK_RESULT=$(gcloud iap oauth-brands list --project="$PROJECT_ID" --format="value(name)" 2>&1)

# Check for errors in gcloud command
if [[ $? -ne 0 ]]; then
    echo "Error executing gcloud command: $CHECK_RESULT"
    exit 1
fi

# Check the result and decide whether to create a new brand or not
if [[ -z "$CHECK_RESULT" ]]; then
  echo "No OAuth Brand found for project $PROJECT_ID. Creating a new one..."
  CREATE_RESULT=$(gcloud iap oauth-brands create \
    --application_title="$APPLICATION_TITLE" \
    --support_email="$ADMIN_EMAIL" \
    --project="$PROJECT_ID"  2>&1)

  # Check for errors in gcloud command
  if [[ $? -ne 0 ]]; then
      echo "Error creating OAuth brand: $CREATE_RESULT"
      exit 1
  fi
  
  echo "Created New Brand:"
  echo "$CREATE_RESULT"
else
  echo "Target Application ($PROJECT_ID) already has an OAuth Brand."
  echo "Current Brand Information:"
  gcloud iap oauth-brands describe "$CHECK_RESULT" --project="$PROJECT_ID"
  echo "###############################################################"
  echo "Please use the GCP Web Console or gcloud to update it accordingly"
  echo "   Expected oauth-brands title       = $APPLICATION_TITLE"
  echo "   Expected oauth-brands admin email = $ADMIN_EMAIL"
  echo "###############################################################"
fi