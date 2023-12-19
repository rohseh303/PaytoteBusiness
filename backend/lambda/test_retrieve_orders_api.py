import requests

url = "https://connect.squareup.com/v2/orders/0qDc8QHsfL3KaZx7OJlPZuoH3SWZY"
headers = {
    'Square-Version': '2023-12-13',
    'Authorization': 'Bearer EAAAELEnB5K-QJvm-jydKXzVCtZY4adLihQtxLZPzegmqROguw6SWWIm4zbWSHZt',
    'Content-Type': 'application/json'
}

response = requests.get(url, headers=headers)

if response.status_code == 200:
    print(response.json())
else:
    print(f"Failed to retrieve order. Status code: {response.status_code}")
    print(response.text)