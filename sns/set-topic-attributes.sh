#!/usr/bin/env bash

if [ "$AWS_PROFILE" = "" ]; then
  echo "No AWS_PROFILE set"
  exit 1
fi

echo -n input region:
read region

echo -n input SuccessSampleRate:
read SuccessSampleRate

echo -n input IAMRoleForSuccessful Arn:
read IAMRoleForSuccessful

echo -n input IAMRoleForFailed Arn:
read IAMRoleForFailed


for arn in $(aws sns --region ${region} list-topics | jq -r .Topics[].TopicArn); do

  echo "* ${region} - ${arn}"
  aws sns set-topic-attributes --region ${region} --topic-arn ${arn} --attribute-name LambdaSuccessFeedbackSampleRate --attribute-value ${SuccessSampleRate}
  aws sns set-topic-attributes --region ${region} --topic-arn ${arn} --attribute-name FirehoseSuccessFeedbackSampleRate --attribute-value ${SuccessSampleRate}
  aws sns set-topic-attributes --region ${region} --topic-arn ${arn} --attribute-name SQSSuccessFeedbackSampleRate --attribute-value ${SuccessSampleRate}
  aws sns set-topic-attributes --region ${region} --topic-arn ${arn} --attribute-name HTTPSuccessFeedbackSampleRate --attribute-value ${SuccessSampleRate}
  aws sns set-topic-attributes --region ${region} --topic-arn ${arn} --attribute-name ApplicationSuccessFeedbackSampleRate --attribute-value ${SuccessSampleRate}

  aws sns set-topic-attributes --region ${region} --topic-arn ${arn} --attribute-name SQSFailureFeedbackRoleArn --attribute-value ${IAMRoleForFailed}
  aws sns set-topic-attributes --region ${region} --topic-arn ${arn} --attribute-name FirehoseFailureFeedbackRoleArn --attribute-value ${IAMRoleForFailed}
  aws sns set-topic-attributes --region ${region} --topic-arn ${arn} --attribute-name ApplicationFailureFeedbackRoleArn --attribute-value ${IAMRoleForFailed}
  aws sns set-topic-attributes --region ${region} --topic-arn ${arn} --attribute-name LambdaFailureFeedbackRoleArn --attribute-value ${IAMRoleForFailed}
  aws sns set-topic-attributes --region ${region} --topic-arn ${arn} --attribute-name HTTPFailureFeedbackRoleArn --attribute-value ${IAMRoleForFailed}

  aws sns set-topic-attributes --region ${region} --topic-arn ${arn} --attribute-name ApplicationSuccessFeedbackRoleArn --attribute-value ${IAMRoleForSuccessful}
  aws sns set-topic-attributes --region ${region} --topic-arn ${arn} --attribute-name FirehoseSuccessFeedbackRoleArn --attribute-value ${IAMRoleForSuccessful}
  aws sns set-topic-attributes --region ${region} --topic-arn ${arn} --attribute-name SQSSuccessFeedbackRoleArn --attribute-value ${IAMRoleForSuccessful}
  aws sns set-topic-attributes --region ${region} --topic-arn ${arn} --attribute-name HTTPSuccessFeedbackRoleArn --attribute-value ${IAMRoleForSuccessful}
  aws sns set-topic-attributes --region ${region} --topic-arn ${arn} --attribute-name LambdaSuccessFeedbackRoleArn --attribute-value ${IAMRoleForSuccessful}

done
