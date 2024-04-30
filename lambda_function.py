import boto3
import json
 
S3_BUCKET_NAME = 'random-s3-test-bucket'
S3_BUCKET_PREFIX = 'CUSTOMER1/20240501/'
WORKLOAD_FILENAME = "CUSTOMER1/20240501/terraform.tf"
SNS_TOPIC_NAME = 'arn:aws:sns:eu-central-1:XXXXXXXXXXXXXXX:Sample-lambda-topic'

s3  = boto3.resource('s3') 
 
def lambda_handler(event, context):   
    my_bucket=s3.Bucket(S3_BUCKET_NAME)
    file_list = []
    for file in my_bucket.objects.filter(Prefix=S3_BUCKET_PREFIX ):
        file_name=file.key
        file_list.append(file_name)
    print(file_list)
    if (WORKLOAD_FILENAME in file_list):
        print('The file exists in the bucket.')
    else:
        sns = boto3.client('sns')
        response = sns.publish(
        TopicArn= SNS_TOPIC_NAME,   
        Message='Hello, you are receiving this email because the file you are expecting in s3 has not yet been created: '+S3_BUCKET_NAME+WORKLOAD_FILENAME,   
           )