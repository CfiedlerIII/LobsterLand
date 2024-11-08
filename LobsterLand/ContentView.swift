//
//  ContentView.swift
//  LobsterLand
//
//  Created by Charles Fiedler on 11/8/24.
//

import SwiftUI
import ArcGIS

struct ContentView: View {

  @State private var map = {
    let map = Map(basemapStyle: .arcGISTopographic)
    map.initialViewpoint = Viewpoint(latitude: 34.02700, longitude: -118.80500, scale: 72_000)
    return map
  }()

  var body: some View {
    VStack {
      MapView(map: map)
        .ignoresSafeArea()
    }
  }
}

#Preview {
  ContentView()
}
