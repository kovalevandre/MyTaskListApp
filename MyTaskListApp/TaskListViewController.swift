//
//  TaskListViewController.swift
//  MyTaskListApp
//
//  Created by Andrey Kovalev on 25.11.2023.
//

import UIKit

final class TaskListViewController: UITableViewController {
    private let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private let cellID = "task"
    private var taskList: [Task] = []
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        view.backgroundColor = .white
        
        setupNavigationBar()
        
    }
    
    @objc
    private func addNewTask() {
        showAlert(with: "New Task", and: "What a task do you want to add?")
    }
    
    private func saveTask(_ taskName: String) {
        
            StorageManager.shared.addTask(withName: taskName)
            fetchData()
        }

    private func editTask(at indexPath: IndexPath, newName: String) {
            let task = taskList[indexPath.row]
            task.title = newName
            StorageManager.shared.editTask(task, newName: newName)
            fetchData() 
        }
    
    func deleteTask(at indexPath: IndexPath) {
           let task = taskList[indexPath.row]
           StorageManager.shared.deleteTask(task)
           taskList.remove(at: indexPath.row)
           tableView.deleteRows(at: [indexPath], with: .automatic)
        fetchData()
        
       }
    
}



// MARK: - Private Methods

private extension TaskListViewController {
    func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor(named: "CustomBlue")
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
            
        )
        
        navigationController?.navigationBar.tintColor = .white
        
    }
    
    func fetchData() {
        taskList = StorageManager.shared.fetchTasks()
    }
    
    private func showAlert(with title: String, and message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save Task", style: .default) { [unowned self] _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            
            self.save(task) // Вызываем функцию сохранения задачи
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)

        alert.addAction(saveAction)
        alert.addAction(cancelAction)

        alert.addTextField { textField in
            textField.placeholder = "New Task"
        }

        present(alert, animated: true)
    }
    
    func save(_ taskName: String) {
        
        let task = Task(context: viewContext)
        task.title = taskName
        taskList.append(task)
        let indexPath = IndexPath(row: taskList.count - 1, section: 0)
        
        tableView.insertRows(at: [indexPath], with: .automatic)
        
        if viewContext.hasChanges {
            
            do {
                
                try viewContext.save()
                
            } catch {
                
                print(error)
            }
        }
    }
}

  

extension TaskListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        taskList.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                deleteTask(at: indexPath)
            }
        }
}

extension TaskListViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTask = taskList[indexPath.row]
        showEditTaskAlert(for: selectedTask, at: indexPath)
    }

    private func showEditTaskAlert(for task: Task, at indexPath: IndexPath) {
        let alert = UIAlertController(title: "Edit Task", message: "Enter the updated task", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = task.title
        }

        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let updatedTask = alert.textFields?.first?.text, !updatedTask.isEmpty else { return }
            self?.editTask(at: indexPath, newName: updatedTask)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)

        alert.addAction(saveAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
        fetchData()
    }
}



