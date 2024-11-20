//
//  ExploreMaineView.swift
//  LobsterLand
//
//  Created by Charles Fiedler on 11/12/24.
//

import SwiftUI
import ArcGIS

struct ExploreMaineView: View {
  @ObservedObject var viewModel = ExploreMaineViewModel()

  var body: some View {
    NavigationStack {
      List {
        Section(content: {
          ExplorerRowView(
            viewModel: MaineExplorerRowViewModel(
              map: viewModel.map,
              mapItem: viewModel.map.item,
              parentMapItem: viewModel.portalItem
            ),
            canDownload: false
          )
        }, header: {
          Text("Web Map")
        })
        Section(content: {
          ForEach(viewModel.mapAreas, id: \.portalItem.id) { area in
            ExplorerRowView(
              viewModel: ExplorerRowViewModel(
                isOnline: viewModel.networkHandler.connected,
                mapArea: area,
                parentMapItem: viewModel.portalItem,
                offlineMapTask: viewModel.offlineMapTask,
                mapURL: viewModel.basemapURL
              )
            )
          }
        }, header: {
          Text("Map Areas")
        })
      }
      .environment(\.defaultMinListRowHeight, 80)
      .task {
        await viewModel.handleMapLoad()
      }
      .navigationTitle("Explore Maine")
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}

struct ExploreMaineView_Previews: PreviewProvider {
  static var previews: some View {
    ExploreMaineView()
  }
}
