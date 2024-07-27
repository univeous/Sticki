import SwiftUI
import Photos
import SDWebImageSwiftUI

extension PHAsset: Identifiable {
    public var id: String {
        self.localIdentifier
    }
}

struct PhotoGridView: View {
    @State private var photoAssets: [PHAsset] = []
    @Binding var albumName:String

    var body: some View {
        if albumName != ""{
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 100)), count: 3), spacing: 10) {
                    ForEach(photoAssets) { asset in
                        PhotoThumbnailView(asset: asset)
                            .aspectRatio(1, contentMode: .fill)
                            .clipped()
                    }
                }
                .padding()
            }
            //.navigationTitle("Photo Grid")
            .onAppear(perform: loadAlbum)
            .onChange(of: albumName) {
                loadAlbum()
            }
            .background(BlurWindow())
            .onDrop(of: ["public.image"], isTargeted: nil){ providers in
                handleDrop(providers: providers)
            }
        }
    }
    
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        var shouldReturnFalse = false
        
        for provider in providers {
            //print(provider)
            if provider.hasItemConformingToTypeIdentifier("public.image") {
                provider.loadItem(forTypeIdentifier: "public.image", options: nil) { item, error in
                    //print(item)
                    if let url = item as? URL {
                        photoAssets.forEach{asset in
                            let res = PHAssetResource.assetResources(for: asset).first
                            //print(res?.assetLocalIdentifier)
                            if let exists = res?.assetLocalIdentifier.contains(url.lastPathComponent.split(separator: ".")[0]), exists {
                                shouldReturnFalse = true
                            }
                        }
                        if shouldReturnFalse {
                            return
                        }
                        DispatchQueue.main.async {
                            saveURLToAlbum(url: url, completion: loadAlbum)
                        }
                    }
                    else if let data = item as? Data, let tempURL = saveDataToTemporaryURL(data: data, provider: provider) {
                        DispatchQueue.main.async {
                            saveURLToAlbum(url: tempURL, completion: loadAlbum)
                        }
                    }
                }
                return shouldReturnFalse ? false : true
            }
        }
        return false
    }
    
    private func saveURLToAlbum(url: URL, completion: @escaping () -> Void) {
        PHPhotoLibrary.shared().performChanges {
            //let creationRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let creationRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: url)
            if let album = fetchAlbum(named: albumName) {
                if let albumChangeRequest = PHAssetCollectionChangeRequest(for: album) {
                    albumChangeRequest.addAssets([creationRequest?.placeholderForCreatedAsset] as NSArray)
                }
            }
        } completionHandler: { success, error in
            if success {
                print("Image saved to album successfully")
                completion()
            } else if let error = error {
                print("Error saving image to album: \(error.localizedDescription)")
            }
        }
    }
    
    private func saveDataToTemporaryURL(data: Data, provider: NSItemProvider) -> URL? {
        let tempDirectory = FileManager.default.temporaryDirectory
        let identifier = provider.registeredTypeIdentifiers.first ?? "public.data"
        let fileExtension = identifier.components(separatedBy: ".").last ?? "data"
        
        let tempURL = tempDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension(fileExtension)
        do {
            try data.write(to: tempURL)
            return tempURL
        } catch {
            print("Error saving data to temporary URL: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func fetchAlbum(named name: String) -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", name)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: fetchOptions)
        return collection.firstObject
    }

    private func loadAlbum() {
        if let album = fetchAlbum(named: albumName) {
            loadPhotos(from: album)
        }
    }

    private func loadPhotos(from album: PHAssetCollection) {
        let assets = PHAsset.fetchAssets(in: album, options: nil)
        var fetchedAssets: [PHAsset] = []
        
        assets.enumerateObjects { (asset, _, _) in
            fetchedAssets.append(asset)
        }
        
        fetchedAssets.sort { (asset1, asset2) -> Bool in
            guard let date1 = asset1.creationDate, let date2 = asset2.creationDate else {
                return false
            }
            return date1 < date2
        }
        
        DispatchQueue.main.async {
            self.photoAssets = fetchedAssets
        }
    }
}

struct PhotoThumbnailView: View {
    let asset: PHAsset
    @State private var assetURL: URL?
    @State private var image:NSImage?
    
    var body: some View {
            Group {
                if let url = assetURL {
                    WebImage(url: url)
                        .onSuccess{ image, _, _ in
                            DispatchQueue.main.async {
                                self.image = image
                            }
                        }
                        .resizable()
                        .indicator(.activity)
                        .aspectRatio(contentMode: .fit)
                        //.frame(width: geometry.size.width, height: geometry.size.height)
                        .onDrag{
                            if self.image != nil {
                                //return NSItemProvider(object: img)
                                if let cacheKey = SDWebImageManager.shared.cacheKey(for: url) {
                                    let provider = NSItemProvider(object: NSString(string: cacheKey))
                                    //provider.setValue(Bundle.main.bundleIdentifier, forKey: "identifier")
                                    return provider
                                } else{
                                    return NSItemProvider()
                                }
                            } else {
                                return NSItemProvider()
                            }
                        }
                } else {
                    Color.gray
                }
            }
        .onAppear {
            getAssetURL()
        }
    }
    
    private func getAssetURL() {
        let options = PHContentEditingInputRequestOptions()
        options.isNetworkAccessAllowed = true
        asset.requestContentEditingInput(with: options) { (input, _) in
            if let url = input?.fullSizeImageURL {
                DispatchQueue.main.async {
                    self.assetURL = url
                }
            }
        }
    }
}
