//
//  Task.swift
//  ScavengerHunt
//
//  Created by Brianna Thelwell on 4/4/26.
//

import Foundation
import CoreLocation
import Combine

class Task: Identifiable, ObservableObject {
    
    let id: UUID
    let title: String
    let description: String
    var isCustom: Bool  // seperating the custom ones from the others
    @Published var isCompleted: Bool
    @Published var photoData: Data?
    @Published var photoLocation: CLLocationCoordinate2D?
    
    init(id: UUID = UUID(), title: String, description: String, isCustom: Bool = false, isCompleted: Bool = false, photoData: Data? = nil, photoLocation: CLLocationCoordinate2D? = nil) {
        
        self.id = id
        self.title = title
        self.description = description
        self.isCustom = isCustom
        self.isCompleted = isCompleted
        self.photoData = photoData
        self.photoLocation = photoLocation
        
    }
    
    func complete(with photoData: Data, location: CLLocationCoordinate2D?) {
        
        self.photoData = photoData
        self.photoLocation = location
        self.isCompleted = true
        
    }
    
    // Helper to convert location to dictionary for storage
    //mostly cuz i was trying to figure out how to get around using this and it fell apart in my face
    func locationDictionary() -> [String: Double]? {
        
        guard let location = photoLocation else { return nil }
        return ["latitude": location.latitude, "longitude": location.longitude]
        
    }
    
    // Helper to restore location from dictionary
    //dictionary saves time  lowkenuinely
    func setLocationFromDictionary(_ dict: [String: Double]) {
        
        if let latitude = dict["latitude"], let longitude = dict["longitude"] {
            
            self.photoLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
        }
        
    }
    
}

