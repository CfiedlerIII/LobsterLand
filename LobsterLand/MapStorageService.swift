//
//  MapStorageService.swift
//  LobsterLand
//
//  Created by Charles Fiedler on 11/18/24.
//

import Foundation
import ArcGIS

class MapStorageService {
  static let shared = MapStorageService()

  func generateDirectoryForArea(withID areaID: String) -> URL {
    let docURL = getParentDirectory()
    let dataPath = docURL.appendingPathComponent("\(areaID)")
    return dataPath
  }

  func getParentDirectory() -> URL {
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let documentsDirectory = paths[0]
    let docURL = URL(string: documentsDirectory)!
    let dataPath = docURL.appendingPathComponent("OfflineBasemaps")
    return dataPath
  }

  func getDirectoryForMetaDataIfNeeded(withID areaID: String) -> URL {
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let dataPath = documentsDirectory.appendingPathComponent("\(areaID).json")
    return dataPath
  }

  func createLocalBasemapDirectoryIfNeeded(areaID: String) -> URL? {
    let dataPath = generateDirectoryForArea(withID: areaID)
    if !FileManager.default.fileExists(atPath: dataPath.path) {
      do {
        try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
        return dataPath
      } catch {
        print(error.localizedDescription)
        return nil
      }
    }
    return dataPath
  }

  func removeDownloadedArea(withID areaID: String) -> Bool {
    let dataPath = generateDirectoryForArea(withID: areaID)
    let metaDataPath = getDirectoryForMetaDataIfNeeded(withID: areaID)
    if FileManager.default.fileExists(atPath: dataPath.path) {
      do {
        try FileManager.default.removeItem(atPath: dataPath.path)
        try FileManager.default.removeItem(atPath: metaDataPath.path)
        return true
      } catch {
        print("Error 7: \(error.localizedDescription)")
      }
    }
    return false
  }

  func fetchAllMetaData(portal: Portal) -> [PreplannedMapArea] {
    let url = getParentDirectory()
    do {
      let fileNames = try FileManager.default.contentsOfDirectory(atPath: url.path())
      var metaDataFiles: [PreplannedMapArea] = []
      for fileName in fileNames where fileName.contains(".json") {
        let path = url.appending(path: fileName)
        if let data = try? Data(contentsOf: path) {
          do {
            let json = try JSONDecoder().decode(String.self, from: data)
            let metaData = PreplannedMapArea(portalItem: .init(json: json, portal: portal)!)
            metaDataFiles.append(metaData)
          }
        } else {
          print("Error: Data was nil")
        }
      }
      return metaDataFiles
    } catch {
      print("Error 6: \(error)")
      return []
    }
  }

  func saveMetaData(metaData: PreplannedMapArea, toUrl url: URL) {
    do {
      let json = metaData.portalItem.toJSON()
      let data = try JSONEncoder().encode(json)
      try data.write(to: url)
    } catch {
      print("Error 8: \(error)")
    }
  }

  func removeMetaDataAt(url: URL) {
    if FileManager.default.fileExists(atPath: url.path) {
      do {
        try FileManager.default.removeItem(atPath: url.path)
      } catch {
        print("Error 9: \(error.localizedDescription)")
      }
    }
  }

  func removeFileAt(url: URL) {
    if FileManager.default.fileExists(atPath: url.path) {
      do {
        try FileManager.default.removeItem(atPath: url.path)
      } catch {
        print("Error 10: \(error.localizedDescription)")
      }
    }
  }

  func fetchDownloadedMapArea(withID areaID: String) -> Bool {
    let dataPath = generateDirectoryForArea(withID: areaID)
    if FileManager.default.fileExists(atPath: dataPath.path) {
      return true
    }
    return false
  }

  func dataExistsForMapArea(withID areaID: String) -> Bool {
    let dataPath = generateDirectoryForArea(withID: areaID)
    if FileManager.default.fileExists(atPath: dataPath.path) {
      return true
    }
    return false
  }
}
