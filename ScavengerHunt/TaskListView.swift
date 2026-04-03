//
//  TaskListView.swift
//  ScavengerHunt
//
//  Created by Brianna Thelwell on 4/4/26.
//

import SwiftUI

struct TaskListView: View {
    
    @StateObject private var viewModel = TaskListViewModel()
    @State private var refreshID = UUID()
    @State private var showingAddTask = false
    
    var body: some View {
        
        NavigationView {
            
            ScrollView {
                
                LazyVStack(spacing: 16) {
                    
                    // Custom Tasks Section (if any)
                    //just thought it'd be nice to have
                    let customTasks = viewModel.tasks.filter {
                        $0.isCustom }
                    if !customTasks.isEmpty {
                        
                        SectionHeader(title: "My Custom Scavenger Hunt Spots", icon: "star.fill")
                            .padding(.top, 8)
                        
                        ForEach(customTasks) { task in
                            NavigationLink(destination: TaskDetailView(task: task, onTaskUpdated: {
                                refreshID = UUID()
                                viewModel.loadTasks()
                            })) {
                                
                                TaskBubbleView(task: task)
                                
                            }
                            
                            .buttonStyle(PlainButtonStyle())
                            
                        }
                        
                    }
                    
                    // Default Tasks Section
                    let defaultTasks = viewModel.tasks.filter { !$0.isCustom }
                    if !defaultTasks.isEmpty {
                        
                        if !customTasks.isEmpty {
                            
                            SectionHeader(title: "Photo Scavenger Hunt Tasks", icon: "map.fill")
                            
                        }
                        
                        ForEach(defaultTasks) { task in
                            NavigationLink(destination: TaskDetailView(task: task, onTaskUpdated: {
                                refreshID = UUID()
                                viewModel.loadTasks()
                            })) {
                                
                                TaskBubbleView(task: task)
                                
                            }
                            
                            .buttonStyle(PlainButtonStyle())
                            
                        }
                        
                    }
                    
                }
                
                .padding(.horizontal)
                .padding(.vertical, 8)
                
            }
            
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Photo Scavenger Hunt")
            .id(refreshID)
            .onAppear {
                
                viewModel.loadTasks()
                
            }
            .toolbar {
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    
                    Button(action: {
                        
                        showingAddTask = true
                        
                    }) {
                        
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.mint)
                        
                    }
                    
                }
                
            }
            
            .sheet(isPresented: $showingAddTask) {
                
                AddTaskView { newTask in
                    viewModel.addCustomTask(newTask)
                    refreshID = UUID()
                    
                }
                
            }
            
        }
        
    }
    
}

// Section Header Component
struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.mint)
                .font(.subheadline)
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
}

// Custom Bubble View for Tasks
struct TaskBubbleView: View {
    
    let task: Task
    
    var body: some View {
        
        HStack(spacing: 15) {
            
            // Completion Indicator Circle
            ZStack {
                
                Circle()
                    .fill(task.isCompleted ? Color.green : (task.isCustom ? Color.mint.opacity(0.2) : Color.gray.opacity(0.2)))
                    .frame(width: 30, height: 30)
                
                if task.isCompleted {
                    
                    Image(systemName: "checkmark")
                            .foregroundColor(.white)
                            .font(.system(size: 15, weight: .bold))
                    
                }
                
            }
            
            // Task Info
            VStack(alignment: .leading, spacing: 6) {
                
                HStack {
                    
                    Text(task.title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    if task.isCustom && !task.isCompleted {
                        
                        Text("Custom")
                            .font(.system(size: 10, weight: .medium))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.mint.opacity(0.1))
                            .foregroundColor(.mint)
                            .cornerRadius(8)
                        
                    }
                    
                }
                
                Text(task.description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                if task.isCompleted {
                    
                    HStack(spacing: 4) {
                        
                        Image(systemName: "location.fill")
                            .font(.system(size: 10))
                        Text("Photo captured")
                            .font(.system(size: 12))
                        
                    }
                    
                    .foregroundColor(.green)
                    .padding(.top, 2)
                    
                }
                
            }
            
            Spacer()
            
            // Arrow Indicator
            // i think this setup is alot cuter than a regular bullet point setup
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.system(size: 14, weight: .semibold))
            
        }
        
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            
        )
        
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(task.isCompleted ? Color.green.opacity(0.3) : (task.isCustom ? Color.mint.opacity(0.2) : Color.clear), lineWidth: 1)
        )
        
    }
    
}
