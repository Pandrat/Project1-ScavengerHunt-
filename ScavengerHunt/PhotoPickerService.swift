//
//  PhotoPickerService.swift
//  ScavengerHunt
//
//  Created by Brianna Thelwell on 4/4/26.
//

import SwiftUI
import PhotosUI
import CoreLocation
import UIKit
import ImageIO

struct PhotoPicker: UIViewControllerRepresentable {
    
    @Binding var selectedImage: UIImage?
    @Binding var imageLocation: CLLocationCoordinate2D?
    var onPhotoPicked: () -> Void
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
        
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
        
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        
        let parent: PhotoPicker
        
        init(_ parent: PhotoPicker) {
            
            self.parent = parent
            
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            
            picker.dismiss(animated: true)
            
            guard let result = results.first else { return }
            
            let itemProvider = result.itemProvider
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                
                itemProvider.loadObject(ofClass: UIImage.self) {
                    
                    [weak self] image, error in
                    DispatchQueue.main.async {
                        
                        if let uiImage = image as? UIImage {
                            
                            self?.parent.selectedImage = uiImage
                            
                            // Try to get location from photo metadata
                            self?.extractLocation(from: result, completion: { location in
                                self?.parent.imageLocation = location
                                self?.parent.onPhotoPicked()
                            })
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
        private func extractLocation(from result: PHPickerResult, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
            
            result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { url, error in
                guard let url = url else {
                    
                    DispatchQueue.main.async {
                        
                        completion(nil)
                        
                    }
                    
                    return
                    
                }
                
                if let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil),
                   let metadata = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any],
                   let gpsData = metadata[kCGImagePropertyGPSDictionary as String] as? [String: Any] {
                    
                    let latitude = gpsData[kCGImagePropertyGPSLatitude as String] as? Double ?? 0
                    let longitude = gpsData[kCGImagePropertyGPSLongitude as String] as? Double ?? 0
                    let latitudeRef = gpsData[kCGImagePropertyGPSLatitudeRef as String] as? String ?? "N"
                    let longitudeRef = gpsData[kCGImagePropertyGPSLongitudeRef as String] as? String ?? "E"
                    
                    var finalLatitude = latitude
                    var finalLongitude = longitude
                    
                    if latitudeRef == "S" { finalLatitude = -latitude }
                    if longitudeRef == "W" { finalLongitude = -longitude }
                    
                    DispatchQueue.main.async {
                        
                        completion(CLLocationCoordinate2D(latitude: finalLatitude, longitude: finalLongitude))
                        
                    }
                    
                } else {
                    
                    DispatchQueue.main.async {
                        
                        completion(nil)
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
}
