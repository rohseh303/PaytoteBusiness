//
//  Settings.swift
//  COSC345-Project
//
//  Created by Hunter Kingsbeer on 7/09/21.
//

import CoreData
import SwiftUI
import MessageUI

/// ``SettingsView``
/// is a View struct that imports the UserSettings and displays a range of toggles/buttons/pickers that alter the UserSettings upon user action.
/// The view is made up of a ZStack allowing the BackgroundView to be placed behind a VStack containing the title view (which says "Settings" with a hammer icon) and various settings to change.
/// - Called by ContentView.
struct SettingsView: View  {
    ///``settings``: Imports the UserSettings environment object allowing unified usage and updating of the users settings across all classes.
    @EnvironmentObject var settings: UserSettings

    @State private var isShowingMailView = false
    @State private var result: Result<MFMailComposeResult, Error>? = nil
   
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack {
                TitleText(buttonBool: $settings.devMode, title: "settings", icon: "gearshape.fill")
                    .padding(.horizontal)
                
                ScrollView(showsIndicators: false){
                    VStack {
                        HStack {
                            //dark mode
                            DarkModeButton()
                                .frame(height: UIScreen.screenHeight * 0.2)
                        }
                        
                        // scan selector
                        ScanDefaultSelector()
                            .frame(height: UIScreen.screenHeight * 0.2)
                        
                        // color
//                        AccentColorSelector()
//                            .frame(height: UIScreen.screenHeight * 0.2)
                        if MFMailComposeViewController.canSendMail() {
                                        Button("Send Email") {
                                            self.isShowingMailView = true
                                        }
                                        .sheet(isPresented: $isShowingMailView) {
                                            MailView(isShowing: self.$isShowingMailView, result: self.$result, recipients: ["example@example.com"], subject: "Store Integration Request", body: "Here is an example email body.")
                                        }
                                    } else {
                                        ContactUsView()
                                            .frame(height: UIScreen.screenHeight * 0.2)
                                        // Optionally provide alternative contact methods here
                                    }
                    }.padding(.horizontal).padding(.bottom)
                    
//                    if settings.devMode {
//                        DeveloperSettings()
//                    }
                }.animation(.easeInOut)
            }
        }
    }
}

/// ``DarkModeButton``
/// is a View struct that updates the UI color scheme. Either dark or light.
/// - Called by SettingsView.
struct DarkModeButton: View {
    ///``settings``: Imports the UserSettings environment object allowing unified usage and updating of the users settings across all classes.
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut){
                settings.darkMode.toggle()
            }
            hapticFeedback(type: .rigid)
        }){
            Blur(effect: UIBlurEffect(style: .systemThinMaterial))
                .opacity(0.9)
                .cornerRadius(12)
                .overlay(
                    VStack {
                        Spacer()
                        if settings.darkMode {
                            Image(systemName: "moon.fill")
                                .font(.largeTitle)
                                .foregroundColor(Color(settings.accentColor))
                                .transition(AnyTransition.scale(scale: 0.5).combined(with: .opacity))
                        } else {
                            Image(systemName: "sun.max.fill")
                                .font(.largeTitle)
                                .transition(AnyTransition.scale(scale: 0.5).combined(with: .opacity))
                                
                        }
                        Spacer()
                        Text("\(settings.darkMode ? "DARK" : "LIGHT") MODE")
                            .bold()
                            .font(.system(.body, design: .rounded))
                        Spacer()
                    }.padding()
                )
        }.buttonStyle(ShrinkingButton()).padding(.vertical).padding(.trailing, 5)
    }
}

