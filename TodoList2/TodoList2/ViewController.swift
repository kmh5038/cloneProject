//
//  ViewController.swift
//  TodoList2
//
//  Created by 김명현 on 2023/08/09.


// 1. 할 일 등록 alert만들기 v , 할 일 tableView에 나타내기 구현 v
// 2. 할 일들 저장,불러오기 구현 v
// 3. edit상태에서 삭제, 재정렬 구현 v
// 4. 완료된 일들 체크마크 기능 구현 v

import UIKit

class ViewController: UIViewController {
    
    var tasks = [Task]() {
        didSet {
            saveTasts()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTap))
        loadTasts()
        
    }
    @IBAction func editButtonTap(_ sender: UIBarButtonItem) {
        if !tasks.isEmpty {
            tableView.setEditing(true, animated: true)
            navigationItem.leftBarButtonItem = doneButton
        }
    }
    @IBOutlet var edittonButton: UIBarButtonItem!
    
    var doneButton:UIBarButtonItem?
    
    @objc func doneButtonTap() {
        navigationItem.leftBarButtonItem = edittonButton
        tableView.setEditing(false, animated: true)
    }
    
    
    @IBAction func addButtonTap(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "할 일", message: "", preferredStyle: .alert)
        alert.addTextField(configurationHandler: {textField in textField.placeholder = "할 일을 입력해주세요"} )
        
        let registor = UIAlertAction(title: "등록", style: .default, handler: { _ in guard let title2 = alert.textFields?[0].text else {return }
            let task = Task(title: title2, done: false)
            self.tasks.append(task)
            self.tableView.reloadData()
        })
        
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(registor)
        alert.addAction(cancel)
        
        present(alert, animated: true)
        
    }
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    func saveTasts() {
        let data = tasks.map{
            ["title": $0.title, "done": $0.done] as [String : Any]
        }
        let userDefaults = UserDefaults.standard
        userDefaults.set(data, forKey: "tasksKey")
    }
    
    func loadTasts() {
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.object(forKey: "tasksKey") as? [[String : Any]] else { return }
        tasks = data.compactMap{
            guard let title = $0["title"] as? String else {return nil}
            guard let done = $0["done"] as? Bool else {return nil}
            
            return Task(title: title, done: done)
        }
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        tasks.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        var tasks = self.tasks
        let task = tasks[sourceIndexPath.row]
        tasks.remove(at: sourceIndexPath.row)
        tasks.insert(task, at: destinationIndexPath.row)
        
        self.tasks = tasks
        
        
    }
    
}


extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let task = tasks[indexPath.row]
        
        cell.textLabel?.text = task.title
        
        if task.done {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
        
    }
    
}


extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var task = tasks[indexPath.row]
        task.done = !task.done
        tasks[indexPath.row] = task
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
