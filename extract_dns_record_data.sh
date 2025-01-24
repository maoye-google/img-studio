#!/bin/bash

# Check if a log ID was provided as an argument
if [ -z "$1" ]; then
  echo "Error: Log ID is required as a command-line argument."
  exit 1
fi

# Get the log ID from the command-line argument
log_id="$1"

# Get the log using gcloud
log_output=$(gcloud builds log "$log_id" 2>&1)

# Check for gcloud errors
if [ $? -ne 0 ]; then
  echo "Error executing gcloud command:"
  echo "$log_output"
  exit 1
fi

# Extract expected_customer_domain
expected_customer_domain=$(echo "$log_output" | grep "expected_customer_domain" | awk -F ' = ' '{print $2}' | tr -d '"')

# Extract load_balancer_external_ip
load_balancer_external_ip=$(echo "$log_output" | grep "load_balancer_external_ip" | awk -F ' = ' '{print $2}' | tr -d '"')

# Validate IP address format
# Using a regular expression to check for a basic IP address pattern
if [[ "$load_balancer_external_ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
  # Further validation: Check if each octet is within the 0-255 range
  IFS='.' read -ra ip_parts <<< "$load_balancer_external_ip"
  valid_ip=true
  for part in "${ip_parts[@]}"; do
    if (( part < 0 || part > 255 )); then
      valid_ip=false
      break
    fi
  done

  if ! $valid_ip; then
    echo "Error: Invalid IP address format for load_balancer_external_ip: $load_balancer_external_ip"
    load_balancer_external_ip="" # Reset to empty if invalid
  fi
else
  echo "Error: Invalid IP address format for load_balancer_external_ip: $load_balancer_external_ip"
  load_balancer_external_ip="" # Reset to empty if invalid
fi

# Check if both values are valid
if [ -n "$expected_customer_domain" ] && [ -n "$load_balancer_external_ip" ]; then
  echo "Please set up necessary DNS records MANUALLY ! "
  echo "   Expected Customer Domain  = $expected_customer_domain"
  echo "   External Load Balancer IP = $load_balancer_external_ip"
  echo "Command Example : ./set_dns_record.sh $load_balancer_external_ip $expected_customer_domain"
else
  # Print individual error messages if either value is missing or invalid
  if [ -z "$expected_customer_domain" ]; then
    echo "Error: expected_customer_domain not found in the log."
    echo "Please Double Check you Oauth App Setting"
  else
    echo "   Expected Customer Domain  = $expected_customer_domain"
  fi

  if [ -z "$load_balancer_external_ip" ]; then
    echo "Error: load_balancer_external_ip not found in the log or is invalid."
    echo "Please Double Check you Oauth App Setting"
  else
    echo "   External Load Balancer IP = $load_balancer_external_ip"
  fi
fi