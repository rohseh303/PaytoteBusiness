//
//  LoginUser.swift
//  PayTote
//
//  Created by Rohan Sehgal on 12/19/23.
//

import Foundation

func loginUser(userIdentifier: String) async {
    // Define the URL for the API endpoint
    guard let url = URL(string: "https://nxq56w6ffg.execute-api.us-west-1.amazonaws.com/v1") else {
        print("Invalid URL")
        return
    }

    // Create the URLRequest object
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    // Prepare the JSON data for the request body
    let requestData = ["userID": userIdentifier]

    // Convert the request data to JSON
    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: requestData, options: [])
    } catch {
        print("Error in encoding request data")
        return
    }

    // Perform the network request
    do {
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Check for HTTP response
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
            // Parse the response data
            if let jsonStr = String(data: data, encoding: .utf8) {
                parseAndSaveUserData(jsonStr)
            }
        } else {
            print("Error: Invalid response or data")
        }
    } catch {
        print("Network request failed: \(error)")
    }
}

// Function to parse the JSON string and save user data to UserDefaults
func parseAndSaveUserData(_ jsonString: String) {
    if let data = jsonString.data(using: .utf8) {
        do {
            // First-level JSON parsing
            if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let bodyString = jsonResponse["body"] as? String,
               let bodyData = bodyString.data(using: .utf8) {
                
                // Second-level JSON parsing for the 'body' field
                if let userData = try JSONSerialization.jsonObject(with: bodyData, options: []) as? [String: Any] {
                    // Extract and save user information
                    if let emailDict = userData["email"] as? [String: String],
                       let firstNameDict = userData["firstName"] as? [String: String],
                       let lastNameDict = userData["lastName"] as? [String: String] {
                        
                        let email = emailDict["S"] ?? ""
                        let firstName = firstNameDict["S"] ?? ""
                        let lastName = lastNameDict["S"] ?? ""

                        // Update UserDefaults
                        UserDefaults.standard.set(email, forKey: "UserEmail")
                        UserDefaults.standard.set(firstName, forKey: "UserFirstName")
                        UserDefaults.standard.set(lastName, forKey: "UserLastName")
                        UserDefaults.standard.set(true, forKey: "IsLoggedIn")
                        
                        print("User data updated in UserDefaults.")
                    }
                }
            }
        } catch {
            print("Error parsing JSON: \(error)")
        }
    }
}
