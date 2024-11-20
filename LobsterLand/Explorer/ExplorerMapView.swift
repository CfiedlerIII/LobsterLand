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
  @State private var map = Map(
    item: PortalItem(
      portal: .arcGISOnline(connection: .anonymous),
      id: PortalItem.ID("5a030a31e42841a89914bd7c5ecf4d8f")!
    )
  )

  var body: some View {
    NavigationStack {
      MapView(map: viewModel.downloadedMap ?? map)
        .ignoresSafeArea(edges: [.leading, .trailing, .bottom])
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
        ),
        parentMapItem: item
      )
    )
  }
}
