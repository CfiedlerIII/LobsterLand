//
//  Justify.swift
//  LobsterLand
//
//  Created by Charles Fiedler on 11/18/24.
//

import SwiftUI

struct Justify: ViewModifier {
  enum Direction {
    case left
    case right
  }

  var direction: Direction

  func body(content: Content) -> some View {
    HStack {
      if direction == .right {
        Spacer()
      }
      content
      if direction == .left {
        Spacer()
      }
    }
  }
}
