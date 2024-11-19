//
//  ExplorerRowViewModel.swift
//  LobsterLand
//
//  Created by Charles Fiedler on 11/18/24.
//

import SwiftUI
import ArcGIS

class ExplorerRowViewModel: ExplorerViewModelable, ObservableObject {

  var mapArea: PreplannedMapArea
  @Published var title: String?
  @Published var description: String?
  @Published var thumbnailURL: URL?

  init(mapArea: PreplannedMapArea) {
    self.mapArea = mapArea
    Task {
      await loadAreaDetails(mapArea)
    }
  }

  @MainActor
  func loadAreaDetails(_ area: PreplannedMapArea) async {
    do {
      for await loadStatus in area.$loadStatus {
        switch loadStatus {
        case .notLoaded:
          try await area.retryLoad()
        case .loaded:
          self.title = area.portalItem.title
          self.description = area.portalItem.snippet
          self.thumbnailURL = area.portalItem.thumbnail?.url
        case .loading:
          break
        case .failed:
          print("Error: Failed to fetch load status.")
        }
      }
    } catch {
      print("Error: \(error)")
    }
  }
}
