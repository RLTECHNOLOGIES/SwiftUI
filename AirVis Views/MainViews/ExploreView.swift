//
//  ExploreView.swift
//  AirVis
//
//  Created by Arun Kurian on 11/11/24.
//

import SwiftUI

struct ExploreView: View {
    @EnvironmentObject var appModel: AppModel
    @State var isPresented: Bool = false
    var body: some View {
                TrendingView(isPresented: $isPresented).environmentObject(appModel)
    }
}

#Preview {
    ExploreView()
}

