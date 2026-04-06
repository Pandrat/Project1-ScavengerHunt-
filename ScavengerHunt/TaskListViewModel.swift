//
//  TaskListViewModel.swift
//  ScavengerHunt
//
//  Created by Brianna Thelwell on 4/4/26.
//

import SwiftUI
import Combine
import CoreLocation

class TaskListViewModel: ObservableObject {
    
    @Published var tasks: [Task] = []
    private let userDefaults = UserDefaults.standard
    private let hasLoadedKey = "hasLoadedInitialTasks"
    private let customTasksKey = "customTasks"
    
    init() {
        
        loadTasks()
        
    }
    
    func loadTasks() {
        
        // Check if we've already loaded initial tasks
        //just in case
        let hasLoaded = userDefaults.bool(forKey: hasLoadedKey)
        
        if !hasLoaded {
            
            // Create hardcoded tasks only once
            //Reason: I had a lopping hardcoded task issue????
            let hardcodedTasks = [
                Task(title: "Your Favorite Book", description: "What is the book you love the most?", isCustom: false),
                Task(title: "Your favorite collectible", description: "You've been collecting them for so long. Which is your favorite in the collection?", isCustom: false),
                Task(title: "Your favorite Boba shop", description: "Where do you grab your go-to drink?", isCustom: false),
                Task(title: "Your Favorite Game", description: "What's your favorite game?", isCustom: false)
            ]
            
            tasks = hardcodedTasks
            saveTasksToUserDefaults()
            userDefaults.set(true, forKey: hasLoadedKey)
            
        } else {
            
            // Load existing tasks from UserDefaults
            loadTasksFromUserDefaults()
            
        }
        
        // Load custom tasks
        //these are for fun
        loadCustomTasks()
        
    }
    
    func addCustomTask(_ task: Task) {
        
        tasks.append(task)
        saveCustomTasks()
        objectWillChange.send()
        
    }
    
    func deleteCustomTask(_ task: Task) {
        
        tasks.removeAll { $0.id == task.id && $0.isCustom }
        saveCustomTasks()
        
    }
    
    private func loadCustomTasks() {
        
        if let customTasksData = userDefaults.data(forKey: customTasksKey),
           let customTasks = try? JSONDecoder().decode([CustomTaskData].self, from: customTasksData) {
            
            for customTaskData in customTasks {
                
                let task = Task(
                    id: customTaskData.id,
                    title: customTaskData.title,
                    description: customTaskData.description,
                    isCustom: true,
                    isCompleted: customTaskData.isCompleted
                )
                
                // Load photo data if exists - THIS WAS MISSING
                if customTaskData.isCompleted {
                    
                    if let photoData = userDefaults.data(forKey: "photoData_\(task.id.uuidString)") {
                        
                        task.photoData = photoData
                        
                    }
                    
                    if let locationDict = userDefaults.dictionary(forKey: "photoLocation_\(task.id.uuidString)") as? [String: Double] {
                        task.setLocationFromDictionary(locationDict)
                    }
                    
                }
                
                if !tasks.contains(where: { $0.id == task.id }) {
                    
                    tasks.append(task)
                    
                }
                
            }
            
        }
        
    }
    
    func saveCustomTasks() {
        
        let customTasks = tasks.filter { $0.isCustom }
        let customTasksData = customTasks.map { task in
            CustomTaskData(
                id: task.id,
                title: task.title,
                description: task.description,
                isCompleted: task.isCompleted,
                hasPhotoData: task.photoData != nil,
                hasLocationData: task.photoLocation != nil
            )
            
        }
        
        if let encoded = try? JSONEncoder().encode(customTasksData) {
            
            userDefaults.set(encoded, forKey: customTasksKey)
            
        }
        
    }
    
    private func saveTasksToUserDefaults() {
        
        // Save task completion statuses
        var completedIDs: [String] = []
        
        for task in tasks {
            
            if task.isCompleted {
                
                completedIDs.append(task.id.uuidString)
                
            }
            
            // Save photo data if exists
            if let photoData = task.photoData {
                
                userDefaults.set(photoData, forKey: "photoData_\(task.id.uuidString)")
                
            }
            
            // Save location if exists
            if let locationDict = task.locationDictionary() {
                
                userDefaults.set(locationDict, forKey: "photoLocation_\(task.id.uuidString)")
                
            }
            
        }
        
        userDefaults.set(completedIDs, forKey: "completedTaskIDs")
        
        // Save the task infos for default tasks
        //i complicated stuff adding in custom tasks FS
        let defaultTasks = tasks.filter { !$0.isCustom }
        var taskInfos: [[String: String]] = []
        for task in defaultTasks {
            
            taskInfos.append([
                "id": task.id.uuidString,
                "title": task.title,
                "description": task.description
            ])
            
        }
        
        userDefaults.set(taskInfos, forKey: "savedTaskInfos")
        userDefaults.synchronize()
        
    }
    
