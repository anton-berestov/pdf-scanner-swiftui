//
//  ContentView.swift
//  FolderCreate
//
//  Created by Anton Berestov on 19.03.24.
//

import SwiftUI
import UIKit
import AVFoundation
import VisionKit
import Combine

struct PdfScannerView: View {
    
    private let utility = FileUtility.shared
    @EnvironmentObject var manager: DataManager
    @State private var allFolders: [File] = [File]()
    @State private var showingAlert = false
    @State private var showingAlertError = false
    @State private var errorMessage: String = ""
    @State private var name = ""
    
    @State var cancelPressed = false
    @State var scanError: ScanError?
    @State var scanResult: VNDocumentCameraScan?
    @State var scanMode = false
    @State var recognizedText = "Processing ..."
    var textScanner = TextScanner()
    
    var body: some View {
        NavigationView {
            if !scanMode { VStack {
                if allFolders.count == 0{
                    Image(systemName: "globe")
                        .imageScale(.large)
                        .foregroundStyle(.tint)
                    Text("Hello, world!")
                } else {
                    FoldersListView
                }
                
            }.toolbar {
                Button(action: {
                    self.showingAlert.toggle()
                }, label: {
                    Image(systemName: "folder.badge.plus")
                })
                .alert("Add Folder", isPresented: $showingAlert) {
                    TextField("Folder name", text: $name)
                    Button("Later", role: .cancel){}
                    Button("OK", action: submit)
                } message: {
                    Text("Enter folder name to add new folder")
                }
                .alert("Failed\n\(errorMessage)", isPresented: $showingAlertError) {
                    Button("OK", role: .cancel) { }
                }
                Button(action: {
                    scanMode.toggle()
                }, label: {
                    Image(systemName: "doc.viewfinder")
                })
            }
            } else {
                activeView
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            self.getFolders()
        }
    }
    
    @ViewBuilder
    var activeView: some View {
        if (scanMode) {
            ScannerView(cancelPressed: $cancelPressed, error: $scanError, scanResult: $scanResult, path: utility.defaultPath.path)
                .onChange(of: scanResult, perform: process(scanResult: ))
                .onChange(of: scanError, perform: notify(error:))
                .onChange(of: cancelPressed, perform: toggleScanMode(mode:))
                .onReceive(textScanner.$recognizedText, perform: { stringValue in self.recognizedText = stringValue })
                .ignoresSafeArea(.all)
        }
    }
    
    /// Folders scroll view
    private var FoldersListView: some View {
        ScrollView(.vertical, showsIndicators: false, content: {
            VStack {
                Spacer(minLength: 0)
                ForEach(0..<allFolders.count, id: \.self) { index in
                    if allFolders[index].type == .folder {
                        NavigationLink(destination: FolderOverviewView(folder: allFolders[index])
                        ) {
                            FolderView(folder: allFolders[index], handler: self.getFolders)
                                .navigationBarBackButtonHidden(true)
                        }
                        .onTapGesture {
                            self.getFolders()
                        }
                    }
                    if allFolders[index].type == .pdf {
                        NavigationLink(destination: PDFViewer(folder: allFolders[index] )
                        ) {
                            FolderView(folder: allFolders[index], handler: {})
                                .navigationBarBackButtonHidden(true)
                        }
                        .onTapGesture {
                            self.getFolders()
                        }
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(0)
            .padding([.top, .bottom], 5)
        })
    }
    
    private func getFolders() -> Void {
        self.allFolders = utility.scanDirectory(directory: utility.defaultPath)
    }
    
    private func submit() {
        errorMessage = utility.createFolder(directory: utility.defaultPath, name: name)
        if (errorMessage != "") {
            self.showingAlertError.toggle()
        } else {
           allFolders = utility.scanDirectory(directory: utility.defaultPath)
        }
        self.name = ""
    }
    
    func process(scanResult: VNDocumentCameraScan?) {
        guard let scanResult = scanResult else { return }
        toggleScanMode(mode: false)
        textScanner.subject.send(scanResult)
        getFolders()
    }
    
    func notify(error: ScanError?) {
        guard let error = error else { return }
        NSLog(error.localizedDescription)
    }
    
    func toggleScanMode(mode: Bool) {
        withAnimation(.easeInOut(duration: 1.0)) {
            scanMode.toggle()
        }
    }
    
}

#Preview {
    PdfScannerView()
}
