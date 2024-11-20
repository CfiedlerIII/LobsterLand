//
//  NetworkHandler.swift
//  LobsterLand
//
//  Created by Charles Fiedler on 11/20/24.
//

import Foundation
import Network

class NetworkHandler: ObservableObject {
  let monitor = NWPathMonitor()
  let queue = DispatchQueue(label: "Monitor")
  @Published private(set) var connected: Bool = false

  func checkConnection() {
    monitor.pathUpdateHandler = { path in
      if path.status == .satisfied {
        self.connected = true
      } else {
        self.connected = false
      }
    }
    monitor.start(queue: queue)
  }
}
