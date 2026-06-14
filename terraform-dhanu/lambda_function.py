import base64
import json
import boto3
import os

# Initialize the SageMaker Feature Store Runtime client in Mumbai
sagemaker_runtime = boto3.client('sagemaker-featurestore-runtime', region_name='ap-south-1')

FEATURE_GROUP_NAME = 'transactions-feature-group-dhanu'

def lambda_handler(event, context):
    processed_records = 0
    
    # Kinesis sends data in batches. We loop through the records.
    for record in event['Records']:
        # Kinesis data is base64 encoded, so we decode it first
        payload = base64.b64decode(record['kinesis']['data']).decode('utf-8')
        data = json.loads(payload)
        
        print(f"Processing event for User: {data['user_id']}")
        
        # SageMaker expects features in a specific List[Dict] format, and all values MUST be strings
        sagemaker_record = [
            {'FeatureName': 'user_id', 'ValueAsString': str(data['user_id'])},
            {'FeatureName': 'timestamp', 'ValueAsString': str(data['timestamp'])},
            {'FeatureName': 'amount', 'ValueAsString': str(data['amount'])},
            {'FeatureName': 'location_risk', 'ValueAsString': str(data['location_risk'])}
        ]
        
        try:
            # Push the real-time feature directly into the Online Store
            sagemaker_runtime.put_record(
                FeatureGroupName=FEATURE_GROUP_NAME,
                Record=sagemaker_record
            )
            processed_records += 1
        except Exception as e:
            print(f"Error putting record to Feature Store: {str(e)}")
            
    return {
        'statusCode': 200,
        'body': f"Successfully processed {processed_records} records."
    }