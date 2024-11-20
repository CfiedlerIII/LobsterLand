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

  func getParentDirectory() -> URL {
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let documentsDirectory = paths[0]
    let docURL = URL(string: documentsDirectory)!
    let dataPath = docURL.appendingPathComponent("OfflineBasemaps")
    return dataPath
  }

  func getDirectoryForArea(withID areaID: String) -> URL {
    let docURL = getParentDirectory()
    let dataPath = docURL.appendingPathComponent("\(areaID)")
    return dataPath
  }

  func getDirectoryForMetaData(withID areaID: String) -> URL {
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let dataPath = documentsDirectory.appendingPathComponent("\(areaID).json")
    return dataPath
  }

  func createLocalBasemapDirectoryIfNeeded(areaID: String) -> URL? {
    let dataPath = getDirectoryForArea(withID: areaID)
    if !FileManager.default.fileExists(atPath: dataPath.path) {
      do {
        try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
        return dataPath
      } catch {
        print("Error 0x00: \(error.localizedDescription)")
        return nil
      }
    }
    return dataPath
  }

  func saveMetaData(metaData: PreplannedMapArea, toUrl url: URL) {
    do {
      let json = metaData.portalItem.toJSON()
      let data = try JSONEncoder().encode(json)
      try data.write(to: url)
    } catch {
      print("Error 0x01: \(error)")
    }
  }

  func deleteFileAt(url: URL) throws {
    if FileManager.default.fileExists(atPath: url.path) {
      try FileManager.default.removeItem(atPath: url.path)
    } else {
      print("Error 0x02: No file to delete at URL \(url.absoluteURL)")
    }
  }

  func removeDownloadedDataForArea(withID areaID: String) throws {
    let dataPath = getDirectoryForArea(withID: areaID)
    let metaDataPath = getDirectoryForMetaData(withID: areaID)
    try deleteFileAt(url: dataPath)
    try deleteFileAt(url: metaDataPath)
  }

  func getAllPreplannedMetaData(portal: Portal) -> [PreplannedMapArea] {
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
          } catch {
            print("Error 0x03: \(error)")
          }
        } else {
          print("Error 0x04: MetaData contents was empty.")
        }
      }
      print("Files Returned:")
      print(metaDataFiles)
      return metaDataFiles
    } catch {
      print("Error 0x05: \(error)")
      return []
    }
  }
}
