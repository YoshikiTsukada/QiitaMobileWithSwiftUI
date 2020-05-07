//
//  ArticleRowView.swift
//  QiitaMobileWithSwiftUI
//
//  Created by Yoshiki Tsukada on 2020/05/07.
//

import SwiftUI
import SwiftyJSON

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

struct ArticleRowView_Previews: PreviewProvider {
    static var previews: some View {
        ArticleRowView(article: TrendArticle(
            JSON(parseJSON: """
                {
                    "isNewArrival":true,
                    "hasCodeBlock":false,
                    "node":{
                        "createdAt":"2020-05-05T23:45:28Z",
                        "likesCount":862,
                        "title":"GoでTCPとUDPのデータの扱い方を比較してみた",
                        "uuid":"b089a3f2e6dbc59cd5c8",
                        "author":{
                            "profileImageUrl":"https://qiita-user-profile-images.imgix.net/https%3A%2F%2Fqiita-image-store.s3.amazonaws.com%2F0%2F254486%2Fprofile-images%2F1540910033?ixlib=rb-1.2.2&auto=compress%2Cformat&lossless=0&w=75&s=b17ce3114b1fe1ade18669e5c3c7e8a1",
                            "urlName":"shirakiyo"
                        }
                    }
                }
            """)
        )!)
    }
}
