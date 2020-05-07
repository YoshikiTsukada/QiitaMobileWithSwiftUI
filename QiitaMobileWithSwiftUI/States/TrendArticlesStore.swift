//
//  TrendArticlesStore.swift
//  QiitaMobileWithSwiftUI
//
//  Created by Yoshiki Tsukada on 2020/05/07.
//

import SwiftUI

class TrendArticlesStore: ObservableObject {
    @Published var dailyTrends: [TrendArticle] = []
}
