import json
import boto3
import requests

def lambda_handler(event, context):
    print(event)
    receipt_url = event['data']['object']['payment']['receipt_url']
    temp = event['created_at'].split('T')
    date = temp[0]
    order_id = event['data']['object']['payment']['order_id']
    
    # # Set your access token
    # access_token = 'EAAAELEnB5K-QJvm-jydKXzVCtZY4adLihQtxLZPzegmqROguw6SWWIm4zbWSHZt'
    
    # Set the headers
    headers = {
        'Square-Version': '2023-12-13',
        'Authorization': 'Bearer EAAAELEnB5K-QJvm-jydKXzVCtZY4adLihQtxLZPzegmqROguw6SWWIm4zbWSHZt',
        'Content-Type': 'application/json'
    }
    
    client = boto3.client('lambda')
    
    # Define the URL
    url = f'https://connect.squareup.com/v2/orders/{order_id}'
    
    # Make the GET request
    response = requests.get(url, headers=headers)
    
    # Check if the request was successful
    if response.status_code == 200:
        # Parse the JSON response
        order_data = response.json()
        print("order data: ", order_data)

        fufillments = order_data['order']['fulfillments'][0] # ['pickup_details']['recipient']['email_address']
        if 'pickup_details' in fufillments:
            email = fufillments['pickup_details']['recipient']['email_address']
        elif 'shipment_details' in fufillments:
            email = fufillments['shipment_details']['recipient']['email_address']
        else:
            email = "ERROR: could not find email and went into else clause"
        
        print("customer's email: ", email)

    else:
        print(f'Failed to retrieve order. Status code: {response.status_code}')

    # List of target Lambda functions
    target_functions = [
        'screenshotReceipt',
        'attachReceiptToUser'
    ]

    # Prepare the payload. Note that it's a dictionary with a single key-value pair,
    # where the key is the name of the input parameter that `screenshotReceipt` is expecting.
    payload = json.dumps({
        'receipt_input': receipt_url,
        'created_at': date, # 'receipt_input' is an example. Use the actual parameter name.
        'email': email
    }).encode()

    print("going to invoke funtions now")

    # Invoke each target Lambda function
    for function_name in target_functions:
        response = client.invoke(
            FunctionName=function_name,
            InvocationType='Event',
            Payload=payload
        )

    print("check s3 bucket")
    
    return {
        'statusCode': 200,
        'body': json.dumps(event)
    }