    private func loadTasksFromUserDefaults() {
        
        // Load default task infos
        guard let taskInfos = userDefaults.array(forKey: "savedTaskInfos") as? [[String: String]] else {
            
            loadHardcodedTasks()
            return
            
        }
        
        var loadedTasks: [Task] = []
        let completedIDs = userDefaults.array(forKey: "completedTaskIDs") as? [String] ?? []
        
        for taskInfo in taskInfos {
            
            guard let idString = taskInfo["id"],
                  let title = taskInfo["title"],
                  let description = taskInfo["description"],
                  let id = UUID(uuidString: idString) else {
                continue
                
            }
            
            let isCompleted = completedIDs.contains(idString)
            var photoData: Data? = nil
            var photoLocation: CLLocationCoordinate2D? = nil
            
            if isCompleted {
                
                photoData = userDefaults.data(forKey: "photoData_\(idString)")
                if let locationDict = userDefaults.dictionary(forKey: "photoLocation_\(idString)") as? [String: Double] {
                    
                    photoLocation = CLLocationCoordinate2D(
                        latitude: locationDict["latitude"] ?? 0,
                        longitude: locationDict["longitude"] ?? 0
                    )
                    
                }
                
            }
            
            let task = Task(
                
                id: id,
                title: title,
                description: description,
                isCustom: false,
                isCompleted: isCompleted,
                photoData: photoData,
                photoLocation: photoLocation
            )
            loadedTasks.append(task)
            
        }
        
        if !loadedTasks.isEmpty {
            
            tasks = loadedTasks
            
        } else {
            
            loadHardcodedTasks()
            
        }
        
    }
    
    //this was the cause of the duplicating tasks
    //but for some reaosn when i removed it and related stuff my thing crashed
    //tried to get it gone but it didnt wokr
    //so it's here for structure ig
    //maybe it wasnt the issuea and the let was
    //i'll figure it out one day
    private func loadHardcodedTasks() {
        
        tasks = [
            Task(title: "Your Favorite Book", description: "What is the book you love the most?", isCustom: false),
            Task(title: "Your favorite collectible", description: "You've been collecting them for so long. Which is your favorite in the collection?", isCustom: false),
            Task(title: "Your favorite Boba shop", description: "Where do you grab your go-to drink?", isCustom: false),
            Task(title: "Your Favorite Game", description: "What's your favorite game?", isCustom: false)
        ]
        
    }
    
    func updateTask(_ updatedTask: Task) {
        
        if let index = tasks.firstIndex(where: { $0.id == updatedTask.id }) {
            
            tasks[index] = updatedTask
            saveSingleTask(updatedTask)
            
            if updatedTask.isCustom {
                
                saveCustomTasks()
                
            }
            
        }
        
    }
    
    private func saveSingleTask(_ task: Task) {
        
        // Update completed IDs
        var completedIDs = userDefaults.array(forKey: "completedTaskIDs") as? [String] ?? []
        
        if task.isCompleted {
            
            if !completedIDs.contains(task.id.uuidString) {
                
                completedIDs.append(task.id.uuidString)
                
            }
            
            // Save photo data
            if let photoData = task.photoData {
                
                userDefaults.set(photoData, forKey: "photoData_\(task.id.uuidString)")
                
            }
            
            // Save location
            if let locationDict = task.locationDictionary() {
                
                userDefaults.set(locationDict, forKey: "photoLocation_\(task.id.uuidString)")
                
            }
            
        } else {
            
            completedIDs.removeAll { $0 == task.id.uuidString }
            userDefaults.removeObject(forKey: "photoData_\(task.id.uuidString)")
            userDefaults.removeObject(forKey: "photoLocation_\(task.id.uuidString)")
            
        }
        
        userDefaults.set(completedIDs, forKey: "completedTaskIDs")
        userDefaults.synchronize()
        
    }
    
}

// Codable struct for saving custom tasks
//this bit finally works thank GOD
struct CustomTaskData: Codable {
    
    let id: UUID
    let title: String
    let description: String
    let isCompleted: Bool
    let hasPhotoData: Bool
    let hasLocationData: Bool
    
}
