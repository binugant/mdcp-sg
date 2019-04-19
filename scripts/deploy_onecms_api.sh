#!/bin/bash

REGION=us-east-1
ENVIRONMENT="${CIRCLE_BRANCH//environment\/}"
STACK_NAME=onecms-wordpress-cfn
API_STACK_NAME="${STACK_NAME}"-API-GATEWAY
TEMPLATE=cfn/apigw.yml
CUSTOMER=onecms
PURPOSE=hosting

set -exo pipefail

regex="^environment\/([0-9a-z]*)"
if [[ $CIRCLE_BRANCH =~ $regex ]]; then
    env="${BASH_REMATCH[1]}"
    echo "Will attempt api $ENVIRONMENT environment deployment."
    digops-stacks change-set -e environment=${ENVIRONMENT} $API_STACK_NAME $TEMPLATE \
          --environment $CIRCLE_BRANCH \
          --region $REGION \
          --customer $CUSTOMER \
          --purpose $PURPOSE
    digops-stacks execute $API_STACK_NAME \
          --environment $CIRCLE_BRANCH \
          --region $REGION
else
    echo "Failed regex match '$regex'. Exiting."
fi
