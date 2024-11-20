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
  var isLoading: Bool = false
  var downloadedMap: Map? = nil
  var parentMapItem: PortalItem
  @Published var title: String?
  @Published var description: String?
  @Published var thumbnailURL: URL?


  init(mapItem: Item?, parentMapItem: PortalItem) {
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