/// ``ScanDefaultSelector``
/// is a View struct that controls the default scanner option. This is either the camera, gallery or the option of both.
/// - Called by SettingsView.
struct ScanDefaultSelector: View {
    ///``settings``: Imports the UserSettings environment object allowing unified usage and updating of the users settings across all classes.
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        Blur(effect: UIBlurEffect(style: .systemThinMaterial))
            .opacity(0.9)
            .cornerRadius(12)
            .overlay(
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack {
                            Button(action: {
                                withAnimation(.easeInOut){
                                    settings.scanDefault = ScanDefault.camera.rawValue
                                }
                                hapticFeedback(type: .rigid)
                            }){
                                Image(systemName: "camera")
                                    .font(.largeTitle)
                                    .foregroundColor(Color(ScanDefault.camera.rawValue == settings.scanDefault ? settings.accentColor : "accentAlt"))
                                    .scaleEffect(ScanDefault.camera.rawValue == settings.scanDefault ? 1.25 : 1)
                                    .transition(AnyTransition.scale(scale: 0.25)
                                                    .combined(with: .opacity))
                                    .padding()
                            }.buttonStyle(ShrinkingButton())
                        }
                        
                        Spacer()
                        VStack {
                            Button(action: {
                                withAnimation(.easeInOut){
                                    settings.scanDefault = ScanDefault.choose.rawValue
                                }
                                hapticFeedback(type: .rigid)
                            }){
                                Image(systemName: "plus")
                                    .font(.largeTitle)
                                    .foregroundColor(Color(ScanDefault.choose.rawValue == settings.scanDefault ? settings.accentColor : "accentAlt"))
                                    .scaleEffect(ScanDefault.choose.rawValue == settings.scanDefault ? 1.25 : 1)
                                    .transition(AnyTransition.scale(scale: 0.25)
                                                    .combined(with: .opacity))
                                    .padding()
                            }.buttonStyle(ShrinkingButton())
                        }
                        
                        Spacer()
                        VStack {
                            Button(action: {
                                withAnimation(.easeInOut){
                                    settings.scanDefault = ScanDefault.gallery.rawValue
                                }
                                hapticFeedback(type: .rigid)
                            }){
                                VStack {
                                    Image(systemName: "photo")
                                        .font(.largeTitle)
                                        .foregroundColor(Color(ScanDefault.gallery.rawValue == settings.scanDefault ? settings.accentColor : "accentAlt"))
                                        .scaleEffect(ScanDefault.gallery.rawValue == settings.scanDefault ? 1.25 : 1)
                                        .transition(AnyTransition.scale(scale: 0.25)
                                                        .combined(with: .opacity))
                                        .padding()
                                }
                            }.buttonStyle(ShrinkingButton())
                        }
                        Spacer()
                    }
                    Text("DEFAULT SCANNER: \(settings.scanDefault == ScanDefault.camera.rawValue ? "CAMERA" : settings.scanDefault == ScanDefault.gallery.rawValue ? "GALLERY" : "EITHER")")
                        .bold()
                        .font(.system(.body, design: .rounded))
                    Spacer()
                }.padding()
            ).padding(.bottom)
    }
}

/// ``AccentColorSelector``
/// is a View struct that controls the accent color of the app. This is takes the UI colors and presents them for selection.
/// - Called by SettingsView.
struct AccentColorSelector: View {
    ///``colors`` Imports an array of tuples containing various colors that are used to style the UI. This is based on the UserSettings 'style' setting, and is an @State to update the UI.
    @State var colors = Color.colors
    ///``settings``: Imports the UserSettings environment object allowing unified usage and updating of the users settings across all classes.
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        Blur(effect: UIBlurEffect(style: .systemThinMaterial))
            .opacity(0.9)
            .cornerRadius(12)
            .overlay(
                VStack {
                    Spacer()
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(0..<colors.count){ color in
                                Button(action: {
                                    withAnimation(.easeInOut){
                                        settings.accentColor = colors[color]
                                    }
                                    hapticFeedback(type: .soft)
                                }){
                                    VStack {
                                        if color == 0 {
                                            Image(systemName: "circle.righthalf.fill")
                                                        .font(.largeTitle).scaleEffect(1.1)
                                                .foregroundColor(Color("text"))
                                                .overlay(
                                                    VStack {
                                                        if settings.accentColor == colors[color]{
                                                            Image(systemName: "circle.fill")
                                                                .font(.system(size: 18, weight: .bold))
                                                                .foregroundColor(Color("accent"))
                                                                .transition(AnyTransition.scale(scale: 0.25).combined(with: .opacity))
                                                        }
                                                    }
                                                )
                                                .padding(.horizontal, 5)
                                                .scaleEffect(settings.accentColor == colors[color] ? 1.25 : 1)
                                                .animation(.spring())
                                        } else {
                                            Circle()
                                                .foregroundColor(Color(colors[color]))
                                                .overlay(
                                                    VStack {
                                                        if settings.accentColor == colors[color]{
                                                            Image(systemName: "circle.fill")
                                                                .font(.system(size: 18, weight: .bold))
                                                                .foregroundColor(Color("accent"))
                                                                .transition(AnyTransition.scale(scale: 0.25).combined(with: .opacity))
                                                        }
                                                    }
                                                ).frame(width: UIScreen.screenWidth*0.1, height: UIScreen.screenWidth*0.1)
                                                .padding(.horizontal, 5)
                                                .scaleEffect(settings.accentColor == colors[color] ? 1.25 : 1)
                                                .animation(.spring())
                                        }
                                    }.overlay(Image(""))
                                }.buttonStyle(ShrinkingButton())
                            }
                        }.frame(height: UIScreen.screenWidth*0.2)
                        .padding(.horizontal, 20)
                    }
                    Spacer()
                    Text("ACCENT COLOR")
                        .bold()
                        .font(.system(.body, design: .rounded))
                    Spacer()
                }.padding(.vertical)
            ).padding(.bottom)
    }
}

