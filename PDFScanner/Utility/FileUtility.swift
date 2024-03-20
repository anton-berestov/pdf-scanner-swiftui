//
//  FileUtility.swift
//  FolderCreate
//
//  Created by Anton Berestov on 19.03.24.
//

import Foundation
import UIKit

class FileUtility {
    
    static let shared = FileUtility()
    let fileManager = FileManager.default
    
    
    /// Default directory
    let defaultPath : URL = {
        let fileManager = FileManager.default
        let path = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Scans")

        do {
            try fileManager.createDirectory(at: path, withIntermediateDirectories: true, attributes: nil)
            print("The directory was created along the path \(path)")
        } catch {
            print("Failed to create directory at path \(path): \(error)")
        }
        
        return path
    }()
    
    /// Create folder
    func createFolder(directory:URL, name:String) -> String {
        let currentPath = directory.appendingPathComponent(name)
        if(fileManager.fileExists(atPath: currentPath.path)){
            return "Folder already exist with same name"
        }else{
            do{
                try fileManager.createDirectory(atPath: currentPath.path, withIntermediateDirectories: true, attributes: nil)
                return ""
            }catch{
                return "unable create folder due to \n \(error.localizedDescription.description)"
            }
        }
    }
    
    /// Get values from folders
    func scanDirectory(directory :URL)->[File]{
        var allFiles : [File] = []
        var allFileUrl : [URL] = []
        do {
            allFileUrl = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            if let index = allFileUrl.firstIndex(of: defaultPath.appendingPathComponent(".DS_Store")){
                allFileUrl.remove(at: index)
            }
        } catch {
            print(error.localizedDescription)
        }
        for fileUrl in allFileUrl{
            allFiles.append(File.init(fileUrl: fileUrl))
        }
        return allFiles
    }
    
    
    /// Write file
    func writeFile(file: Data, fileName: String) -> String {
        let path = defaultPath.appendingPathComponent(fileName)
        if !fileManager.createFile(atPath: path.path, contents: file, attributes: nil) {
            return "Failed to create file"
        }
        return ""
    }
    
    /// Write file to directory
    func writeFile(directory: URL, file: Data, fileName: String) -> String {
        let path = directory.appendingPathComponent(fileName)
        if !fileManager.createFile(atPath: path.path, contents: file, attributes: nil) {
            return "Failed to create file"
        }
        return ""
    }
    
    /// Rename file or directory
    func renameFolder (atPath path : URL, newName name : String) -> String {
        let currentPath = path
        
        do {
            try  fileManager.moveItem(at: path, to: currentPath.deletingLastPathComponent().appendingPathComponent("\(name)"))
            return ""
        } catch  {
            return error.localizedDescription
        }
    }
    
    /// Rename file
    func renameFile(atPath path:URL,newName name : String) -> String {
        let currentPath = path
        do {
            try  fileManager.moveItem(at: path, to: currentPath.deletingLastPathComponent().appendingPathComponent("\(name).pdf"))
            return ""
        } catch  {
            return error.localizedDescription.description
        }
    }
    
    /// Delete file or directory
    func delete(url:URL) -> String {
        do {
            try fileManager.removeItem(at: url)
            return ""
        } catch {
            return(error.localizedDescription.description)
        }
    }
}

public enum FileType {
    case folder, pdf, doc, txt, png, jpg, image
}

struct File {
    let name : String!
    let type : FileType!
    let size : String!
    let image : UIImage!
    let path : String!
    let url : URL!
    init(fileUrl:URL) {
        path = fileUrl.path
        self.url = fileUrl
        let fileExtension = fileUrl.pathExtension
        switch fileExtension {
        case "":
            name = fileUrl.lastPathComponent
            type = .folder
            self.image = UIImage(systemName: "folder.fill")
            size = ""
        case "pdf":
            name = fileUrl.deletingPathExtension().lastPathComponent
            type = .pdf
            self.size = ""
            image =  UIImage(systemName: "doc.text")
        case "jpg":
            name = ""
            type = .jpg
            self.size = ""
            image = UIImage(systemName: "photo.fill")
        case "png":
            name = fileUrl.deletingPathExtension().lastPathComponent
            type = .png
            self.size = ""
            image = UIImage(systemName: "photo.fill")
        default:
            name = fileUrl.lastPathComponent
            type = .folder
            size = ""
            image = UIImage(named: "folder")
        }
    }
}
