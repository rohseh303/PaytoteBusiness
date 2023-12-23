# import os
# import time
# from selenium import webdriver
# from selenium.webdriver.common.by import By
# from selenium.webdriver.support.ui import WebDriverWait
# from selenium.webdriver.support import expected_conditions as EC

# # Configuration for download directory and URL
# download_dir = "/path/to/download/directory"
# url = "https://www.sandbox.paypal.com/invoice/p/#INV2-G8YA-UDVZ-3ANJ-V7XV"

# # Set up Chrome options
# options = webdriver.ChromeOptions()
# prefs = {"download.default_directory": download_dir}
# options.add_experimental_option("prefs", prefs)

# # Initialize WebDriver
# driver = webdriver.Chrome(options=options)

# try:
#     # Navigate to the URL
#     driver.get(url)
#     print("Navigated to URL.")

#     # Wait and click the button that opens the popup
#     # Replace 'button_identifier' with the actual identifier of your button
#     initial_download_button = WebDriverWait(driver, 10).until(
#         EC.element_to_be_clickable((By.CLASS_NAME, "download-pdf"))
#     )
#     initial_download_button.click()
#     print("Clicked the initial download button.")

#     # Wait for the iframe to be available and switch to it
#     WebDriverWait(driver, 10).until(
#         EC.frame_to_be_available_and_switch_to_it((By.ID, "pdfObject"))
#     )
#     print("Switched to iframe.")

#     # Locate and click the actual download button inside the iframe
#     # You need to inspect the iframe content and replace 'actual_download_button_identifier'
#     # with the correct selector for the download button
#     actual_download_button = WebDriverWait(driver, 10).until(
#         EC.element_to_be_clickable((By.ID, "actual_download_button_identifier"))
#     )
#     actual_download_button.click()
#     print("Clicked the download button inside the iframe.")

#     # Wait for the download to complete
#     time.sleep(10)  # Adjust this time based on your download speed
#     print("Waiting for the download to complete.")

#     # Verify if the file is downloaded
#     downloaded_files = [f for f in os.listdir(download_dir) if f.endswith('.pdf')]
#     if downloaded_files:
#         print("Downloaded files:", downloaded_files)
#     else:
#         print("No files were downloaded.")

# except Exception as e:
#     print("An error occurred:", e)
# finally:
#     driver.quit()

import requests

# URL of the PDF file
pdf_url = "https://www.sandbox.paypal.com/invoice/s/pdf/pay/INV2-G8YA-UDVZ-3ANJ-V7XV?skipAuth=true&time=1703314650698&removeQr=false"

# Path where you want to save the PDF file
save_path = "/Users/rohansehgal/Desktop/PayToteBusiness/paypal/invoice.pdf"

# Send a GET request to the URL
response = requests.get(pdf_url)

# Ensure the request was successful
response.raise_for_status()

# Write the content to a file
with open(save_path, 'wb') as file:
    file.write(response.content)

print(f"PDF has been downloaded and saved to: {save_path}")