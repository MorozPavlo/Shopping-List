//
//  ShoppingListTableViewController.swift
//  Shopping List
//
//  Created by Pavel Moroz on 18.04.2020.
//  Copyright © 2020 Pavel Moroz. All rights reserved.
//

import UIKit
import CoreData

class ShoppingListTableViewController: UITableViewController {

    @IBOutlet weak var addButton: UIBarButtonItem!
    
    private let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var shoppingList: [List]  = []
    var styleDark: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchData()
        self.title = "Список покупок"
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(toggleEditing)) // create a bat button

        if self.traitCollection.userInterfaceStyle  == .dark {
            self.styleDark = true
        } else {
            false
        }

        if styleDark {
            editButton.image = UIImage(systemName: "text.justify")
            editButton.tintColor = .white
            navigationItem.leftBarButtonItem = editButton // assign button
            addButton.tintColor = .white
        } else {
            editButton.image = UIImage(systemName: "text.justify")
            editButton.tintColor = .black
            navigationItem.leftBarButtonItem = editButton // assign button
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return shoppingList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shoppingList", for: indexPath) as! ShoppingListTableViewCell
        let list = shoppingList[indexPath.row]
        cell.set(list: list)
        return cell

    }

    @IBAction func addNewProduct(_ sender: Any) {

        showAlert(title: "Добавление позиции", message: "Что хотите добавить в список?")
    }

    // MARK: - Buy Actions

    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let done = doneAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [done])
    }

    func doneAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Done") { (action, view, completion) in
            self.updatePurchases(self.shoppingList[indexPath.row])
            self.tableView.reloadData()
            completion(true)
        }
        action.backgroundColor = .systemGreen
        action.image = UIImage(systemName: "checkmark.circle")
        return action
    }

    // MARK: - Move List

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let oldList = shoppingList.remove(at: sourceIndexPath.row)
        shoppingList.insert(oldList, at: destinationIndexPath.row)

        tableView.reloadData()
        

    }

    @available(iOS 11.0, *)
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { _, _, complete in
            self.delete(self.shoppingList[indexPath.row])
            self.shoppingList.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            complete(true)
        }
        // here set your image and background color
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .red
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }

    @objc private func toggleEditing() {
        self.tableView.setEditing(!self.tableView.isEditing, animated: true) // Set opposite value of current editing status
        //navigationItem.rightBarButtonItem?.title = self.tableView.isEditing ? "Done" : "Edit" // Set title depending on the editing status
        if(self.tableView.isEditing == true)
        {
            self.navigationItem.leftBarButtonItem?.image = UIImage(systemName: "checkmark")
            self.navigationItem.leftBarButtonItem?.tintColor = .systemGreen
        }
        else
        {
            self.navigationItem.leftBarButtonItem?.image = UIImage(systemName: "text.justify")
            self.navigationItem.leftBarButtonItem?.tintColor = styleDark ? .white : .black

            updateOrders()
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        showEditAlert(title: "Редактирование позиции", message: "На что изменить?", shoppingList: shoppingList[indexPath.row])
    }

}


// MARK: - Alert controller
extension ShoppingListTableViewController {
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Добавить", style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else {
                print("The text field is empty")
                return
            }

            self.save(task)
        }

        let cancelAction = UIAlertAction(title: "Отменить", style: .destructive)
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }

    private func showEditAlert(title: String, message: String, shoppingList: List) {
         let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
         let saveAction = UIAlertAction(title: "Редактировать", style: .default) { _ in
             guard let task = alert.textFields?.first?.text, !task.isEmpty else {
                 print("The text field is empty")
                 return
             }

            self.update(task, order: Int(shoppingList.order))
         }

         let cancelAction = UIAlertAction(title: "Отменить", style: .destructive)
         alert.addTextField()
        alert.textFields?.first?.text = shoppingList.name
         alert.addAction(saveAction)
         alert.addAction(cancelAction)
         present(alert, animated: true)
     }

}


// MARK: - Work with storage
extension ShoppingListTableViewController {

    private func save(_ listName: String) {
        guard let entityDescription = NSEntityDescription.entity(
            forEntityName: "List",
            in: viewContext
            )
            else { return }

        let list = NSManagedObject(entity: entityDescription, insertInto: viewContext) as! List
        list.name = listName
        let maxList = shoppingList.max { a, b in a.order < b.order }
        list.order = (maxList?.order ?? 0) + 1

        do {
            try viewContext.save()
            shoppingList.append(list)
            let cellIndex = IndexPath(row: self.shoppingList.count - 1, section: 0)
            self.tableView.insertRows(at: [cellIndex], with: .automatic)
        } catch let error {
            print(error)
        }
    }

    private func delete(_ listName: List) {

        viewContext.delete(listName)

        do {
            try viewContext.save()
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
    }

    private func update(_ listName: String, order: Int) {

        viewContext.setValue(listName, forKey: "name")
        for (_,list) in shoppingList.enumerated() {

            if list.order == Int32(order) {
                //print(list.name)
                list.name = listName
                self.tableView.reloadData()
            }
        }
            do {
                try viewContext.save()
            } catch let error as NSError {
                print("error: \(error.localizedDescription)")
            }
    }

    private func updatePurchases(_ listName: List) {

        if listName.isBuy == false {
            listName.isBuy = true
        } else {
            listName.isBuy = false
        }

        do {
            try viewContext.save()
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
    }

    private func updateOrders() {
        for (index,list) in shoppingList.enumerated() {
            print(index)
            print(list)
            list.order = Int32(index)
        }
        do {
            try viewContext.save()
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
    }

    private func fetchData() {

        let fetchRequest: NSFetchRequest<List> = List.fetchRequest()
        
        let sort = NSSortDescriptor(key: "order", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        do {
            shoppingList = try viewContext.fetch(fetchRequest)

        } catch let error {
            print(error)
        }
    }
}
