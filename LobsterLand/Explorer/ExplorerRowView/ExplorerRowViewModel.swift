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
  var offlineMapTask: OfflineMapTask?
  var mapURL: URL?
  var parentMapItem: PortalItem
  @Published var isOnline: Bool
  @Published var isLoading: Bool = false
  @Published var map: Map?
  @Published var title: String?
  @Published var description: String?
  @Published var thumbnailURL: URL?
  @Published var savedImage: Image?

  init(isOnline: Bool, mapArea: PreplannedMapArea, parentMapItem: PortalItem, offlineMapTask: OfflineMapTask? = nil, mapURL: URL? = nil) {
    self.isOnline = isOnline
    self.mapArea = mapArea
    self.parentMapItem = parentMapItem
    self.offlineMapTask = offlineMapTask
    self.mapURL = mapURL
    Task {
      if isOnline {
        await loadAreaDetails(mapArea)
      } else {
        await handleMapAreaData(mapArea)
      }
    }
  }

  @MainActor
  func handleMapAreaData(_ area: PreplannedMapArea) async {
    self.title = area.portalItem.title
    self.description = area.portalItem.snippet
    self.thumbnailURL = area.portalItem.thumbnail?.url
    if let image = area.portalItem.thumbnail?.image {
      // This does not currently work :(
      self.savedImage = Image(uiImage: image)
    }
    if downloadedDataExists(),
       let url = getDownloadedMapURL() {
      await makeMobileMapPackage(offlineMapURL: url)
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
          await handleMapAreaData(area)
        case .loading:
          break
        case .failed:
          print("Error 0x08: Failed to fetch load status.")
        }
      }
    } catch {
      print("Error 0x09: \(error)")
    }
  }

  @MainActor
  func downloadOfflineMap() async throws {
    guard let parameters = try await offlineMapTask?.makeDefaultDownloadPreplannedOfflineMapParameters(preplannedMapArea: mapArea),
          let mapID = self.mapArea.portalItem.id?.rawValue,
          let directory = MapStorageService.shared.createLocalBasemapDirectoryIfNeeded(areaID: mapID) else {
      print("Error 0x0a: OfflineMapTask was nil")
      isLoading = false
      return
    }
    // Configures the parameters.
    parameters.continuesOnErrors = false
    parameters.includesBasemap = true
    parameters.referenceBasemapDirectoryURL = mapArea.portalItem.url

    // Starts the preplanned map job and gets its output.

    guard let downloadJob = offlineMapTask?.makeDownloadPreplannedOfflineMapJob(parameters: parameters, downloadDirectory: directory) else {
      print("Error 0x0b: Failed to create download job.")
      isLoading = false
      return
    }
    downloadJob.start()
    let output = try await downloadJob.output
    // Prints the errors if any.
    if output.hasErrors {
      output.layerErrors.forEach { layerError in
        print("Error 0x0c: Taking this layer offline: \(layerError.key.layer.name)")
      }
      output.tableErrors.forEach { tableError in
        print("Error 0x0d: Taking this table offline: \(tableError.key.featureTable.displayName)")
      }
    } else {
      // Otherwise, displays the map.
      self.map = output.offlineMap
      saveAreaMetaData(mapArea: mapArea)
    }
    isLoading = false
  }

  func saveAreaMetaData(mapArea: PreplannedMapArea) {
    guard let mapID = mapArea.portalItem.id?.rawValue else {
      print("Error 0x0f: Failed to generate MetaData directory")
      return
    }
    let path = MapStorageService.shared.getDirectoryForMetaData(withID: mapID)
    if FileManager.default.fileExists(atPath: path.path()) {
      do {
        try MapStorageService.shared.deleteFileAt(url: path)
      } catch {
        print("Error 0x10: \(error)")
      }
    }
    MapStorageService.shared.saveMetaData(metaData: mapArea, toUrl: path)
  }

  func downloadedDataExists() -> Bool {
    guard let areaID = mapArea.portalItem.id?.rawValue else {
      print("Error 0x11: Failed to get Item.ID from mapArea.")
      return false
    }
    let path = MapStorageService.shared.getDirectoryForArea(withID: areaID)
    if FileManager.default.fileExists(atPath: path.path) {
      do {
        let fileNames = try FileManager.default.contentsOfDirectory(atPath: path.absoluteString)
        return fileNames.count > 0
      } catch {
        print("Error 0x12: \(error)")
        return false
      }
    }
    return false
  }

  func removeDownloadedArea() {
    guard let areaID = mapArea.portalItem.id?.rawValue else {
      print("Error 0x13: Failed to get Item.ID from mapArea.")
      return
    }
    do {
      try MapStorageService.shared.removeDownloadedDataForArea(withID: areaID)
      self.map = nil
    } catch {
      print("Error 0x14: \(error)")
    }
  }

  func getDownloadedMapURL() -> URL? {
    guard let areaID = mapArea.portalItem.id?.rawValue else {
      print("Error 0x15: Failed to get Item.ID from mapArea.")
      return nil
    }
    let mapURL = MapStorageService.shared.getDirectoryForArea(withID: areaID)
    return mapURL
  }

  @MainActor
  func makeMobileMapPackage(offlineMapURL: URL) async {
    do {
      let mobileMapPackage = MobileMapPackage(fileURL: offlineMapURL)
      try await mobileMapPackage.load()
      self.map = mobileMapPackage.maps.first
    } catch {
      print("Error 0x16: \(error)")
    }
  }
}
