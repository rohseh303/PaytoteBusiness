//
//  ContentView.swift
//  PayTote
//
//  Created by Rohan Sehgal on 11/19/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State var isLoggedIn = UserDefaults.standard.bool(forKey: "IsLoggedIn")
    
    @EnvironmentObject var selectedTab: TabSelection
    
    var body: some View {
        if isLoggedIn {
//            NavigationView {
//                HomePage()
//            }
            TabView(selection: $selectedTab.selection){
//                NavigationView{
//                    HomePage()
//                }
                HomeView()
                    .tabItem { Label("Home", systemImage: "house") }
                    .tag(0)
                ScanView()
                    .tabItem { Label("Scan", systemImage: "plus") }
                    .tag(1)
                SettingsView()
                    .tabItem { Label("Settings", systemImage: "gearshape.fill").foregroundColor(Color("text")) }
                    .tag(2)
            }//.onAppear(perform: { locked = settings.passcodeProtection }) // passcode protection if settings enabled
//            .fullScreenCover(isPresented: $locked, content: {
//                PasscodeScreen(locked: $locked)
//                    .environmentObject(UserSettings())
//                    .preferredColorScheme(settings.darkMode ? .dark : .light) // weirdly needs this
//            })
//            .accentColor(Color(settings.accentColor))
//            .preferredColorScheme(settings.darkMode ? .dark : .light)
        }
        else {
            CreateAccount(loginStatus: $isLoggedIn)
        }
    }
}

#Preview {
    ContentView()
}

/// ``BackgroundView``
/// is a View struct that holds the background that we see in all the tabs of the app. Usually this is placed in a ZStack behind the specific pages objects.
/// Consists of a Color with value "background", which automatically updates to be white when in light mode, and almost black in dark mode.
/// - Called by HomeView, ScanView, and SettingsView.
struct BackgroundView: View {
    /// A simple color, which allows for the background of the app to be changed app wide.
    var body: some View {
        Color("background")
            .ignoresSafeArea(.all)
            .animation(.easeInOut)
    }
}

/// ``TitleText``
/// is a View struct that displays the pages respective title text along with the icon. These are specified in the title and icon parameters.
/// - Called by HomeView, ScanView, and SettingsView.
/// - Parameters
///     - ``title``: String
///     - ``icon``: String
struct TitleText: View {
    @Binding var buttonBool: Bool
    /// ``settings`` Imports the UserSettings environment object allowing unified usage and updating of the users settings across all classes.
    @EnvironmentObject var settings: UserSettings
    /// ``colors`` Imports an array of tuples containing various colors that are used to style the UI. This is based on the UserSettings 'style' setting, and is an @State to update the UI.
    @State var colors = Color.colors
    /// ``title`` is a String that is used to set the titles text.
    let title: String
    ///``icon`` is a String that is used to set the titles icon.
    let icon: String
    
    /// The title that is seen in all tabs.
    var body: some View {
        HStack {
            HStack {
                Text("\(title.capitalized)")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundColor(Color("text"))
                    .transition(AnyTransition.opacity.combined(with: .move(edge: .bottom)))
                    .padding(.bottom, 10).padding(.top, 20)
                Spacer()
            }.background(
                ZStack {
                    Rectangle()
                        .fill(Color.clear)
                        .scaleEffect(x: 1.5)
                        .animation(.easeOut(duration: 0.3))
                        .ignoresSafeArea(edges: .top)
                    VStack {
                        Spacer()
                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(Color(settings.accentColor))
                            .opacity(settings.accentColor == "UIContrast" ? 0.08 : 0.6)
                    }.padding(.bottom, 14)
                    .transition(AnyTransition.opacity.combined(with: .move(edge: .bottom)))
                })
            Spacer()
            Button(action: {
                withAnimation(.spring()){
                    buttonBool.toggle()
                }
            }){
                Image(systemName: icon)
                    .font(.system(size: 19, weight: .bold, design: .rounded))
                    .foregroundColor(Color(settings.accentColor))
                    .padding(.horizontal)
            }.buttonStyle(ShrinkingButton())
            .frame(width: UIScreen.screenWidth * 0.16)
        }
    }
}
