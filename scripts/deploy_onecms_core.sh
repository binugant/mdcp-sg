#!/bin/bash -e

REGION=us-east-1
STACK_NAME=sg-cfn
# EB_STACK_NAME="${STACK_NAME}--Application"
BASE_STACK_NAME="${STACK_NAME}-Base"
# TEMPLATE=cfn/onecms.yml
BASE_TEMPLATE=cfn/template.yml
CUSTOMER=test
PURPOSE=hosting
NESTED_STACK_VERSION='version/13.8.1'

# create beanstalk application on master only
if [[ $CIRCLE_BRANCH == "master" ]]; then
    
    echo "On master branch. Creating SG application."

    set -exo pipefail
    # digops-stacks change-set $EB_STACK_NAME \
        # https://s3.amazonaws.com/digops-stacks/${NESTED_STACK_VERSION}/eb-application.template \
        # --environment production \
        # --customer $CUSTOMER \
        # --purpose $PURPOSE \
        # --region $REGION \
        # --extra-vars ApplicationName=${STACK_NAME},MaxCountVersions=100
    
    # digops-stacks execute $EB_STACK_NAME \
        # --environment production \
        # --region $REGION

    echo "Creating base resources"
    digops-stacks change-set $BASE_STACK_NAME $BASE_TEMPLATE \
    	--environment production \
        --region $REGION \
	--customer $CUSTOMER \
	--purpose $PURPOSE

    digops-stacks execute $BASE_STACK_NAME \
    	--environment production \
	--region $REGION

    exit 0
fi


regex="^environment\/([0-9a-z]*)"
if [[ $CIRCLE_BRANCH =~ $regex ]]; then
    env="${BASH_REMATCH[1]}"
    echo "Will attempt sg $env environment deployment."
else
    echo "Failed regex match '$regex'. Exiting."
    exit 1
fi       

# set -exo pipefail
# digops-stacks change-set $STACK_NAME $TEMPLATE \
      # --environment $CIRCLE_BRANCH \
      # --region $REGION \
      # --customer $CUSTOMER \
      # --purpose $PURPOSE
# digops-stacks execute $STACK_NAME \
      # --environment $CIRCLE_BRANCH \
      # --region $REGION

exit 0
