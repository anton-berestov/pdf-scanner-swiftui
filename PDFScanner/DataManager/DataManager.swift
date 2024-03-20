//
//  DataManager.swift
//  FolderCreate
//
//  Created by Anton Berestov on 19.03.24.
//

import Foundation

/// Main data manager class
class DataManager: ObservableObject {
    @Published var allFolders: [File] = [File]()
}

