//
//  TrendArticlesListView.swift
//  QiitaMobileWithSwiftUI
//
//  Created by Yoshiki Tsukada on 2020/05/07.
//  Copyright © 2020 Yoshiki Tsukada. All rights reserved.
//

import SwiftUI
import Hydra
import SwiftyJSON

struct TrendArticlesListView: View {
    @ObservedObject private var store: TrendArticlesStore
    
    init() {
        store = TrendArticlesStore()
        GetTrendArticles().execute(in: .background).then(in: .main) { [store] articles in
            store.dailyTrends = articles
        }
    }

    var body: some View {
        NavigationView {
            List(store.dailyTrends) { article in
                ArticleRowView(article: article)
            }
            .navigationBarTitle("トレンド")
        }
    }
}

struct TrendArticlesListView_Previews: PreviewProvider {
    static var previews: some View {
        TrendArticlesListView()
    }
}

class TrendArticlesStore: ObservableObject {
    @Published var dailyTrends: [TrendArticle] = []
}

public final class TrendArticle: Identifiable {
    public let id: String
    public var title: String
//    public var createdAt: DateInRegion
    public var likesCount: Int
    public var isNew: Bool
    public var hasCodeBlock: Bool
    public var authorId: String
    public var authorImageUrl: URL

    public init?(_ json: JSON) {
        guard
            let id = json["node"]["uuid"].string,
            let title = json["node"]["title"].string,
//            let createdAt = DateInRegion(json["node"]["createdAt"].stringValue),
            let likesCount = json["node"]["likesCount"].int,
            let isNew = json["isNewArrival"].bool,
            let hasCodeBlock = json["hasCodeBlock"].bool,
            let authorId = json["node"]["author"]["urlName"].string,
            let authorImageUrl = URL(string: json["node"]["author"]["profileImageUrl"].stringValue)
        else { return nil }

        self.id = id
        self.title = title
//        self.createdAt = createdAt
        self.likesCount = likesCount
        self.isNew = isNew
        self.hasCodeBlock = hasCodeBlock
        self.authorId = authorId
        self.authorImageUrl = authorImageUrl
    }

    public static func load(_ list: [JSON]) -> [TrendArticle] {
        return list.compactMap { TrendArticle($0) }
    }
}

public class GetTrendArticles: PromiseOperation<[TrendArticle]> {
    public init(type: String = "") {
        super.init()

        request = Request(
            trendEndpoint: "/daily",
            method: .get
        )

        jsonResponse = { json in
            TrendArticle.load(json.arrayValue)
        }
    }
}

public class PromiseOperation<Output> {
    public var request: Request?

    public var jsonResponse: ((JSON) -> Output)?

    public init() {
        jsonResponse = { _ in
            fatalError("Must implement `jsonResponse` in PromiseOperation subclass.")
        }
    }

    public func execute(in context: Context) -> Promise<Output> {
        return .init(in: context) { resolve, reject, _ in
            guard let request = self.request?.urlRequest else {
                // TODO: エラーを定義する
                fatalError("The variable `request` has no velue.")
            }

            URLSession.shared.dataTask(with: request) { data, _, error in
                if let error = error {
                    reject(error)
                } else if let data = data {
                    let json = JSON(data)
                    let object = self.jsonResponse!(json)
                    resolve(object)
                }
            }.resume()
        }
    }
}

public typealias ParameterDictionary = [String: Any]

public class Request {
    public static let baseUrl: String = "https://qiita.com/api/v2"
    public let urlRequest: URLRequest

    public init(url: URL, method: RequestMethod, parameters: ParameterDictionary) {
        urlRequest = Request.asUrlRequest(url: url, method: method, parameters: parameters)
    }

    public convenience init(endpoint: String, method: RequestMethod, parameters: ParameterDictionary = [:]) {
        let url = URL(string: "\(Request.baseUrl)\(endpoint)")!
        self.init(url: url, method: method, parameters: parameters)
    }

    public convenience init(trendEndpoint: String, method: RequestMethod, parameters: ParameterDictionary = [:]) {
        let url = URL(string: "https://qiita-api.netlify.com/.netlify/functions/trend")!
        self.init(url: url, method: method, parameters: parameters)
    }

    public static func asUrlRequest(url: URL, method: RequestMethod, parameters: ParameterDictionary) -> URLRequest {
        RequestConvertible.convert(url: url, method: method, parameters: parameters)
    }
}

public class RequestConvertible {
    public static func convert(url: URL, method: RequestMethod, parameters: ParameterDictionary) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if !parameters.isEmpty {
            do {
                let data = try JSONSerialization.data(withJSONObject: parameters)
                request.httpBody = data
            } catch {
                print(error)
            }
        }

        return request
    }
}

public enum RequestMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

struct ArticleRowView: View {
    private let article: TrendArticle
    
    init(article: TrendArticle) {
        self.article = article
    }

    var body: some View {
        HStack(alignment: .top) {
            URLImage(url: article.authorImageUrl)
                .frame(width: 60, height: 60)
                .cornerRadius(5)
            VStack(alignment: .leading, spacing: 10) {
                Text(article.title)
                    .font(.system(size: 18, weight: .semibold))
                    .lineLimit(3)
                HStack(spacing: 10) {
                    if article.isNew {
                        ZStack {
                             Color(#colorLiteral(red: 0.3333333333, green: 0.7725490196, blue: 0, alpha: 1))
                                 .edgesIgnoringSafeArea(.all)
                             Text("new")
                                 .foregroundColor(.white)
                         }
                        .frame(width: 40, height: 20)
                        .cornerRadius(3)
                    }
                    Text("@\(article.authorId)")
                        .foregroundColor(.init(UIColor.lightGray))
                    Text("LGTM")
                        .fontWeight(.semibold)
                        .foregroundColor(.init(UIColor.lightGray))
                    Text(String(describing: article.likesCount))
                        .foregroundColor(.init(UIColor.lightGray))
                }
            }
        }
        .padding(.init(top: 5, leading: 0, bottom: 5, trailing: 0))
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
