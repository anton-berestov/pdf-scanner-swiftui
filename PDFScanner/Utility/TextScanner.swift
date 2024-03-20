//
//  TextScanner.swift
//  FolderCreate
//
//  Created by Anton Berestov on 19.03.24.
//

import Foundation
import Combine
import VisionKit
import Vision

class TextScanner: NSObject, ObservableObject {
    @Published var recognizedText: String = ""
    
    let subject = PassthroughSubject<VNDocumentCameraScan, Never>()
    
    private var cancellables = [AnyCancellable]()
    
    override init() {
        super.init()
        subject
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink( receiveValue: { scan in
                self.recognizedText = self.detect(scan: scan)
            }).store(in: &cancellables)
    }
    
    private func detect(scan: VNDocumentCameraScan) -> String {
        return (0 ..< scan.pageCount)
            .compactMap({scan.imageOfPage(at: $0).cgImage})
            .map { image -> String in
                let handler = VNImageRequestHandler(cgImage: image)
                do {
                    let request = VNRecognizeTextRequest()
                    request.recognitionLevel = .accurate
                    try handler.perform([request])
                    guard let observations = request.results else { return "" }
                    return observations.compactMap({$0.topCandidates(1).first?.string}).joined(separator: "\n")
                } catch {
                    return ""
                }
            }
            .reduce("") { $0 + "\n\n" + $1 }
    }
}
