import json
import boto3
from botocore.exceptions import ClientError
import os
from datetime import datetime

# Initialize DynamoDB resource
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('metrics')


def counter_handler(event, context):
    """
    Lambda handler function that demonstrates DynamoDB operations
    we only support GET to retrieve the count of all items (or 0),
    and PUT, which adds a new item and returns the updated count.
    """

    try:

        # Get HTTP method - check multiple possible locations
        http_method = None

        # API Gateway REST API format
        if 'httpMethod' in event:
            http_method = event['httpMethod']
        # API Gateway HTTP API format (v2.0)
        elif 'requestContext' in event and 'http' in event['requestContext']:
            http_method = event['requestContext']['http'].get('method')
        # Lambda Function URL format
        elif 'requestContext' in event and 'http' in event['requestContext']:
            http_method = event['requestContext']['http'].get('method')
        # Alternative location for some integrations
        elif 'requestContext' in event and 'httpMethod' in event['requestContext']:
            http_method = event['requestContext']['httpMethod']

        if http_method == 'GET':
            response = getHits()
        elif http_method == 'PUT':
            response = updateHits()
        elif http_method == 'OPTIONS':
            return getOptions()
        else:
            return {
                'statusCode': 400,
                'body': json.dumps({
                    'error': f'Unsupported http_method: {http_method}',
                    'supported_operations': ['get', 'put', 'options']
                })
            }
        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Origin': 'https://resume.peter-greaves.net',
                'Access-Control-Allow-Methods': 'OPTIONS,PUT,GET'},
            'body': json.dumps({
                'hits': response
            }, default=str)
        }

    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': str(e)
            })
        }


def getOptions():
    return {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Allow-Origin': 'https://resume.peter-greaves.net',
            'Access-Control-Allow-Methods': 'OPTIONS,PUT,GET'
        }
    }


def getHits():
    return getCount()


def updateHits():
    """
    trigger a PUT into DynamoDB, and then return the
    updated count
    """

    # get current hit count value
    response = table.get_item(Key={'hits': ''}, ProjectionExpression='hit_count')
    currentCount = response['Item']['hit_count']

    # increment it by one, or set it to one if first time

    if currentCount is None:
        newCount = 1
    else:
        newCount = currentCount + 1

    try:
        table.update_item(
            Key={'metrics': 'hits'},
            UpdateExpression='SET hit_count = :newCount',
            ExpressionAttributeValues={':newCount': newCount}
        )
        return newCount
    except ClientError as e:
        raise Exception(f"Error putting hit: {e.response['Error']['Message']}")


def getCount():
    """
    Get the count from DynamoDB
    """
    try:
        response = table.get_item(Key={'metrics': 'hits'}, ProjectionExpression='hit_count')
        currentCount = response['Item']['hit_count']
        return currentCount
    except ClientError as e:
        raise Exception(f"Error getting count: {e.response['Error']['Message']}")
