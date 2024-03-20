//
//  FolderView.swift
//  PowerScanner
//
//  Created by Anton Berestov on 04.03.24.
//

import SwiftUI

struct FolderView: View {
    @EnvironmentObject var manager: DataManager
    
    static let width: CGFloat = UIScreen.main.bounds.width/1.8
    private let utility = FileUtility.shared
    
    @State private var isPopoverPresented = false
    @State private var show = false
    @State private var showingAlertEdit = false
    @State private var showingAlertDelete = false
    @State private var showingAlertError = false
    @State private var name = ""
    @State private var errorMessage: String = ""
    var folder: File
    var handler: () -> Void
    
    var body: some View {
        HStack {
            HStack(alignment: .center) {
                /// Folder icon
                LinearGradient(gradient: Gradient(colors: [Color.white, Color("LightBlueColor")]), startPoint: .topLeading, endPoint: .bottom)
                    .mask(
                        Image(uiImage: folder.image).resizable().aspectRatio(contentMode: .fit)
                    ).frame(width: 30, height: 30, alignment: .leading)
                
                /// Folder title and items count
                VStack(alignment: .leading) {
                    Text(folder.name).bold().font(.system(size: 18))
                        .foregroundColor(Color("ExtraDarkGrayColor"))
                }.lineLimit(1).multilineTextAlignment(.leading)
                
                Spacer()
                Button(action: {
                    UIImpactFeedbackGenerator().impactOccurred()
                    self.show.toggle()
                }, label: {
                    Image(systemName: "ellipsis").rotationEffect(.degrees(90))
                        .font(.system(size: 16))
                        .foregroundColor(Color("ExtraDarkGrayColor"))
                })
                .alert("Rename Folder", isPresented: $showingAlertEdit) {
                    TextField("Rename name", text: $name)
                    Button("Later", role: .cancel){}
                    Button("Rename", action: rename)
                } message: {
                    Text("Rename folder name")
                }
                .alert("Folder \(folder.name) will be deleted", isPresented: $showingAlertDelete) {
                    Button("Later", role: .cancel){}
                    Button("Delete", action: delete)
                }
                .alert("Failed\n\(errorMessage)", isPresented: $showingAlertError) {
                    Button("OK", role: .cancel) { }
                }
                .frame(width: 20, height: 20)
            }
        }
        .actionSheet(isPresented: $show) {
            ActionSheet(
                title: Text("Actions"),
                message: Text("Available actions"),
                buttons: [
                    .cancel { self.show = false},
                    .default(Text("Rename")) {
                        self.show = false
                        self.showingAlertEdit.toggle()
                    },
                    .destructive(Text("Delete")) {
                        self.show = false
                        self.showingAlertDelete.toggle()
                    }
                ]
            )
        }
        .onAppear{
            self.name = folder.name
        }
        .padding(.horizontal)
        
    }
    private func rename() {
        if folder.type == .folder {
            errorMessage = utility.renameFolder(atPath: folder.url, newName: name)
            if (errorMessage != "") {
                self.showingAlertError.toggle()
            }
        }
        
        if folder.type == .pdf {
            errorMessage = utility.renameFile(atPath: folder.url, newName: name)
            if (errorMessage != "") {
                self.showingAlertError.toggle()
            }
        }
        self.name = ""
        handler()
    }
    
    private func delete() {
        errorMessage = utility.delete(url: folder.url)
        if (errorMessage != "") {
            self.showingAlertError.toggle()
        }
        handler()
    }
    
}


#Preview {
    let myFileInstance = File(fileUrl: URL(fileURLWithPath: "/path/to/example"))
    return FolderView(folder: myFileInstance, handler: {})
        .environmentObject(DataManager())
}
