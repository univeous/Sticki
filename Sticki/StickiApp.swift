//
//  StickiApp.swift
//  Sticki
//
//  Created by Evil on 2024/04/26.
//

import SwiftUI
import Photos

@main
struct StickiApp: App {
    @ObservedObject var photoLibraryManager = PhotoLibraryManager.shared
    
    var body: some Scene {
        WindowGroup {
            if !photoLibraryManager.isAuthorized {
                Text("Please grant album permissions")
                    .onAppear{
                        photoLibraryManager.requestAuthorization()
                    }
                    .onDisappear{
                        if !photoLibraryManager.isAuthorized {
                            NSApplication.shared.terminate(self)
                        }
                    }
            } else {
                ContentView()
                    .onDisappear{
                        NSApplication.shared.terminate(self)
                    }
                    .onAppear{
                        setWindowAlwaysOnTop()
                    }
            }
        }
        //.windowStyle(HiddenTitleBarWindowStyle())
    }
    
    func setWindowAlwaysOnTop() {
        if let window = NSApplication.shared.windows.first {
            window.level = .floating
        }
    }

}


class PhotoLibraryManager: ObservableObject {
    static let shared = PhotoLibraryManager()
    @Published var isAuthorized = false

    func requestAuthorization() {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                self.isAuthorized = (status == .authorized || status == .limited)
            }
        }
    }
}
