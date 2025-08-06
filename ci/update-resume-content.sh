#!/bin/bash
echo "Uploading resume files..."

aws s3 rm s3://test-bucket-resume.peter-greaves.net --recursive
aws s3 cp ../html/index.html s3://test-bucket-resume.peter-greaves.net/
aws s3 cp ../html/stylesheet.css s3://test-bucket-resume.peter-greaves.net/


# now we need to create an invalidation on the CF distro

aws cloudfront create-invalidation \
    --distribution-id E133UXWPUYQ748 \
    --paths "/index.html" "/stylesheet.css"
