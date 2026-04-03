//
//  AddTaskView.swift
//  ScavengerHuntTeaser
//
//  Created by Brianna Thelwell on 4/4/26.
//

import SwiftUI

struct AddTaskView: View {
    
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var showingAlert = false
    var onTaskAdded: (Task) -> Void
    
    var body: some View {
        
        NavigationView {
            
            Form {
                
                Section(header: Text("Task Details")) {
                    TextField("Task Title", text: $title)
                        .textInputAutocapitalization(.words)
                    
                    TextField("Description", text: $description)
                        .textInputAutocapitalization(.sentences)
                        .lineLimit(3...6)
                    
                }
                
                Section(footer: Text("Create your own scavenger hunt task. Add a photo later to complete it!")) {
                    EmptyView()
                    
                }
                
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        
                        dismiss()
                        
                    }
                    
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    
                    Button("Add") {
                        
                        addTask()
                        
                    }
                    .disabled(title.isEmpty || description.isEmpty)
                    
                }
                
            }
            
            .alert("Invalid Task", isPresented: $showingAlert) {
                
                Button("OK", role: .cancel) { }
                
            } message: {
                
                Text("Please enter both a title and description for your task.")
                
            }
            
        }
        
    }
    
    //I dont need an add task button but i imagine adding stuff to your scavenger list might be fun
    private func addTask() {
        
        guard !title.isEmpty && !description.isEmpty else {
            
            showingAlert = true
            return
            
        }
        
        let newTask = Task(
            
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            isCustom: true
        )
        
        onTaskAdded(newTask)
        dismiss()
    }
}
