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
  @ObservedObject var networkHandler = NetworkHandler()
  @Published var map: Map
  @Published var mapAreas: [PreplannedMapArea] = []
  var offlineMapTask: OfflineMapTask?
  var mapLoadTask: Task<(), Never>?
  var basemapURL: URL?
  var portalItem: PortalItem
  private var monitor = NWPathMonitor()

  init() {
    let itemID = Item.ID("3bc3179f17da44a0ac0bfdac4ad15664")!
    let item = PortalItem(portal: .arcGISOnline(connection: .anonymous), id: itemID)
    self.portalItem = item
    self.map = Map(item: item)
    networkHandler.checkConnection()
    if networkHandler.connected {
      self.mapLoadTask = Task { @MainActor in
        await self.handleMapLoad()
      }
    } else {
      self.mapLoadTask?.cancel()
    }
  }

  @MainActor
  func fetchPreplannedAreas(map: Map) async {
    self.offlineMapTask = OfflineMapTask(onlineMap: map)
    do {
      let areas = try await self.offlineMapTask?.preplannedMapAreas
      self.mapAreas = areas ?? []
      self.basemapURL = map.url
    } catch {
      print("Error 0x06: \(error)")
    }
  }

  @MainActor
  func fetchDownloadedAreas(map: Map) async {
    self.mapAreas = MapStorageService.shared.getAllPreplannedMetaData(portal: .arcGISOnline(connection: .anonymous))
    self.basemapURL = map.url
  }

  @MainActor
  func handleMapLoad() async {
    if networkHandler.connected {
      for await loadStatus in map.$loadStatus {
        if loadStatus == .loaded {
          self.mapLoadTask = Task {
            await fetchPreplannedAreas(map: map)
          }
        } else if loadStatus != .loading {
          do {
            try await map.retryLoad()
          } catch {
            print("Error 0x07: \(error)")
            await fetchDownloadedAreas(map: map)
          }
        }
      }
    } else {
      await fetchDownloadedAreas(map: map)
    }
  }
}
