import json
import boto3
import os
import datetime
s3 = boto3.client('s3')

REDIS_ENDPOINT=os.environ["REDIS_ENDPOINT"]

def lambda_handler(event, context):
    try:
      bucket = event['Records'][0]['s3']['bucket']['name']
      key = event['Records'][0]['s3']['object']['key']
      creation_timestamp = str(datetime.datetime.now())
      data = {
        "FileName": key,
        "CreationTimestamp": creation_timestamp
      }
      json_data = json.dumps(data)
      redis_client = boto3.client('elasticache')
      try:
        response = redis_client.put_item(
            CacheClusterId='your-redis-cluster-id',
            Key=key,
            Value=json_data
        )
        print(f"Data written to ElastiCache: {json_data}")
      except Exception as e:
        print(f"Error writing to ElastiCache: {e}")

      return {
        'statusCode': 200,
        'body': json.dumps('Lambda executed successfully!')
      }
