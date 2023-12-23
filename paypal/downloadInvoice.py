# from selenium import webdriver
# from selenium.webdriver.common.by import By
# from selenium.webdriver.support.ui import WebDriverWait
# from selenium.webdriver.support import expected_conditions as EC
# import requests
# import time

# # Your invoice page URL
# url = "https://www.sandbox.paypal.com/invoice/p/#INV2-G8YA-UDVZ-3ANJ-V7XV"

# # Path to the ChromeDriver and setup for download directory
# chrome_driver_path = '/Library/Frameworks/Python.framework/Versions/3.11/lib/python3.11/site-packages/chromedriver_binary/chromedriver'
# download_dir = "/Users/rohansehgal/Desktop/PayToteBusiness/paypal"

# # Set up Chrome options
# options = webdriver.ChromeOptions()
# prefs = {"download.default_directory": download_dir}
# options.add_experimental_option("prefs", prefs)

# # Initialize WebDriver
# driver = webdriver.Chrome(options=options)


# try:
#     # Navigate to the URL
#     driver.get(url)

#     # Switch to the iframe containing the PDF
#     WebDriverWait(driver, 10).until(
#         EC.frame_to_be_available_and_switch_to_it((By.ID, "pdfObject"))
#     )
#     print("Switched to iframe.")

#     # Extract the 'src' attribute from the iframe
#     iframe = driver.find_element(By.ID, "pdfObject")
#     pdf_url = iframe.get_attribute('src')

#     # Append the base URL if the src is a relative path
#     if pdf_url.startswith("/"):
#         pdf_url = f"https://www.sandbox.paypal.com{pdf_url}"

#     # Use requests to download the PDF
#     response = requests.get(pdf_url)
#     response.raise_for_status()  # Raises an HTTPError if the HTTP request returned an unsuccessful status code

#     # Save the PDF to a file in the specified directory
#     with open(f"{download_dir}/invoice.pdf", 'wb') as f:
#         f.write(response.content)
#     print(f"PDF has been downloaded and saved to {download_dir}/invoice.pdf")

# except Exception as e:
#     print(f"An error occurred: {e}")

# finally:
#     driver.quit()


import requests

# The initial URL
initial_url = "https://www.sandbox.paypal.com/invoice/p/#INV2-G8YA-UDVZ-3ANJ-V7XV"

# Extract the invoice ID
invoice_id = initial_url.split('#')[-1]

# Construct the download URL
pdf_url = f"https://www.sandbox.paypal.com/invoice/s/pdf/pay/{invoice_id}?skipAuth=true"
print(pdf_url)

# Path to save the downloaded PDF
save_path = f"/Users/rohansehgal/Desktop/PayToteBusiness/paypal/{invoice_id}.pdf"

# Send a GET request to the download URL
response = requests.get(pdf_url)
response.raise_for_status()  # Raises an HTTPError for bad requests

# Save the PDF file
with open(save_path, 'wb') as file:
    file.write(response.content)

print(f"PDF has been downloaded and saved to: {save_path}")


# import requests

# # URL of the PDF file
# pdf_url = "https://www.sandbox.paypal.com/invoice/s/pdf/pay/INV2-G8YA-UDVZ-3ANJ-V7XV?skipAuth=true&time=1703314650698&removeQr=false"

# # Path where you want to save the PDF file
# save_path = "/Users/rohansehgal/Desktop/PayToteBusiness/paypal/invoice.pdf"

# # Send a GET request to the URL
# response = requests.get(pdf_url)

# # Ensure the request was successful
# response.raise_for_status()

# # Write the content to a file
# with open(save_path, 'wb') as file:
#     file.write(response.content)

# print(f"PDF has been downloaded and saved to: {save_path}")