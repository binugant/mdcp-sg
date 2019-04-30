#!/bin/bash -e

: "${CIRCLECI:=false}"

if $CIRCLECI; then
    echo "Running on CircleCI"
    DOCKER_CMD_PREFIX=""
else
    echo "Not running on CircleCI. Assume local and run digops via container."
    DOCKER_CMD_PREFIX="docker-compose run digops-stacks-container "
    : "${CIRCLE_BRANCH:=$(git rev-parse --abbrev-ref HEAD)}" # use active branch if CIRCLE_BRANCH envir var not set
    
    aws_account=$(aws iam list-account-aliases --query 'AccountAliases' --output text)
    echo "Resources in the \"$CIRCLE_BRANCH\" branch will be created in the \"$aws_account\" aws account."
    echo "PRESS ANY KEY TO CONTINUE."
    read
fi

REGION=us-east-1
STACK_NAME=StackSet-sg-bhaskar
#BASE_STACK_NAME="${STACK_NAME}-security"
TEMPLATE=cfn/template.yml
#BASE_TEMPLATE=cfn/template.yml
CUSTOMER=bhaskar
PURPOSE=hosting
#NESTED_STACK_VERSION='version/13.9.4'


if ! $(command -v yamllint >/dev/null 2>&1); then
    pip install yamllint
fi


# # create beanstalk application on master only
# if [[ $CIRCLE_BRANCH == "master" ]]; then
    
    # echo "On master branch. Creating base resources"
    # set -exo pipefail
    # echo
    # cfn-lint --ignore-checks W1020 W2001 W8001 -t $TEMPLATE
    # yamllint -d "{extends: relaxed, rules: {line-length: {max: 150}}}" $TEMPLATE
    # $DOCKER_CMD_PREFIX digops-stacks change-set $BASE_STACK_NAME $BASE_TEMPLATE \
    	# --environment production \
        # --region $REGION \
	# --customer $CUSTOMER \
	# --purpose $PURPOSE

    # $DOCKER_CMD_PREFIX digops-stacks execute $BASE_STACK_NAME \
    	# --environment production \
	# --region $REGION

    # exit 0
# fi


regex="^environment\/([0-9a-z]*)"
if [[ $CIRCLE_BRANCH =~ $regex ]]; then
    env="${BASH_REMATCH[1]}"
    echo "Will attempt sg $env environment deployment."
else
    echo "Failed regex match '$regex'. Exiting."
    exit 1
fi       


set -exo pipefail
cfn-lint --ignore-checks W1020 W2001 W8001 -t $TEMPLATE
yamllint -d "{extends: relaxed, rules: {line-length: {max: 150}}}" $TEMPLATE

$DOCKER_CMD_PREFIX digops-stacks change-set $STACK_NAME $TEMPLATE \
      --environment $env \
      --region $REGION \
      --customer $CUSTOMER \
      --purpose $PURPOSE
$DOCKER_CMD_PREFIX digops-stacks execute $STACK_NAME \
      --environment $env \
      --region $REGION

exit 0
