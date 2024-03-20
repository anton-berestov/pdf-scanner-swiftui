//
//  FolderCreateApp.swift
//  FolderCreate
//
//  Created by Anton Berestov on 19.03.24.
//

import SwiftUI

let screen = UIScreen.main.bounds

@main
struct PDFScannerApp: App {
    
    @StateObject private var manager = DataManager()
    var body: some Scene {
        WindowGroup {
            PdfScannerView().environmentObject(manager)
        }
    }
}
