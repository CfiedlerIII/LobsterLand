//
//  ExplorerViewModelable.swift
//  LobsterLand
//
//  Created by Charles Fiedler on 11/18/24.
//

import Foundation
import SwiftUI
import ArcGIS

protocol ExplorerViewModelable: ObservableObject {
  var map: Map? { get set }
  var title: String? { get set }
  var description: String? { get set }
  var thumbnailURL: URL? { get set }
  var isOnline: Bool { get set }
  var isLoading: Bool { get set }
  var parentMapItem: PortalItem { get set }
  var savedImage: Image? { get set }

  func downloadOfflineMap() async throws
  func downloadedDataExists() -> Bool
  func removeDownloadedArea()
  func getDownloadedMapURL() -> URL?
  func makeMobileMapPackage(offlineMapURL: URL) async
}
