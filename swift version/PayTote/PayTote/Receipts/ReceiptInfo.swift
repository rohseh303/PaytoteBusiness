//
//  ReceiptInfo.swift
//  PayTote
//
//  Created by Rohan Sehgal on 12/17/23.
//

import Foundation
import SwiftUI

struct fetchedReceipt: Identifiable {
    var id = UUID() // Unique identifier for each receipt
    var name: String
    var imageURL: String
}

struct fetchedReceiptDetailView: View {
    var receipt: fetchedReceipt

    var body: some View {
        GeometryReader { geometry in
            VStack {
                if let url = URL(string: receipt.imageURL) {
                    AsyncImage(url: url)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .scaledToFit()
                } else {
                    Text("Unable to load image")
                }
            }.navigationBarTitle(receipt.name, displayMode: .inline)
        }
    }
}
