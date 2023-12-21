//
//  CreateAccount.swift
//  PayTote
//
//  Created by Rohan Sehgal on 11/19/23.
//

import SwiftUI
import AuthenticationServices

struct CreateAccount: View {
    @Binding var loginStatus: Bool
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var passwordMessage = ""

    var body: some View {
            VStack() {
                Text("Sign in with Apple")
                
                SignInWithAppleButton(.continue) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    switch result {
                    case .success(let auth):
                        switch auth.credential {
                        case let credential as ASAuthorizationAppleIDCredential:
                            let userID = credential.user
                            print("userID: ", userID)
                            UserDefaults.standard.set(userID, forKey: "userID")
                            if let email = credential.email, let firstName = credential.fullName?.givenName, let lastName = credential.fullName?.familyName {
                                // Cache user details
                                UserDefaults.standard.set(email, forKey: "UserEmail")
                                UserDefaults.standard.set(firstName, forKey: "UserFirstName")
                                UserDefaults.standard.set(lastName, forKey: "UserLastName")
                                UserDefaults.standard.set(true, forKey: "IsLoggedIn")
                                
                                // Perform network request
                                Task {
                                    await registerUser(userID: userID, email: email, firstName: firstName, lastName: lastName)
                                }
                            }
                            else {
                                // Existing user login
                                // Perform network request for user login
                                Task {
                                    await loginUser(userIdentifier: userID)
                                }
                            }
                            
                            loginStatus = true

                        default:
                            break
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
                .frame(height: 50)
                .padding()
                .cornerRadius(8)
            }
        }
    
    // Asynchronous network request function
    func registerUser(userID: String, email: String, firstName: String, lastName: String) async {
            // Define the URL for the API endpoint
            guard let url = URL(string: "https://jgz0to3dja.execute-api.us-west-1.amazonaws.com/v1") else {
                print("Invalid URL")
                return
            }

            // Create the URLRequest object
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            // Prepare the JSON data
            let requestData = [
                "userID": userID,
                "email": email,
                "firstName": firstName,
                "lastName": lastName
            ]

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
                    // Handle the response data
                    print("Response data: \(String(describing: String(data: data, encoding: .utf8)))")
                } else {
                    print("Error: Invalid response or data")
                }
            } catch {
                print("Network request failed: \(error)")
            }
        }

//    private func validatePassword() {
//        if !passwordIsValid(password) {
//            passwordMessage = "Password must be at least 8 characters, include a number and an uppercase letter"
//        } else if password != confirmPassword {
//            passwordMessage = "Passwords do not match"
//        } else {
//            passwordMessage = "Password is valid"
//        }
//    }
//
//    private func passwordIsValid(_ password: String) -> Bool {
//        let passwordRegEx = "^(?=.*[A-Z])(?=.*[0-9]).{8,}$"
//        let passwordPred = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
//        return passwordPred.evaluate(with: password)
//    }
}

struct CreateAccount_Previews: PreviewProvider {
    static var previews: some View {
        CreateAccount(loginStatus: .constant(false))
    }
}