struct DeveloperSettings: View {
    ///``FetchRequest``: Creates a FetchRequest for the 'Receipt' CoreData entities. Contains a NSSortDescriptor that sorts and orders the receipts as specified by Date.
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Receipt.date, ascending: false)], animation: .spring())
    ///``receipts``: Takes and stores the requested Receipt entities in a FetchedResults variable of type Receipt. This variable is essentially an array of Receipt objects that the user has scanned.
    var receipts: FetchedResults<Receipt>
    ///``settings``: Imports the UserSettings environment object allowing unified usage and updating of the users settings across all classes.
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                Image(systemName: "aqi.medium")
                Image(systemName: "hammer.fill")
                //Image(systemName: "gyroscope")
                Image(systemName: "cloud.moon.bolt")
                Image(systemName: "lightbulb")
                //Image(systemName: "move.3d")
                //Image(systemName: "perspective")
                Spacer()
            }.padding()
            Text("\(receipts.count) receipts.")
                .font(.body)
            HStack {
                Button(action: {
                    if isTesting(){
                        Receipt.generateKnownReceipts()
                    } else {
                        Receipt.generateRandomReceipts()
                    }
                    hapticFeedback(type: .rigid)
                }){
                    Blur(effect: UIBlurEffect(style: .systemThinMaterial))
                        .opacity(0.9)
                        .cornerRadius(12)
                        .overlay(
                            VStack {
                                Spacer()
                                Image(systemName: "doc.badge.plus")
                                    .font(.largeTitle)
                                    .padding(2)
                                Text("+10 RECEIPTS")
                                    .bold()
                                    .font(.system(.body, design: .rounded))
                                Spacer()
                            }.padding()
                        )
                }.buttonStyle(ShrinkingButton())
                .padding(.trailing, 5)
                
                Button(action: {
                    Receipt.deleteAll(receipts: receipts)
                    Folder.deleteAll()
                    hapticFeedback(type: .rigid)
                }){
                    Blur(effect: UIBlurEffect(style: .systemThinMaterial))
                        .opacity(0.9)
                        .cornerRadius(12)
                        .overlay(
                            VStack {
                                Spacer()
                                Image(systemName: "trash")
                                    .font(.largeTitle)
                                    .padding(2)
                                Text("DELETE ALL")
                                    .bold()
                                    .font(.system(.body, design: .rounded))
                                Spacer()
                            }.padding()
                        )
                }.buttonStyle(ShrinkingButton())
                .padding(.leading, 5)
            }.frame(height: UIScreen.screenHeight * 0.15)
        }.animation(.spring()).transition(AnyTransition.move(edge: .bottom))
        .padding(.horizontal).padding(.bottom, 20)
    }
}

struct MailView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentation
    @Binding var isShowing: Bool
    @Binding var result: Result<MFMailComposeResult, Error>?
    var recipients: [String]
    var subject: String
    var body: String

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var isShowing: Bool
        @Binding var result: Result<MFMailComposeResult, Error>?

        init(isShowing: Binding<Bool>, result: Binding<Result<MFMailComposeResult, Error>?>) {
            _isShowing = isShowing
            _result = result
        }

        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            defer {
                isShowing = false
            }
            if let error = error {
                self.result = .failure(error)
                return
            }
            self.result = .success(result)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(isShowing: $isShowing, result: $result)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setToRecipients(recipients)
        vc.setSubject(subject)
        vc.setMessageBody(body, isHTML: false)
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: UIViewControllerRepresentableContext<MailView>) {
    }
}

// ContactUsButton View
struct ContactUsView: View {
    var body: some View {
        Blur(effect: UIBlurEffect(style: .systemThinMaterial))
            .opacity(0.9)
            .cornerRadius(12)
            .overlay(
                VStack {
                    Spacer().frame(height: 20) // Add some space at the top
                    Text("For any inquiries, please contact us:")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        // Handle action for contacting
                    }) {
                        HStack {
                            Image(systemName: "envelope")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 20)
                                .foregroundColor(.blue)
                            Text("paytoteforbusiness@gmail.com")
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .foregroundColor(.primary)
                    
                    Button(action: {
                        // Handle action for opening website
                    }) {
                        HStack {
                            Image(systemName: "network")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 20)
                                .foregroundColor(.blue)
                            Text("www.example.com")
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .foregroundColor(.primary)
                    
                    Spacer() // Push everything to the top
                }
//                .padding()
//                .background(Color.white)
//                .cornerRadius(15)
//                .shadow(radius: 5)
//                .padding()
        )
    }
}

