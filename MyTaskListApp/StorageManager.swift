//
//  StorageManager.swift
//  MyTaskListApp
//
//  Created by Andrey Kovalev on 26.11.2023.
//

import CoreData
import UIKit

final class StorageManager {
    static let shared = StorageManager()
    
    private let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private init() {}
    
    func fetchTasks() -> [Task] {
        do {
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            return try viewContext.fetch(fetchRequest)
        } catch {
            print("Failed to fetch tasks: \(error)")
            return []
        }
    }
    
    func addTask(withName taskName: String) {
        let newTask = Task(context: viewContext)
        newTask.title = taskName
        
        do {
            try viewContext.save()
        } catch {
            print("Failed to add task: \(error)")
        }
    }
    
    func deleteTask(_ task: Task) {
        viewContext.delete(task)
        
        do {
            try viewContext.save()
        } catch {
            print("Failed to delete task: \(error)")
        }
    }
    
    
    
    func editTask(_ task: Task, newName: String) {
        task.title = newName
        
        do {
            try viewContext.save()
        } catch {
            print("Failed to edit task: \(error)")
        }
    }
    
    func saveContext() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
           if context.hasChanges {
               do {
                   try context.save()
               } catch {
                   print("Failed to save context: \(error)")
               }
           }
        
       }
}
