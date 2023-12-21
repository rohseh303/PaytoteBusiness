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

import SwiftUI
import CoreData

/// ``HomeView``
/// is a View struct that displays the home page of the application. This homepage shows the user its receipts, the folders, the title bar (doubling as a search bar).
/// - Called by ContentView.
struct HomeView: View {
    @ObservedObject var viewModel = APILinksViewModel()
    ///``FetchRequest``: Creates a FetchRequest for the 'Receipt' CoreData entities. Contains a NSSortDescriptor that sorts and orders the receipts as specified by Date.
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Receipt.date, ascending: false)], animation: .spring())
    ///``receipts``: Takes and stores the requested Receipt entities in a FetchedResults variable of type Receipt. This variable is essentially an array of Receipt objects that the user has scanned.
    var receipts: FetchedResults<Receipt>
    ///``FetchRequest``: Creates a FetchRequest for the 'Folder' CoreData entities. Contains 2 NSSortDescriptor's that sorts and orders the folders as specified by title and receipt count.
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Folder.receiptCount, ascending: false),
                          NSSortDescriptor(keyPath: \Folder.title, ascending: true)], animation: .spring())
    ///``folders``: Takes and stores the requested Folder entities in a FetchedResults variable of type Folder. This variable is essentially an array of Folder objects relating to the receipts predicted folders.
    var folders: FetchedResults<Folder>
    ///``userSearch``: Filters the search results based on the users search input into the titlebar/search bar. This applies to every section of a receipt.
    @State var userSearch: String = ""
    ///``selectedFolder``: Filters the search results based on the users selected Folder, so that only receipts within the selected Folder are displayed.
    @State var selectedFolder: String = ""
    ///``colors``: Imports an array of tuples containing various colors that are used to style the UI. This is based on the UserSettings 'style' setting, and is an @State to update the UI.
    @State var colors = Color.colors
    ///``settings``: Imports the UserSettings environment object allowing unified usage and updating of the users settings across all classes.
    @EnvironmentObject var settings: UserSettings

    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack {
                HomeTitleBar(selectedFolder: $selectedFolder, userSearch: $userSearch)
                    .padding(.horizontal)
                    
                // FOLDERS
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(folders) { folder in
                            if selectedFolder != folder.title {
                                FolderView(folder: folder, selectedFolder: $selectedFolder)
                                    .transition(AnyTransition.opacity.combined(with: .scale(scale: 0.9)))
                                    .animation(.spring())
                                
                            }
                        }.padding(.vertical, 8)
                    }.padding(.horizontal)
                }
                
                // RECEIPTS
                ScrollView(showsIndicators: false) {
                    ScrollViewReader { value in
                        VStack {
                            if receipts.count > 0 {
                            
                                // If selectedFolder contains something, use it to show receipts in the folder.
                                // Else If userSearch contains something, use it to check for receipts.
                                    // Else show receipts that have any body text (all receipts).
                                ForEach(receipts.filter({ !selectedFolder.isEmpty ?
                                                            $0.folder!.localizedCaseInsensitiveContains("\(selectedFolder)") :
                                                          !userSearch.isEmpty ?
                                                            $0.body!.localizedCaseInsensitiveContains("\(userSearch)") ||
                                                            $0.folder!.localizedCaseInsensitiveContains("\(userSearch)")  ||
                                                            $0.title!.localizedCaseInsensitiveContains("\(userSearch)") :
                                                            $0.body!.count > 0 })){ receipt in
                                    ReceiptView(receipt: receipt)
                                        .transition(.opacity)
                                        .padding(.horizontal)
                                        .padding(.bottom, 8)
                                }
                                if receipts.count > 8 {
                                    Button(action: {
                                        withAnimation(.spring()){
                                            value.scrollTo(0, anchor: .top)
                                        }
                                    }){
                                        Image(systemName: "arrow.up.to.line")
                                            .opacity(0.5)
                                    }.buttonStyle(ShrinkingButton()).padding(.bottom)
                                }
                            } else {
                                NoReceiptsView()
                            }
                        }.padding(.top, 10).padding(.bottom).id(0)
                    }
                }.cornerRadius(0)
            }
            .onAppear {
                viewModel.fetchAPILinks() // Fetch receipts when the view appears
            }
        }
    }
}

/// ``NoReceiptsView``
/// is a View struct that displays when the user has added no receipts. Upon interaction it links the user to the scan tab.
/// - Called by HomeView.
struct NoReceiptsView: View {
    ///``selectedTab`` Controls the TabView's active tab it is viewing. In this case, it is used to switch the user's view to the scanning page.
    @EnvironmentObject var selectedTab: TabSelection
    /// ``settings``: Imports the UserSettings environment object allowing unified usage and updating of the users settings across all classes.
    @EnvironmentObject var settings: UserSettings
    
