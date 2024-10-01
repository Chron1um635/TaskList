//
//  ViewController.swift
//  TaskList
//
//  Created by Alexey Efimov on 28.03.2024.
//

import UIKit

final class TaskListViewController: UITableViewController {
    
    private var taskList: [ToDoTask] = []
    private let cellID = "task"
    private let storeManager = StorageManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        fetchData()
    }
    
    @objc private func addNewTask() {
        showAlert(withTitle: "New Task", andMessage: "What do you want to do?")
    }
    
    private func fetchData() {
        storeManager.fetchData { result in
            switch result {
            case .success(let tasks):
                taskList = tasks
            case .failure(let error):
                showAlert(withTitle: "Oops", andMessage: error.localizedDescription)
            }
        }
    }
    
    private func showAlert(withTitle title: String, andMessage message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { [unowned self] _ in
            if title == "New Task" {
                guard let inputText = alert.textFields?.first?.text, !inputText.isEmpty else { return }
                storeManager.create(inputText) { task in
                    taskList.append(task)
                    let indexPath = IndexPath(row: taskList.count - 1, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                }
            } else if title == "Edit Task" {
                guard let inputText = alert.textFields?.first?.text, !inputText.isEmpty else { return }
                guard let index = tableView.indexPathForSelectedRow else { return }
                storeManager.update(taskList[index.row], newName: inputText)
                tableView.reloadRows(at: [index], with: .automatic)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        alert.addTextField { [unowned self] textField in
            if title == "New Task" {
                textField.placeholder = "New Task"
            } else if title == "Edit Task" {
                guard let index = tableView.indexPathForSelectedRow else { return }
                textField.text = taskList[index.row].title
                textField.placeholder = "Edit Task"
            }
            
        }
        present(alert, animated: true)
    }
    
}

// MARK: - UITableViewDataSource
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
}

// MARK: - Setup UI
private extension TaskListViewController {
    func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Navigation bar appearance
        let navBarAppearance = UINavigationBarAppearance()
        
        navBarAppearance.backgroundColor = .milkBlue
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        // Add button to navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
    }
}

// MARK: - UITableViewDelegate
extension TaskListViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showAlert(withTitle: "Edit Task", andMessage: "Edit your task")
    }
    
    override func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        
        if editingStyle == .delete {
            storeManager.deleteContext(object: taskList[indexPath.row])
            taskList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}
