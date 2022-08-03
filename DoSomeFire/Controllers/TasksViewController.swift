//
//  TasksViewController.swift
//  DoSomeFire
//
//  Created by admin on 02.08.2022.
//

import UIKit
import FirebaseCore
import FirebaseDatabase
import FirebaseAuth


class TasksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private var user: MyUser!
    private var reference: DatabaseReference!
    private var tasks = Array<Task>()
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func barButtonTapped(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "New task", message: "Add new task", preferredStyle: .alert)
        alertController.addTextField()
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] action in
            guard let textField = alertController.textFields?.first, textField.text != "" else { return }
            
            let task = Task(title: textField.text!, userId: (self?.user.uid)!)
            let taskRef = self?.reference.child(task.title.lowercased())
            taskRef?.setValue(task.convertToDict)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let currentUser = Auth.auth().currentUser else { return }
        user = MyUser(user: currentUser)
        reference = Database.database().reference(withPath: "users").child(String(user.uid)).child("tasks")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reference.observe(.value) { [weak self] snapshot in
            var _tasks = Array<Task>()
            for item in snapshot.children{
                let task = Task(snapshot: item as! DataSnapshot)
                _tasks.append(contentsOf: [task])
            }
            self?.tasks = _tasks
            self?.tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        reference.removeAllObservers()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let taskTitle = tasks[indexPath.row].title
        cell.textLabel?.text = taskTitle
        toggleCompletion(cell, isCompleted: tasks[indexPath.row].completed)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let task = tasks[indexPath.row]
            task.ref?.removeValue()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        let task = tasks[indexPath.row]
        let isCompleted = !task.completed
        toggleCompletion(cell, isCompleted: isCompleted)
        task.ref?.updateChildValues(["completed": isCompleted])
    }
    
    private func toggleCompletion(_ cell: UITableViewCell, isCompleted: Bool){
        cell.accessoryType = isCompleted ? .checkmark : .none
    }
}
