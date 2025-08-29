import json
import random
import string
from typing import Dict

import boto3
from botocore.exceptions import ClientError
import os
from datetime import datetime, timezone

# Initialize DynamoDB resource
dynamodb = boto3.resource('dynamodb')
metrics_table = dynamodb.Table('metrics')

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
            response = updateHits(event)
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
                'Access-Control-Allow-Origin': 'https://about.peter-greaves.net',
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
            'Access-Control-Allow-Origin': 'https://about.peter-greaves.net',
            'Access-Control-Allow-Methods': 'OPTIONS,PUT,GET'
        }
    }


def getHits():
    return getCount()

def updateHits(event):
    """
    trigger a PUT into DynamoDB, and then return the
    updated count
    """

    'hit datetime'
    now_utc = datetime.now(timezone.utc)
    iso_format = now_utc.strftime('%Y-%m-%dT%H:%M:%SZ')

    'generate a random string as ID'
    hit_id = ''.join(random.choices(string.ascii_uppercase + string.digits, k=6))
    headers = event.get("headers", {})

    #for header in headers:
    #   print(header)
    country = headers.get("CloudFront-Viewer-Country")

    if country is None:
        country = "Unknown"

    item_data = {
        'hits': hit_id,
        'hit_geo': country,
        'hit_dt': iso_format
    }
    insert_hit(item_data)
    return getCount()

def insert_hit(item_data):
    """
    Insert a single item using DynamoDB client (low-level API)
    """

    try:
        metrics_table.put_item(Item=item_data)
        print(f"Successfully inserted item: {item_data['hits']}")
        return None
    except ClientError as e:
        print(f"Error inserting item {item_data['hits']}: {e}")
        return None


def getCount():
    """
    Get the count from DynamoDB
    """
    # Method 1: Scan with Select=COUNT
    response = metrics_table.scan(Select='COUNT')
    count = response['Count']
    scanned_count = response['ScannedCount']

    # Handle pagination for accurate count on a hypothetically large metrics table
    while 'LastEvaluatedKey' in response:
        response = metrics_table.scan(
            Select='COUNT',
            ExclusiveStartKey=response['LastEvaluatedKey']
        )
        count += response['Count']
        scanned_count += response['ScannedCount']

    return count