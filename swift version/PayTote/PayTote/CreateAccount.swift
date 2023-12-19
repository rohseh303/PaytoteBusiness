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
            
            SignInWithAppleButton(.continue) {request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                switch result {
                case .success(let auth):
                    switch auth.credential {
                    case let credential as ASAuthorizationAppleIDCredential:
//                        let userId = credential.user
                        
                        //need to cache into AWS or userDefaults
                        let email = credential.email
                        let firstName = credential.fullName?.givenName
                        let lastName = credential.fullName?.familyName
                        loginStatus = true
                        
                        UserDefaults.standard.set(email, forKey: "UserEmail")
                        UserDefaults.standard.set(firstName, forKey: "UserFirstName")
                        UserDefaults.standard.set(lastName, forKey: "UserLastName")
                        UserDefaults.standard.set(true, forKey: "IsLoggedIn")
                        
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
