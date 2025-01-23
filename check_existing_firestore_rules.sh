#!/bin/bash


PROJECT_ID="img-studio-demo-001"
ACCESS_TOKEN=$(gcloud auth print-access-token)

RULESET_INFO=$(curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  "https://firebaserules.googleapis.com/v1/projects/$PROJECT_ID/rulesets/")

echo "$RULESET_INFO"