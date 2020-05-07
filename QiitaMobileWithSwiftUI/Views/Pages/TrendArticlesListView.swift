//
//  TrendArticlesListView.swift
//  QiitaMobileWithSwiftUI
//
//  Created by Yoshiki Tsukada on 2020/05/07.
//  Copyright © 2020 Yoshiki Tsukada. All rights reserved.
//

import SwiftUI

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
