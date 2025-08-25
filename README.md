This project is an implementation more or less faithfully following the <a href="https://cloudresumechallenge.dev">Cloud Resume Challenge</a>. The URL of the resume is https://about.peter-greaves.net, and was designed to be an illustration of the skills I have acquired by
taking on the challenges.  It is hosted on the free-tier AWS technologies.   I pay a trivial Route53 fee for DNS for the hostname, but that's all.

# Project technical details
The project is composed of two technology code-bases:

- the IaC components which are terraform files in the tf path
- the serverless component, a Lambda that handles the visitor count on the page, which is a Python implementation off the src path

# How it works
## Host name and DNS
The hostname is registered and all network-level ingress managed in records in an AWS Route 53 Hosted Zone.  Apart from the DNS Domain, all the Route53 stuff is under TF/IAC.
## HTML page storage and serving
The resume content (simple HTML/CSS) is served from an S3 bucket via CloudFront. There is some JavaScript in the page that asynchronously calls the visitor count Lambda
(via the API gateway), which  This content is in the HTML directory, and is not managed with Terraform.  I use the aws cli to manage the content.

## Recording hits (application)
The Lambda handles PUT requests via the API gateway.  When it receives a PUT request, it adds an item to an Amazon DynamoDB database, counts the items and returns the total number
of items back to the JavaScript which updates the DOM in the page.  The Lambda also supports GET and OPTIONS (for CORS reasons).

## Recording hits (database)
The Lambda persists data in an Amazon DynamoDB database.
