#!/usr/bin/env bash

if [ "$AWS_PROFILE" = "" ]; then
  echo "No AWS_PROFILE set"
  exit 1
fi

for region in $(aws ec2 describe-regions --region ap-northeast-1 | jq -r .Regions[].RegionName); do
  echo "* ${region}"
  aws securityhub batch-disable-standards --region ${region} --standards-subscription-arn ""arn:aws:securityhub:${region}:$(aws sts get-caller-identity --query 'Account' --output text):subscription/cis-aws-foundations-benchmark/v/1.2.0""
done