    var body: some View{
        Button(action: {
            selectedTab.changeTab(tabPage: .scan)
        }){
            Blur(effect: UIBlurEffect(style: .systemThinMaterial))
                .cornerRadius(18)
                .overlay(
                    // the title and body
                    HStack (alignment: .center){
                        VStack(alignment: .leading) {
                            Text("Add a receipt!")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                            Text("Tap the 'Scan' button at the bottom.")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                        }
                        Spacer()
                        Image(systemName: "doc.plaintext")
                    }.padding()
                ).frame(height: UIScreen.screenHeight * 0.08)
                .padding(.horizontal)
        }.buttonStyle(ShrinkingButton())
    }
}

/// ``HomeTitleBar``
/// is a View struct that functions similarily to ``TitleText``, to display the "Receipted." title, however it also doubles as a search bar which hooks into the userSearch variable to filter receipts.
/// - Called by HomeView.
struct HomeTitleBar: View {
    /// ``settings``: Imports the UserSettings environment object allowing unified usage and updating of the users settings across all classes.
    @EnvironmentObject var settings: UserSettings
    ///``selectedFolder``: Filters the search results based on the users selected Folder, so that only receipts within the selected Folder are displayed.
    @Binding var selectedFolder: String
    ///``userSearch``: Filters the search results based on the users search input into the titlebar/search bar. This applies to every section of a receipt.
    @Binding var userSearch: String
    /// ``colors``: Imports an array of tuples containing various colors that are used to style the UI. This is based on the UserSettings 'style' setting, and is an @State to update the UI.
    @State var colors = Color.colors
    var body: some View {
        HStack {
            HStack {
                if selectedFolder.isEmpty {
                    ZStack(alignment: .leading) {
                        if userSearch.isEmpty {
                            Text("Receipted.")
                                .font(.system(size: 40, weight: .semibold))
                                .foregroundColor(Color("text"))
                                .transition(AnyTransition.opacity.combined(with: .move(edge: .bottom)))
                        }
                        TextField("", text: $userSearch)
                            .animation(.easeInOut(duration: 0.3))
                            .accessibility(identifier: "SearchBar")
                    }
                    .transition(AnyTransition.opacity.combined(with: .move(edge: .bottom)))
                    .foregroundColor(Color(selectedFolder.isEmpty ? "text" : "background"))
                    .font(.system(size: 40, weight: .regular))
                } else {
                    HStack {
                        Image(systemName: Folder.getIcon(title: selectedFolder))
                            .font(.system(size: 30, weight: .semibold))
                        Text("\(selectedFolder).")
                            .font(.system(size: 40, weight: .semibold))
                            .lineLimit(2).minimumScaleFactor(0.8)
                    }
                    .foregroundColor(Color("background"))
                    .transition(AnyTransition.opacity.combined(with: .offset(y: -100)))
                }
                Spacer()
            }.padding(.bottom, 10).padding(.top, 20)
            .background(
                VStack {
                    if selectedFolder.isEmpty {
                        Spacer()
                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(Color(settings.accentColor))
                            .opacity(settings.accentColor == "UIContrast" ? 0.08 : 0.6)
                    }
                }.padding(.bottom, 14)
                .transition(AnyTransition.offset(y: 60).combined(with: .opacity))
                
            )
            Spacer()
            ZStack {
                if userSearch.isEmpty && selectedFolder.isEmpty {
                    Image(systemName: "magnifyingglass")
                        .transition(AnyTransition.scale(scale: 0.8).combined(with: .opacity))
                        .foregroundColor(Color(settings.accentColor))
                } else {
                    // make a down arrow
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)){
                            userSearch = ""
                            selectedFolder = ""
                        }
                        UIApplication.shared.endEditing()
                    }){
                        if !selectedFolder.isEmpty { // if selecting a folder
                            Image(systemName: "chevron.down")
                        } else if !userSearch.isEmpty { // if typing text
                            Image(systemName: "xmark")
                        }
                    }.buttonStyle(ShrinkingButtonSpring())
                }
            }
            .font(.system(size: 19, weight: .bold, design: .rounded))
            .foregroundColor(Color(selectedFolder.isEmpty ? "text" : "background"))
            .padding(.horizontal).frame(width: UIScreen.screenWidth * 0.16)
        }.background(
            ZStack{ // (folder's) drop in color block
                VStack {
                    if selectedFolder.isEmpty {
                        Rectangle()
                            .fill(Color.clear)
                    } else {
                        Rectangle()
                            .fill(Color(Folder.getColor(title: selectedFolder)))
                            .transition(AnyTransition.offset(y: -150).combined(with: .opacity))
                    }
                }
                .scaleEffect(x: 1.5)
                .animation(.easeOut(duration: 0.3))
                .ignoresSafeArea(edges: .top)
            }
        )
    }
}



