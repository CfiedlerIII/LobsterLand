//
//  ExplorerViewModelable.swift
//  LobsterLand
//
//  Created by Charles Fiedler on 11/18/24.
//

import Foundation

protocol ExplorerViewModelable: ObservableObject {
  var title: String? { get set }
  var description: String? { get set }
  var thumbnailURL: URL? { get set }
}
