//
//  MainApp.swift
//  LobsterLand
//
//  Created by Charles Fiedler on 11/8/24.
//

import SwiftUI
import ArcGIS

@main
struct MainApp: App {

  init() {
    ArcGISEnvironment.apiKey = APIKey("AAPTxy8BH1VEsoebNVZXo8HurB1acyzTMP3XaQKfbLcPPiza5wUjXRwgQl5B0qHf0imv21OkG8Xg_XsalnL7JbCfPot7XEzcWJjIUtHxtAvJcSV9QeJOXsITTnZ_CjkNviV1YId3rbuCvFR4XkfiK9rfju62OLY3Gy3Xm6bLl86DHa3BzBTtyl86I7Hr0ZIQ75Hnansc_n6p0tXUA2KZJDu9n18TpsAN6D2LzEwTz8eIOjg.AT1_uI9Onfuh")
  }

  var body: some SwiftUI.Scene {
        WindowGroup {
            ContentView()
            .ignoresSafeArea()
        }
    }
}