//struct HomePage: View {
//
//    @State private var savedEmail = UserDefaults.standard.string(forKey: "UserEmail")
//    @State private var savedFirstName = UserDefaults.standard.string(forKey: "UserFirstName")
//    @State private var savedLastName = UserDefaults.standard.string(forKey: "UserLastName")
//    @State private var isLoggedIn = UserDefaults.standard.bool(forKey: "IsLoggedIn")
//    
//    @ObservedObject var viewModel = APILinksViewModel()
//    
//    var body: some View {
////        Text("Welcome, \(savedFirstName ?? "Guest"), to the future of your finances")
//        VStack {
//                    Text("Welcome, \(savedFirstName ?? "Guest"), to the future of your finances")
//                    
//                    VStack {
//                        Text("Fetched Receipts:")
//                            .padding(.top)
//                        
//                        List(viewModel.receipts, id: \.name) { receipt in
//                            NavigationLink(destination: fetchedReceiptDetailView(receipt: receipt)) {
//                                Text(receipt.name)
//                            }
//                        }
//                    }
//            }
//            .onAppear {
//                print("calling fetch api links")
//                viewModel.fetchAPILinks()
//                print("View appeared. Fetching receipts.")
//            }
//        }
//}
//
//#Preview {
//    HomePage()
//}

// Model to handle the API response
struct APIResponse: Decodable {
    let statusCode: Int
    let body: String
}

class APILinksViewModel: ObservableObject {
    @Published var receipts: [Receipt] = []
//    @Published var apiLinks: [String] = []
    @State var receipt: Receipt = Receipt()
    ///``invalidAlert`` is used to set whether the scan is valid or not. This links with the parent ScanView which actually displays the error.
    @State var invalidAlert: Bool = false
    ///``isConfirming`` is a bool used to control the confirmation screens sheet.
    @State var isConfirming: Bool = false
    ///``recognizedContent`` is an object that holds an array of ReceiptItems, holding the information about the scan performed by the user.
    @ObservedObject var recognizedContent: RecognizedContent  = RecognizedContent()

    func fetchAPILinks() {
        let apiURL = "https://su605qng12.execute-api.us-west-1.amazonaws.com/v2"
        guard let url = URL(string: apiURL) else {
            print("Invalid API URL.")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        //instead of passing in the email, we have to pass in the unique user identifier
        let requestBody: [String: Any] = ["email": UserDefaults.standard.string(forKey: "UserEmail") ?? "no email"]
        do {
            print("fetching list of receipts to get")
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

                        // Assuming `objectNames` are URLs to the images
                        for objectName in objectNames {
                            let imageURL = "https://aaku0fbfpe.execute-api.us-west-1.amazonaws.com/prod/receipts-global/\(objectName)"
                            self.fetchImage(from: imageURL, completion: { image in
                                DispatchQueue.main.async {
                                    if let image = image {
                                        print("got image now i am trying to put it thru the scanner")
//                                        let newReceipt = fetchedReceipt(name: objectName, image: image)
//                                        self.receipts.append(newReceipt)
                                        self.processImage(image)
                                    }
                                }
                            })
                        }
                        
                    }
                } catch {
                    print("Error decoding data: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
    
    private func processImage(_ image: UIImage) {
            // Process the image similar to the ImagePicker success case in GalleryScannerView
            let scanTranslation = ScanTranslation(scannedImages: [image], recognizedContent: recognizedContent) {
                if self.saveReceipt() {
                    // Perform actions upon successful save
                }
                // Additional handling if needed
            }.recognizeText()
        }
    
    /// ``saveReceipt``
    /// is a function that is used to save a RecognizedContent objects receipts. It is used in an if statement to determine whether there is actually translated text, and if its at an acceptable number.
    /// - Returns
    ///     - True if the scan is being saved, and passed the validity tests, False if the scan isn't able to be saved, and didn't pass the validity tests.
    func saveReceipt() -> Bool {
        print("recognizedContent.items: ", recognizedContent.items)
        let recognizedContentIn = recognizedContent.items[recognizedContent.items.count-1]
        if recognizedContentIn.text.count > 2 {
            receipt = Receipt.returnScan(recognizedText: recognizedContentIn.text, image: recognizedContentIn.image)
            return true
        } else {
            invalidAlert = true
            return false
        }
    }
    
    private func fetchImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }

            completion(UIImage(data: data))
        }.resume()
    }
}
