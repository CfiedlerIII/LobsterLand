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
          ExplorerRowView(viewModel: MaineExplorerRowViewModel(mapItem: viewModel.map.item))
        }, header: {
          Text("Web Map")
        })
        Section(content: {
          ForEach(viewModel.mapAreas, id: \.portalItem.id) { area in
            ExplorerRowView(viewModel: ExplorerRowViewModel(mapArea: area))
          }
        }, header: {
          Text("Map Areas")
        })
      }
      .environment(\.defaultMinListRowHeight, 80)
      .task {
        await handleMapLoad()
      }
      .navigationTitle("Explore Maine")
      .navigationBarTitleDisplayMode(.inline)
    }
  }

  func handleMapLoad() async {
    for await loadStatus in viewModel.map.$loadStatus {
      if loadStatus == .loaded {
        Task { @MainActor in
          await viewModel.fetchPreplannedAreas(map: viewModel.map)
        }
      } else if loadStatus != .loading {
        do {
          try await viewModel.map.retryLoad()
        } catch {
          print("Error: \(error)")
        }
      }
    }
  }
}

struct ExploreMaineView_Previews: PreviewProvider {
  static var previews: some View {
    ExploreMaineView()
  }
}
