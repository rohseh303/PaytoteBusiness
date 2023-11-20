//
//  ContentView.swift
//  PayTote
//
//  Created by Rohan Sehgal on 11/19/23.
//

import SwiftUI

struct ContentView: View {
    @State var isLoggedIn = false
    
    var body: some View {
        if isLoggedIn {
            HomePage()
        }
        else {
            CreateAccount(loginStatus: $isLoggedIn)
        }
    }
}

#Preview {
    ContentView()
}
