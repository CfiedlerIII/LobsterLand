//
//  MaineExplorerRowViewModel.swift
//  LobsterLand
//
//  Created by Charles Fiedler on 11/18/24.
//

import SwiftUI
import ArcGIS

class MaineExplorerRowViewModel: ExplorerViewModelable, ObservableObject {
  var mapItem: Item?
  @Published var map: Map?
  @Published var title: String?
  @Published var description: String?
  @Published var thumbnailURL: URL?

  init(map : Map? = nil, mapItem: Item?) {
    self.map = map
    self.mapItem = mapItem
    self.title = mapItem?.title
    self.description = mapItem?.snippet
    self.thumbnailURL = mapItem?.thumbnail?.url
  }
}
