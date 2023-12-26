import requests
from io import BytesIO
import boto3
import json

def lambda_handler(event, context):
    print(event)
    initial_url = event['invoice_link']
    invoice_id = initial_url.split('#')[-1]

    pdf_url = f"https://www.sandbox.paypal.com/invoice/s/pdf/pay/{invoice_id}?skipAuth=true"
    print(pdf_url)

    s3 = boto3.client('s3')
    bucket_name = 'receipts-global'  # Replace with your S3 bucket name

    response = requests.get(pdf_url)
    response.raise_for_status()

    # Create a BytesIO object from the response content
    fileobj = BytesIO(response.content)

    s3_key = f"paypal/{invoice_id}.pdf"
    s3.upload_fileobj(
        Fileobj=fileobj,
        Bucket=bucket_name,
        Key=s3_key,
        ExtraArgs={'ContentType': 'application/pdf'}
    )

    print("PDF uploaded to S3")

    return {
        'statusCode': 200,
        'body': json.dumps("PDF uploaded successfully")
    }
