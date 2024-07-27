//
//  ContentView.swift
//  Sticki
//
//  Created by Evil on 2024/04/26.
//

import PhotosUI
import SwiftUI

struct ContentView: View {
    //@Binding var photoLibraryManager: PhotoLibraryManager
    @State private var albumNames: [String] = []
    @State private var selectedAlbums: [String: Bool] = [:] {
        didSet {
            UserDefaults.standard.setValue(selectedAlbums, forKey: "selectedAlbums")
        }
    }
    @State private var thumbnails: [String: NSImage] = [:]
    @State private var selected: String = "" {
        didSet {
            UserDefaults.standard.set(selected, forKey: "selectedAlbum")
        }
    }

    init() {
        _selected = State(initialValue: UserDefaults.standard.string(forKey: "selectedAlbum") ?? "")
        _selectedAlbums = State(initialValue: UserDefaults.standard.dictionary(forKey: "selectedAlbums") as? [String: Bool] ?? [:])
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if albumNames.isEmpty {
                Text("Loading albums...")
                    .onAppear{
                        fetchUserCreatedAlbums()
                    }
            } else {
                if selected == "" {
                            List{
                            ForEach(albumNames, id: \.self) { albumName in
                                    HStack{
                                        Toggle(albumName, isOn: Binding(
                                            get: { selectedAlbums[albumName, default: false] },
                                            set: { selectedAlbums[albumName] = $0 }
                                        ))
                                        .toggleStyle(.switch)
                                    }
                                }
                            }
                            .background(BlurWindow())
                } else {
                    PhotoGridView(albumName: $selected)
                }
                /*
                switch selected {
                case "":
                        List{
                        ForEach(albumNames, id: \.self) { albumName in
                                HStack{
                                    Toggle(albumName, isOn: Binding(
                                        get: { selectedAlbums[albumName, default: false] },
                                        set: { selectedAlbums[albumName] = $0 }
                                    ))
                                }
                            }
                        }
                case let albumName where albumNames.contains(albumName):
                        //PhotoGridView(albumName: albumName)
                    Text(albumName)
                default:
                    Text("Invalid Selection")
                }
                 */
                HStack {
                    ScrollView(.horizontal) {
                        HStack(spacing: 20) {
                            ForEach(albumNames, id: \.self) { albumName in
                                if  selectedAlbums[albumName] ?? false {
                                if let img = thumbnails[albumName] {
                                    ZStack {
                                        Image(nsImage: img)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 30, height: 30)
                                            .clipped()
                                            .saturation(selected == albumName ? 1 : 0)
                                            .onTapGesture{
                                                selected = albumName
                                                print(selected)
                                            }
                                        Circle()
                                            .fill(selected == albumName ? Color.accentColor : Color.clear)
                                            .frame(width: 5, height: 5)
                                            .offset(y: 15)
                                    }
                                }
                                }
                            }
                        }
                    }
                    Spacer()
                    Image(systemName: "gear")
                        .resizable()
                        .frame(width: 18, height: 18)
                        .foregroundColor(selected == "" ? Color.accentColor : nil)
                        .onTapGesture {
                            selected = ""
                        }
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .onChange(of: selected) {
                    print("Selected album: \(selected)")
                }
            }
        }
    }
    
    
    private func fetchUserCreatedAlbums() {
        let fetchOptions = PHFetchOptions()
        let albums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: fetchOptions)

        albums.enumerateObjects { (collection, _, _) in
            if let title = collection.localizedTitle {
                albumNames.append(title)
                fetchFirstPhoto(for: collection, albumName: title)
            }
        }
    }
    
    private func fetchFirstPhoto(for collection: PHAssetCollection, albumName: String) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 1

        let assets = PHAsset.fetchAssets(in: collection, options: fetchOptions)

        if let firstAsset = assets.firstObject {
            let imageManager = PHImageManager.default()
            let requestOptions = PHImageRequestOptions()
            requestOptions.isSynchronous = true

            imageManager.requestImage(for: firstAsset, targetSize: CGSize(width: 50, height: 50), contentMode: .aspectFill, options: requestOptions) { image, _ in
                thumbnails[albumName] = image
            }
        }
    }
}
