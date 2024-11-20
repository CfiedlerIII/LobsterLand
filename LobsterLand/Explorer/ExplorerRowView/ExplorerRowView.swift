//
//  ExplorerRowView.swift
//  LobsterLand
//
//  Created by Charles Fiedler on 11/17/24.
//

import SwiftUI
import ArcGIS

struct ExplorerRowView<ViewModel>: View where ViewModel: ExplorerViewModelable {
  @ObservedObject var viewModel: ViewModel

  var body: some View {
    GeometryReader { geom in
      ZStack {
        HStack {
          AsyncImage(url: viewModel.thumbnailURL) { image in
            image
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(maxHeight: .infinity)
          } placeholder: {
            Color.gray
          }
          VStack {
            Text(viewModel.title ?? "--")
              .font(.system(size: 18))
              .modifier(Justify(direction: .left))
            Text(viewModel.description ?? "--")
              .lineLimit(3)
              .truncationMode(.tail)
              .font(.system(size: 14))
              .foregroundStyle(Color(red: 0.4, green: 0.4, blue: 0.4))
              .modifier(Justify(direction: .left))
          }
          Spacer()
        }
        NavigationLink(destination: ExplorerMapView(viewModel: viewModel), label: {})
          .opacity(0.0)
          .buttonStyle(PlainButtonStyle())
          .disabled(viewModel.map == nil)
      }
    }
  }
}

struct ExplorerRowView_Previews: PreviewProvider {
  static let itemID = Item.ID("3bc3179f17da44a0ac0bfdac4ad15664")!
  static let item = PortalItem(portal: .arcGISOnline(connection: .anonymous), id: itemID)

  static var previews: some View {
    ExplorerRowView(
      viewModel: ExplorerRowViewModel(
        mapArea: .init(
          portalItem: item
        )
      )
    )
  }
}
