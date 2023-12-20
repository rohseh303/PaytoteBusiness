//
//  HomePage.swift
//  PayTote
//
//  Created by Rohan Sehgal on 11/19/23.
//

import SwiftUI
//import CoreData
import Combine
//import Foundation

struct HomePage: View {
    
    @State private var savedEmail = UserDefaults.standard.string(forKey: "UserEmail")
    @State private var savedFirstName = UserDefaults.standard.string(forKey: "UserFirstName")
    @State private var savedLastName = UserDefaults.standard.string(forKey: "UserLastName")
    @State private var isLoggedIn = UserDefaults.standard.bool(forKey: "IsLoggedIn")
    
    @ObservedObject var viewModel = APILinksViewModel()
    
    var body: some View {
        Text("Welcome, \(savedFirstName ?? "Guest"), to the future of your finances")
        
        VStack {
            Text("Fetched Receipts:")
                .padding(.top)
            
            ScrollView {
                VStack {
                    ForEach(viewModel.apiLinks, id: \.self) { link in
                        if let url = URL(string: link) {
                            AsyncImage(url: url)
                                .frame(width: 300, height: 300)
                                .padding(.bottom)
                        }
                    }
                }
            }
        }.onAppear(perform: viewModel.fetchAPILinks)
    }
}

#Preview {
    HomePage()
}

class ImageLoader: ObservableObject {
    @Published var imageData = Data()
    var cancellables = Set<AnyCancellable>()
    
    func fetchImage(url: URL) {
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .replaceError(with: Data())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.imageData = $0 }
            .store(in: &cancellables)
    }
}

// Custom Image view to load images from data
struct AsyncImage: View {
    @ObservedObject private var loader: ImageLoader
    
    init(url: URL) {
        loader = ImageLoader()
        loader.fetchImage(url: url)
    }
    
    var body: some View {
        Group {
            if let image = UIImage(data: loader.imageData) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                ProgressView() // Spinner until image loads
            }
        }
    }
}

// Model to handle the API response
struct APIResponse: Decodable {
    let statusCode: Int
    let body: String
}

class APILinksViewModel: ObservableObject {
    @Published var apiLinks: [String] = []

    func fetchAPILinks() {
        let apiURL = "https://su605qng12.execute-api.us-west-1.amazonaws.com/v2"
        guard let url = URL(string: apiURL) else {
            print("Invalid API URL.")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: Any] = ["email": UserDefaults.standard.string(forKey: "UserEmail") ?? "no email"]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            print("Error encoding request body: \(error.localizedDescription)")
            return
        }

        URLSession.shared.dataTask(with: request) { (data, response, error) in  // Updated to use 'request'
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            if let data = data, let jsonString = String(data: data, encoding: .utf8) {
                print("JSON String: \(jsonString)")  // Print raw JSON response

                do {
                    let apiResponse = try JSONDecoder().decode(APIResponse.self, from: data)

                    if let bodyData = apiResponse.body.data(using: .utf8) {
                        let objectNames = try JSONDecoder().decode([String].self, from: bodyData)

                        DispatchQueue.main.async {
                            self.apiLinks = objectNames.map { objectName in
                                let imageURL = "https://aaku0fbfpe.execute-api.us-west-1.amazonaws.com/prod/receipts-global/\(objectName)"
                                print("Image URL: \(imageURL)")
                                return imageURL
                            }
                        }
                    }
                } catch {
                    print("Error decoding data: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
}
