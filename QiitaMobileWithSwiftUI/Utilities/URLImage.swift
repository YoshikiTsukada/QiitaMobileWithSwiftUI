//
//  URLImage.swift
//  QiitaMobileWithSwiftUI
//
//  Created by Yoshiki Tsukada on 2020/05/07.
//

import SwiftUI

struct URLImage: View {
    let url: URL
    @ObservedObject private var imageDownloader = ImageDownloader()

    init(url: URL) {
        self.url = url
        self.imageDownloader.downloadImage(url: self.url)
    }

    var body: some View {
        if let imageData = self.imageDownloader.downloadData {
            let img = UIImage(data: imageData)
            return VStack {
                Image(uiImage: img!).resizable()
            }
        } else {
            return VStack {
                Image(uiImage: UIImage(systemName: "icloud.and.arrow.down")!).resizable()
            }
        }
    }
}

class ImageDownloader : ObservableObject {
    @Published var downloadData: Data? = nil

    func downloadImage(url: URL) {
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url)
            DispatchQueue.main.async {
                self.downloadData = data
            }
        }
    }
}
