//
//  ReceiptInfo.swift
//  PayTote
//
//  Created by Rohan Sehgal on 12/17/23.
//

import Foundation
import SwiftUI
import Combine

struct fetchedReceipt: Identifiable {
    var id = UUID()
    var name: String
    var image: UIImage
}

struct fetchedReceiptDetailView: View {
    var receipt: fetchedReceipt

    var body: some View {
        VStack {
            Image(uiImage: receipt.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
        .navigationBarTitle(receipt.name, displayMode: .inline)
    }
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
                //should probably create Receipt/or no scanTranslation here to get it into core databse and everything
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                ProgressView() // Spinner until image loads
            }
        }
    }
}
