//
//  FolderOverviewView.swift
//  PowerScanner
//
//  Created by Anton Berestov on 04.03.24.
//

import SwiftUI
import UIKit
import AVFoundation
import VisionKit
import Combine

struct FolderOverviewView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var manager: DataManager
    @Environment(\.dismiss) private var dismiss
    @State var folders: [File] = [File]()
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
    
    var folder: File
    private let utility = FileUtility.shared
    
    var body: some View {
        NavigationView {
            if !scanMode {
                VStack {
                    FoldersListView
                    Spacer()
                }.toolbar {
                    HStack {
                        Button(action: {
                            dismiss()
                        }, label: {
                            Image(systemName: "arrowshape.turn.up.backward.2")
                        })
                        Text(folder.name)
                            .font(
                                Font.system(size: 18)
                                    .weight(.bold)
                            )
                            .padding(0)
                        Spacer()
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
                    .padding(.horizontal)
                    .frame(width: screen.width)
                }.onAppear {
                    self.getFolders()
                }
            } else {
                activeView
            }
        }.navigationBarBackButtonHidden(true)
    }
    
    @ViewBuilder
    var activeView: some View {
        if (scanMode) {
            ScannerView(cancelPressed: $cancelPressed, error: $scanError, scanResult: $scanResult, path: folder.path)
                .onChange(of: scanResult, perform: process(scanResult:))
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
                ForEach(0..<folders.count, id: \.self) { index in
                    if folders[index].type == .folder {
                        NavigationLink(destination: FolderOverviewView(folder: folders[index])) {
                            FolderView(folder: folders[index],  handler: self.getFolders).navigationBarBackButtonHidden(true)
                        }
                        .onTapGesture {
                            self.folders = utility.scanDirectory(directory: folders[index].url)
                        }
                    }
                    if folders[index].type == .pdf {
                        NavigationLink(destination: PDFViewer(folder: folders[index])) {
                            FolderView(folder: folders[index], handler: self.getFolders)
                                .navigationBarBackButtonHidden(true)
                        }
                        .onTapGesture {
                            self.folders = utility.scanDirectory(directory: folders[index].url)
                        }
                    }
                }
            }
            .padding(0)
            .padding([.top, .bottom], 5)
        })
    }
    private func getFolders() -> Void {
        self.folders = utility.scanDirectory(directory: folder.url)
    }
    
    private func submit() {
        errorMessage = utility.createFolder(directory: folder.url, name: name)
        if (errorMessage != "") {
            self.showingAlertError.toggle()
        } else {
            self.folders = utility.scanDirectory(directory: folder.url)
        }
        self.name = ""
    }
    
    private func process(scanResult: VNDocumentCameraScan?) {
        guard let scanResult = scanResult else { return }
        toggleScanMode(mode: false)
        textScanner.subject.send(scanResult)
        self.getFolders()
    }
    
    private func notify(error: ScanError?) {
        guard let error = error else { return }
        NSLog(error.localizedDescription)
    }
    
    private func toggleScanMode(mode: Bool) {
        withAnimation(.easeInOut(duration: 1.0)) {
            scanMode.toggle()
        }
    }
}

#Preview {
    let myFileInstance = File(fileUrl: URL(fileURLWithPath: "/path/to/example"))
    return FolderOverviewView(folder: myFileInstance)
        .environmentObject(DataManager())
}
