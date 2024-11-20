//
//  ExplorerViewModelable.swift
//  LobsterLand
//
//  Created by Charles Fiedler on 11/18/24.
//

import Foundation
import ArcGIS

protocol ExplorerViewModelable: ObservableObject {
  var title: String? { get set }
  var description: String? { get set }
  var thumbnailURL: URL? { get set }
  var isLoading: Bool { get set }
  var downloadedMap: Map? { get set }
  var parentMapItem: PortalItem { get set }

  func downloadOfflineMap() async
  func downloadedDataExists() -> Bool
  func removeDownloadedArea()
  func getDownloadedMapURL() -> URL?
  func makeMobileMapPackage(offlineMapURL: URL) async
}
