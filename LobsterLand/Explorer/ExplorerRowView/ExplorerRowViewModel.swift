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
  @Published var downloadedMap: Map?
  @Published var isLoading: Bool = false
  @Published var title: String?
  @Published var description: String?
  @Published var thumbnailURL: URL?

  init(mapArea: PreplannedMapArea, parentMapItem: PortalItem, offlineMapTask: OfflineMapTask? = nil, mapURL: URL? = nil) {
    self.mapArea = mapArea
    self.parentMapItem = parentMapItem
    self.offlineMapTask = offlineMapTask
    self.mapURL = mapURL
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
          if downloadedDataExists(),
             let url = getDownloadedMapURL() {
            await makeMobileMapPackage(offlineMapURL: url)
          }
        case .loading:
          break
        case .failed:
          print("Error: Failed to fetch load status.")
        }
      }
    } catch {
      print("Error 15: \(error)")
    }
  }

  @MainActor
  func downloadOfflineMap() async {
    do {
      guard let parameters = try await offlineMapTask?.makeDefaultDownloadPreplannedOfflineMapParameters(preplannedMapArea: mapArea),
      let mapID = self.mapArea.portalItem.id?.rawValue,
          let directory = MapStorageService.shared.createLocalBasemapDirectoryIfNeeded(areaID: mapID) else {
            print("Error: OfflineMapTask was nil")
            isLoading = false
            return
      }
      // Configures the parameters.
      parameters.continuesOnErrors = false
      parameters.includesBasemap = true
      parameters.referenceBasemapDirectoryURL = mapArea.portalItem.url

      // Starts the preplanned map job and gets its output.

      guard let downloadJob = offlineMapTask?.makeDownloadPreplannedOfflineMapJob(parameters: parameters, downloadDirectory: directory) else {
        print("Error: Failed to create download job.")
        isLoading = false
        return
      }
      downloadJob.start()
      let output = try await downloadJob.output
      // Prints the errors if any.
      if output.hasErrors {
        output.layerErrors.forEach { layerError in
          print("Error taking this layer offline: \(layerError.key.layer.name)")
        }
        output.tableErrors.forEach { tableError in
          print("Error taking this table offline: \(tableError.key.featureTable.displayName)")
        }
      } else {
        // Otherwise, displays the map.
        self.downloadedMap = output.offlineMap
        saveAreaMetaData(mapArea: mapArea)
      }
      isLoading = false
    } catch {
      print("Error 14: \(error)")
      isLoading = false
    }
  }

  func saveAreaMetaData(mapArea: PreplannedMapArea) {
    guard let mapID = mapArea.portalItem.id?.rawValue else {
      print("Error: Failed to generate MetaData directory")
      return
    }
    let path = MapStorageService.shared.getDirectoryForMetaDataIfNeeded(withID: mapID)
    if FileManager.default.fileExists(atPath: path.path()) {
      print("Removing MetaData before saving")
      MapStorageService.shared.removeFileAt(url: path)
    }
    MapStorageService.shared.saveMetaData(metaData: mapArea, toUrl: path)
  }

  func downloadedDataExists() -> Bool {
    guard let areaID = mapArea.portalItem.id?.rawValue else {
      return false
    }
    let path = MapStorageService.shared.generateDirectoryForArea(withID: areaID)
    if FileManager.default.fileExists(atPath: path.path) {
      do {
        let fileNames = try FileManager.default.contentsOfDirectory(atPath: path.absoluteString)
        return fileNames.count > 0
      } catch {
        print("Error 13: \(error)")
        return false
      }
    }
    return false
  }

  func removeDownloadedArea() {
    guard let areaID = mapArea.portalItem.id?.rawValue else {
      return
    }
    if MapStorageService.shared.removeDownloadedArea(withID: areaID) {
      self.downloadedMap = nil
    }
  }

  func getDownloadedMapURL() -> URL? {
    guard let areaID = mapArea.portalItem.id?.rawValue else {
      return nil
    }
    let mapURL = MapStorageService.shared.generateDirectoryForArea(withID: areaID)
    return mapURL
  }

  @MainActor
  func makeMobileMapPackage(offlineMapURL: URL) async {
    do {
      let mobileMapPackage = MobileMapPackage(fileURL: offlineMapURL)
      try await mobileMapPackage.load()
      downloadedMap = mobileMapPackage.maps.first
    } catch {
      print("Error 4: \(error)")
    }
  }
}
