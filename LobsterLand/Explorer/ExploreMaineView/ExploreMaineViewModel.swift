//
//  ExploreMaineViewModel.swift
//  LobsterLand
//
//  Created by Charles Fiedler on 11/18/24.
//

import SwiftUI
import ArcGIS

class ExploreMaineViewModel: ObservableObject {
  @Published var map: Map
  @Published var mapAreas: [PreplannedMapArea] = []

  init() {
    let itemID = Item.ID("3bc3179f17da44a0ac0bfdac4ad15664")!
    let item = PortalItem(portal: .arcGISOnline(connection: .anonymous), id: itemID)
    self.map = Map(item: item)
  }

  @MainActor
  func fetchPreplannedAreas(map: Map) async {
    let offlineMapTask = OfflineMapTask(onlineMap: map)
    do {
      let areas = try await offlineMapTask.preplannedMapAreas
      self.mapAreas = areas
    } catch {
      print("Error: \(error)")
    }
  }
}
