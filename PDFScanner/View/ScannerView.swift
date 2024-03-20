//
//  ScannerView.swift
//  FolderCreate
//
//  Created by Anton Berestov on 19.03.24.
//

import Foundation
import SwiftUI
import VisionKit

struct ScannerView: UIViewControllerRepresentable {
    
    @Binding var cancelPressed: Bool
    @Binding var error: ScanError?
    @Binding var scanResult: VNDocumentCameraScan?
    var path: String
    
    typealias UIViewControllerType = VNDocumentCameraViewController
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        let myViewController = UIViewControllerType()
        myViewController.delegate = context.coordinator
        return myViewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        ///
    }
    
    func makeCoordinator() -> ScannerView.Coordinator {
        return Coordinator(self)
    }
}

extension ScannerView {
    class Coordinator : NSObject, VNDocumentCameraViewControllerDelegate {
        var parent: ScannerView
        
        init(_ parent: ScannerView) {
            self.parent = parent
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            parent.cancelPressed.toggle()
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            parent.error = error as? ScanError
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            parent.scanResult = scan
            saveScanResultToDocumentDirectory(scan)
        }
        
        func saveScanResultToDocumentDirectory(_ scan: VNDocumentCameraScan) {
            guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                print("Documents directory not found")
                return
            }
            
            let currentDate = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
            let formattedDate = dateFormatter.string(from: currentDate)
            
            let fileName = "Scan-\(formattedDate).pdf"
            if let range = parent.path.range(of: "Documents") {
                let substring = String(parent.path[parent.path.index(range.upperBound, offsetBy: 1)...])
                print(substring)
                
                let directory = documentsDirectory.appendingPathComponent(substring)
                let fileURL = directory.appendingPathComponent(fileName)
                
                UIGraphicsBeginPDFContextToFile(fileURL.path, CGRect.zero, nil)
                for i in 0..<scan.pageCount {
                    UIGraphicsBeginPDFPageWithInfo(CGRect(x: 0, y: 0, width: scan.imageOfPage(at: i).size.width, height: scan.imageOfPage(at: i).size.height), nil)
                    let image = scan.imageOfPage(at: i)
                    image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
                }
                UIGraphicsEndPDFContext()
                print("Scan result saved to: \(fileURL)")
            }
        }
    }
}
