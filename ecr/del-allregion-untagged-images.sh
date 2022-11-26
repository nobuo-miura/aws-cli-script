#!/usr/bin/env bash


if [ "$AWS_PROFILE" = "" ]; then
  echo "No AWS_PROFILE set"
  exit 1
fi


for region in $(aws ec2 describe-regions --region ap-northeast-1 | jq -r .Regions[].RegionName); do

  echo "* Region ${region}"

  aws ecr describe-repositories --region ${region} \
  | jq --raw-output .repositories[].repositoryName \
  | while read repo; do  
      imageIds=$(aws ecr list-images --repository-name $repo --filter tagStatus=UNTAGGED --query 'imageIds[*]' --output json  | jq -r '[.[].imageDigest] | map("imageDigest="+.) | join (" ")');
      if [[ "$imageIds" == "" ]]; then continue; fi
      aws ecr batch-delete-image --repository-name $repo --image-ids $imageIds; 
  done

done
