#!/usr/bin/env bash

if [ "$AWS_PROFILE" = "" ]; then
  echo "No AWS_PROFILE set"
  exit 1
fi

echo -n input region:
read region

echo -n input notification-arns:
read snsarn


for stackname in $(aws cloudformation --region ${region} list-stacks | jq -r .StackSummaries[].StackName); do
  echo "* ${region} -> ${stackname}"
  aws cloudformation update-stack --region ${region} --stack-name ${stackname} --use-previous-template --notification-arns ${snsarn}
done
