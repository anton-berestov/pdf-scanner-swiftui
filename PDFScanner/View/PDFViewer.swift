//
//  PDFViewer.swift
//  FolderCreate
//
//  Created by Anton Berestov on 19.03.24.
//

import SwiftUI
import PDFKit

struct PDFViewer: View {
    var folder: File
    var body: some View {
        VStack {
            PDFKitView(url: folder.url)
        }
    }
}

struct PDFKitView: UIViewRepresentable {
    let url: URL
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        if let document = PDFDocument(url: url) {
            pdfView.document = document
        }
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        // Update the view if needed
    }
}

#Preview {
    let myFileInstance = File(fileUrl: URL(fileURLWithPath: "/path/to/example"))
    return PDFViewer(folder: myFileInstance)
}
