//
//  ExplorerMapView.swift
//  LobsterLand
//
//  Created by Charles Fiedler on 11/19/24.
//

import SwiftUI
import ArcGIS

struct ExplorerMapView<ViewModel>: View where ViewModel: ExplorerViewModelable {
  @ObservedObject var viewModel: ViewModel

  init(viewModel: ViewModel) {
    self.viewModel = viewModel
  }

  var body: some View {
    NavigationStack {
      if let safeMap = viewModel.map {
        MapView(map: safeMap)
          .ignoresSafeArea(edges: [.leading, .trailing, .bottom])
      }else {
        Text("Failed to load MapView.")
      }

    }
    .navigationTitle(viewModel.title ?? "--")
    .navigationBarTitleDisplayMode(.inline)
  }
}

struct ExplorerMapView_Previews: PreviewProvider {
  static let itemID = Item.ID("3bc3179f17da44a0ac0bfdac4ad15664")!
  static let item = PortalItem(portal: .arcGISOnline(connection: .anonymous), id: itemID)

  static var previews: some View {
    ExplorerMapView<ExplorerRowViewModel>(
      viewModel: ExplorerRowViewModel(
        mapArea: .init(
          portalItem: item
        )
      )
    )
  }
}
