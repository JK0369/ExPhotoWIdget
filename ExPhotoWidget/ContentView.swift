//
//  ContentView.swift
//  ExPhotoWidget
//
//  Created by 김종권 on 2022/09/25.
//

import SwiftUI

struct ContentView: View {
  var body: some View {
    Text("Hello, world!")
      .padding()
      .onAppear {
        print("등장")
        getPhoto { image, string in
          print("여기", string)
          print(image)
        }
      }
  }
  
  private func getPhoto(completion: @escaping (UIImage, String) -> ()) {
    guard
      let url = URL(string: "https://api.flickr.com/services/feeds/photos_public.gne?tags=texas&tagmode=any&format=json&nojsoncallback=1")
    else { return }
    URLSession.shared.dataTask(with: url) { data, response, error in
      guard
        let data = data,
        let photoModel = try? JSONDecoder().decode(PhotoModel.self, from: data),
        let urlString = photoModel.url
      else { return }
      
      if let uiImage = ImageCache.shared.object(forKey: urlString as NSString) {
        completion(uiImage, urlString)
      } else {
        guard
          let url = URL(string: urlString),
          let data = try? Data(contentsOf: url),
          let uiImage = UIImage(data: data)
        else { return }
        ImageCache.shared.setObject(uiImage, forKey: urlString as NSString)
        completion(uiImage, urlString)
      }
    }.resume()
  }

}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
