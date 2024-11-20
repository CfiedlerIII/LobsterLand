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
  var isOnline: Bool = true
  var isLoading: Bool = false
  var parentMapItem: PortalItem
  @Published var map: Map?
  @Published var title: String?
  @Published var description: String?
  @Published var thumbnailURL: URL?
  @Published var savedImage: Image?

  init(map: Map? = nil, mapItem: Item?, parentMapItem: PortalItem) {
    self.map = map
    self.mapItem = mapItem
    self.title = mapItem?.title
    self.description = mapItem?.snippet
    self.thumbnailURL = mapItem?.thumbnail?.url
    self.parentMapItem = parentMapItem
  }

  func downloadOfflineMap() {}
  func downloadedDataExists() -> Bool {
    return false
  }
  func removeDownloadedArea() {}
  func getDownloadedMapURL() -> URL? {
    return nil
  }
  func makeMobileMapPackage(offlineMapURL: URL) {}
}
