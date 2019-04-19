#!/bin/bash

: "${CIRCLE_BRANCH:=environment/do}"
: "${CIRCLECI:=false}"

if $CIRCLECI; then
    echo "Running on CircleCI"
    DOCKER_CMD_PREFIX=""
else
    echo "Not running on CircleCI. Assume local and run digops via container."
    DOCKER_CMD_PREFIX="docker-compose run digops-stacks-container "
fi

REGION=us-east-1
ENVIRONMENT="${CIRCLE_BRANCH//environment\/}"
STACK_NAME=onecms-wordpress-cfn
TOOLS_STACK_NAME="${STACK_NAME}"-infra-tools
TEMPLATE=cfn/onecms-tools.yml
CUSTOMER=onecms
PURPOSE=hosting

set -exo pipefail

regex="^environment\/([0-9a-z]*)"
if [[ $CIRCLE_BRANCH =~ $regex ]]; then
    env="${BASH_REMATCH[1]}"
    echo "Will attempt infra tools $ENVIRONMENT environment deployment."
    $DOCKER_CMD_PREFIX digops-stacks change-set -e environment=${ENVIRONMENT} $TOOLS_STACK_NAME $TEMPLATE \
          --environment $CIRCLE_BRANCH \
          --region $REGION \
          --customer $CUSTOMER \
          --purpose $PURPOSE
    $DOCKER_CMD_PREFIX digops-stacks execute $TOOLS_STACK_NAME \
          --environment $CIRCLE_BRANCH \
          --region $REGION
else
    echo "Failed regex match '$regex'. Exiting."
fi
