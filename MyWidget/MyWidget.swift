//
//  MyWidget.swift
//  MyWidget
//
//  Created by 김종권 on 2022/09/25.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
  func placeholder(in context: Context) -> SimpleEntry {
    SimpleEntry(date: Date(), uiImage: UIImage(), url: "")
  }
  
  func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
    getPhoto { uiImage, url in
      let entry = SimpleEntry(date: Date(), uiImage: uiImage, url: url)
      completion(entry)
    }
  }
  
  func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
    getPhoto { uiImage, url in
      let currentDate = Date()
      let entry = SimpleEntry(date: currentDate, uiImage: uiImage, url: url)
      let nextRefresh = Calendar.current.date(byAdding: .minute, value: 3, to: currentDate)!
      let timeline = Timeline(entries: [entry], policy: .after(nextRefresh))
      completion(timeline)
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

struct SimpleEntry: TimelineEntry {
  let date: Date
  let uiImage: UIImage
  let url: String
}

struct MyWidgetEntryView : View {
  var entry: Provider.Entry
  
  var body: some View {
    Image(uiImage: entry.uiImage)
      .resizable()
      .aspectRatio(contentMode: .fill)
      .widgetURL(URL(string: getPercentEcododedString("widget://deeplink?url=\(entry.url)")))
  }
  
  private func getPercentEcododedString(_ string: String) -> String {
    string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
  }
}

@main
struct MyWidget: Widget {
  let kind: String = "MyWidget"
  
  var body: some WidgetConfiguration {
    IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
      MyWidgetEntryView(entry: entry)
    }
    .configurationDisplayName("위젯 예제")
    .description("이미지를 불러오는 위젯 예제입니다")
  }
}
