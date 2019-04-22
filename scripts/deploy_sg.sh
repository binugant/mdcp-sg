#!/bin/bash

if [ -z "$1" ];  then
   echo "Missing environment arg"
   exit 1
fi

ENV=environment/$1
REGION=us-east-1
STACK_NAME=onesg-aws034876-cfn
TEMPLATE=cfn/template.yml
CUSTOMER=mdcp
PURPOSE=hosting

# cfn-lint --ignore-checks W2001 W8001 -t $TEMPLATE
# yamllint -d "{extends: relaxed, rules: {line-length: {max: 150}}}" $TEMPLATE

aws cloudformation deploy --template-file ./cfn/template.yml --stack-name test-stack-abc98383838
# docker-compose run digops-stacks digops-stacks change-set $STACK_NAME $TEMPLATE \
	       # --environment $ENV \
	       # --region $REGION \
	       # --customer $CUSTOMER \
	       # --purpose $PURPOSE

# docker-compose run digops-stacks digops-stacks execute $STACK_NAME \
	       # --environment $ENV \
	       # --region $REGION

