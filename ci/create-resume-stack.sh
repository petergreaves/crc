#!/bin/bash
source check_stack.sh

echo "Clearing resume bucket..."
aws s3 rm s3://test-bucket-resume.peter-greaves.net --recursive

check_stack_exists "resume-stack-2"
result=$?
 # Print result and exit with the return code
if [ $result -eq 1 ]; then
    echo "Stack resume-stack-2 exists..."
    echo "Deleting stack ..."
    aws cloudformation delete-stack --stack-name resume-stack-2
    echo "Waiting for delete-stack confirmation ..."
    aws cloudformation wait stack-delete-complete --stack-name resume-stack-2
fi

echo "Creating stack ..."
aws cloudformation create-stack \
  --stack-name resume-stack-2 \
  --template-body file://resume-stack-template.json \
  --parameters \
    ParameterKey=BucketName,ParameterValue=test-bucket-resume.peter-greaves.net \
    ParameterKey=IndexDocument,ParameterValue=index.html \
    ParameterKey=ErrorDocument,ParameterValue=index.html \
    ParameterKey=DomainName,ParameterValue=resume.peter-greaves.net \
    ParameterKey=AcmCertificateArn,ParameterValue=arn:aws:acm:us-east-1:869700439563:certificate/0736b2dc-093f-4a60-bacb-e28e70414a25
echo "Waiting for create confirmation..."
aws cloudformation wait stack-create-complete --stack-name resume-stack-2
echo "Stack created..."
echo "Uploading resume files..."
aws s3 cp ../html/index.html s3://test-bucket-resume.peter-greaves.net/
aws s3 cp ../html/stylesheet.css s3://test-bucket-resume.peter-greaves.net/

