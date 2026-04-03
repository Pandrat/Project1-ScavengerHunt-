//
//  TaskDetailView.swift
//  ScavengerHunt
//
//  Created by Brianna Thelwell on 4/4/26.
//

import SwiftUI
import MapKit

struct TaskDetailView: View {
    
    let task: Task
    let onTaskUpdated: () -> Void
    @State private var showingPhotoPicker = false
    @State private var selectedImage: UIImage?
    @State private var imageLocation: CLLocationCoordinate2D?
    @State private var currentTask: Task
    @State private var region: MKCoordinateRegion
    @State private var showingLocationAlert = false
    @State private var showCompletionAnimation = false
    
    init(task: Task, onTaskUpdated: @escaping () -> Void) {
        
        self.task = task
        self.onTaskUpdated = onTaskUpdated
        _currentTask = State(initialValue: task)
        
        // Default region
        //having a default in case i forgot to add the location info
        //precaution when debugging
        let defaultLocation = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        _region = State(initialValue: MKCoordinateRegion(
            center: task.photoLocation ?? defaultLocation,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
        
    }
    
    var body: some View {
        
        ScrollView {
            
            VStack(alignment: .leading, spacing: 20) {
                
                // Task Info with bubble styling
                //had to keep adjusting the bubbles bc they weren't working at first
                //first model didnt even have bubbles
                VStack(alignment: .leading, spacing: 15) {
                    
                    Text(currentTask.title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(currentTask.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                    
                }
                
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal)
                
                // Photo Section with bubble styling
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        
                        Image(systemName: "camera.fill")
                            .foregroundColor(.mint)
                        Text("Photo")
                            .font(.headline)
                        
                    }
                    
                    if let photoData = currentTask.photoData,
                       let image = UIImage(data: photoData) {
                        
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 250)
                            .cornerRadius(15)
                            .shadow(color: Color.black.opacity(0.1), radius: 5)
                        
                    } else {
                        
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 200)
                            .overlay(
                                VStack(spacing: 10) {
                                    Image(systemName: "photo")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                    Text("No photo attached")
                                        .foregroundColor(.gray)
                                    
                                }
                                
                            )
                        
                    }
                    
                    Button(action: {
                        
                        showingPhotoPicker = true
                        
                    }) {
                        
                        HStack {
                            
                            Image(systemName: currentTask.isCompleted ? "arrow.triangle.2.circlepath.camera.fill" : "camera.fill")
                            Text(currentTask.isCompleted ? "Change Photo" : "Attach Photo")
                                .fontWeight(.semibold)
                            
                        }
                        
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.mint)
                                .shadow(color: Color.mint.opacity(0.3), radius: 5)
                        )
                        .foregroundColor(.white)
                        
                    }
                    
                }
                
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal)
                
                if currentTask.isCompleted && currentTask.photoLocation != nil {
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // Map Section with photo annotation
                    //the photo makes it like the lab
                    VStack(alignment: .leading, spacing: 15) {
                        
                        HStack {
                            
                            Image(systemName: "map.fill")
                                .foregroundColor(.pink)
                            Text("Photo Location")
                                .font(.headline)
                            
                        }
                        
                        CustomMapView(
                            coordinate: currentTask.photoLocation!,
                            photoImage: UIImage(data: currentTask.photoData ?? Data())
                        )
                        .frame(height: 400)
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.1), radius: 10)
                        
                    }
                    
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    )
                    .padding(.horizontal)
                    
                    // Completion Animation
                    //it's completed yayyyy this better work
                    if showCompletionAnimation {
                        
                        HStack {
                            
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.green)
                                .font(.title2)
                            Text("Task Completed!")
                                .font(.headline)
                                .foregroundColor(.green)
                            
                        }
                        
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.green.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.green, lineWidth: 1)
                                )
                        )
                        .padding(.horizontal)
                        .transition(.scale.combined(with: .opacity))
                        
                    }
                    
                }
                
            }
            
            .padding(.vertical)
            
        }
        
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Task Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingPhotoPicker) {
            
            PhotoPicker(selectedImage: $selectedImage, imageLocation: $imageLocation, onPhotoPicked: {
                
                if let image = selectedImage {
                    
                    if let location = imageLocation {
                        
                        // Update the task
                        currentTask.complete(with: image.jpegData(compressionQuality: 0.8) ?? Data(), location: location)
                        
                        // Update the region to show the new location
                        //the animation does send you out of the task before showing you but you can fgo back in
                        withAnimation {
                            
                            region.center = location
                            
                        }
                        
                        // Show completion animation
                        withAnimation {
                            
                            showCompletionAnimation = true
                            
                        }
                        
                        // Hide animation after 2 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            
                            withAnimation {
                                
                                showCompletionAnimation = false
                                
                            }
                            
                        }
                        
                        // Save and notify
                        //but doesn't navigate back
                        saveUpdatedTask()
                        
                        // Reset selection
                        selectedImage = nil
                        imageLocation = nil
                        
                    } else {
                        
                        showingLocationAlert = true
                        
                    }
                    
                }
                
            })
            
        }
        
        .alert("No Location Data", isPresented: $showingLocationAlert) {
            Button("OK", role: .cancel) { }
            
        } message: {
            
            Text("The selected photo doesn't contain location metadata. Please select a photo with location data enabled in your camera settings.")
            
        }
        
    }
    
    private func saveUpdatedTask() {
        
        // Save to UserDefaults
        let userDefaults = UserDefaults.standard
        
        // Get existing completed IDs
        var completedIDs = userDefaults.array(forKey: "completedTaskIDs") as? [String] ?? []
        
        if !completedIDs.contains(currentTask.id.uuidString) {
            
            completedIDs.append(currentTask.id.uuidString)
            
        }
        
        // Save the photo data
        if let photoData = currentTask.photoData {
            
            userDefaults.set(photoData, forKey: "photoData_\(currentTask.id.uuidString)")
            
        }
        
        // Save location
        if let location = currentTask.photoLocation {
            
            let locationDict = ["latitude": location.latitude, "longitude": location.longitude]
            userDefaults.set(locationDict, forKey: "photoLocation_\(currentTask.id.uuidString)")
            
        }
        
        userDefaults.set(completedIDs, forKey: "completedTaskIDs")
        userDefaults.synchronize()
        
        // Notify that task was updated but don't navigate back
        //should've made it naviagte back but i was having issues with it
        onTaskUpdated()
        
    }
    
}

