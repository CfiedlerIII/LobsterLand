//
//  ExploreMaineViewModel.swift
//  LobsterLand
//
//  Created by Charles Fiedler on 11/18/24.
//

import SwiftUI
import ArcGIS
import Network

class ExploreMaineViewModel: ObservableObject {
  @Published var map: Map
  @Published var mapAreas: [PreplannedMapArea] = []
  var offlineMapTask: OfflineMapTask?
  var basemapURL: URL?
  var portalItem: PortalItem
  private var monitor = NWPathMonitor()

  init() {
    let itemID = Item.ID("3bc3179f17da44a0ac0bfdac4ad15664")!
    let item = PortalItem(portal: .arcGISOnline(connection: .anonymous), id: itemID)
    self.portalItem = item
    self.map = Map(item: item)
    monitor.pathUpdateHandler = { path in
      if path.status == .satisfied {
        print("Internet connection is available.")
        // Perform actions when internet is available
        Task {
          await self.fetchPreplannedAreas(map: self.map)
        }
      } else {
        print("Internet connection is not available.")
        // Perform actions when internet is not available
        self.offlineMapTask?.cancelLoad()
        Task {
          await self.fetchDownloadedAreas(map: self.map)
        }
      }
    }
    let queue = DispatchQueue(label: "NetworkMonitor")
    monitor.start(queue: queue)
  }

  @MainActor
  func fetchPreplannedAreas(map: Map) async {
    self.offlineMapTask = OfflineMapTask(onlineMap: map)
    do {
      let areas = try await offlineMapTask?.preplannedMapAreas
      self.mapAreas = areas ?? []
      self.basemapURL = map.url
    } catch {
      print("Error 0x07: \(error)")
    }
  }

  @MainActor
  func fetchDownloadedAreas(map: Map) async {
    self.mapAreas = MapStorageService.shared.getAllPreplannedMetaData(portal: .arcGISOnline(connection: .anonymous))
  }

  @MainActor
  func handleMapLoad() async {
    for await loadStatus in map.$loadStatus {
      if loadStatus == .loaded {
        Task {
          await fetchPreplannedAreas(map: map)
        }
      } else if loadStatus != .loading {
        do {
          try await map.retryLoad()
        } catch {
          print("Error 0x08: \(error)")
        }
      }
    }
  }
}