// Custom Map View with Image Annotation
struct CustomMapView: UIViewRepresentable {
    
    let coordinate: CLLocationCoordinate2D
    let photoImage: UIImage?
    
    func makeUIView(context: Context) -> MKMapView {
        
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        
        // Set initial region
        let region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        mapView.setRegion(region, animated: false)
        
        // Add custom annotations
        let annotation = CustomAnnotation(
            coordinate: coordinate,
            title: "Photo Location",
            image: photoImage
        )
        mapView.addAnnotation(annotation)
        
        return mapView
        
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        
        // Update annotation if needed
        //won't be using this in the video i make honestly
        mapView.removeAnnotations(mapView.annotations)
        let annotation = CustomAnnotation(
            coordinate: coordinate,
            title: "Photo Location",
            image: photoImage
        )
        mapView.addAnnotation(annotation)
        
    }
    
    func makeCoordinator() -> Coordinator {
        
        Coordinator()
        
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
            guard let customAnnotation = annotation as? CustomAnnotation else {
                
                return nil
                
            }
            
            let identifier = "PhotoAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                
                annotationView = MKAnnotationView(annotation: customAnnotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                
            } else {
                
                annotationView?.annotation = customAnnotation
                
            }
            
            // Create custom pin with photo
            //cute little photos to make the thing cutesy
            if let image = customAnnotation.image {
                
                // Resize image to fit in pin
                let size = CGSize(width: 50, height: 50)
                let renderer = UIGraphicsImageRenderer(size: size)
                let resizedImage = renderer.image { context in
                    image.draw(in: CGRect(origin: .zero, size: size))
                    
                }
                
                // Create a custom view with image
                let containerView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 60, height: 60)))
                containerView.backgroundColor = .white
                containerView.layer.cornerRadius = 30
                containerView.layer.borderWidth = 2
                containerView.layer.borderColor = UIColor.gray.cgColor
                containerView.layer.shadowColor = UIColor.black.cgColor
                containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
                containerView.layer.shadowRadius = 4
                containerView.layer.shadowOpacity = 0.3
                
                let imageView = UIImageView(image: resizedImage)
                imageView.frame = CGRect(x: 5, y: 5, width: 50, height: 50)
                imageView.layer.cornerRadius = 25
                imageView.clipsToBounds = true
                imageView.contentMode = .scaleAspectFill
                containerView.addSubview(imageView)
                
                annotationView?.addSubview(containerView)
                annotationView?.frame = containerView.frame
                
            } else {
                
                // Fallback to default pin
                //this is pushing a yellow warning bc it depreciated
                //but for now i'll keep it cuz it works
                let pinView = MKPinAnnotationView(annotation: customAnnotation, reuseIdentifier: identifier)
                pinView.pinTintColor = UIColor.systemPink
                pinView.canShowCallout = true
                return pinView
                
            }
            
            return annotationView
            
        }
        
    }
    
}


// Custom Annotation Class
//if aint broke dont fix it
//and without it something broke so it stays
//never cut corners fr i tried to slim down annotations and threw tons of errors
class CustomAnnotation: NSObject, MKAnnotation {
    
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let image: UIImage?
    
    init(coordinate: CLLocationCoordinate2D, title: String?, image: UIImage?) {
        
        self.coordinate = coordinate
        self.title = title
        self.image = image
        super.init()
        
    }
    
}
