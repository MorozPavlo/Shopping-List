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

    private let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var shoppingList: [List]  = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchData()
        self.title = "Список покупок"
        self.navigationItem.leftBarButtonItem = self.editButtonItem

        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(toggleEditing)) // create a bat button
        editButton.image = UIImage(systemName: "text.justify")
        editButton.tintColor = .black
        navigationItem.leftBarButtonItem = editButton // assign button
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return shoppingList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shoppingList", for: indexPath) as! ShoppingListTableViewCell
        let list = shoppingList[indexPath.row]
        var index = indexPath.row
        update(list, index: index)
        cell.set(list: list)
        return cell

    }

    @IBAction func addNewProduct(_ sender: Any) {

        showAlert(title: "Добавление продукта", message: "Что хотите добавить в список?")
    }

    // MARK: - Delete list

    //    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
    //        return .delete
    //    }
    //
    //    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    //        if editingStyle == .delete {
    //
    //            delete(shoppingList[indexPath.row])
    //            shoppingList.remove(at: indexPath.row)
    //            tableView.deleteRows(at: [indexPath], with: .fade)
    //        }
    //    }

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

        let someArray = shoppingList
        let oldList = shoppingList.remove(at: sourceIndexPath.row)
        shoppingList.insert(oldList, at: destinationIndexPath.row)
        tableView.reloadData()

//        for i in 0...shoppingList.count - 1 {
//            print(shoppingList[i].name)
//        }
        let fetchRequest: NSFetchRequest<List> = List.fetchRequest()
                do {
                    let result = try viewContext.fetch(fetchRequest)
                    var indexx = 0
                        for _ in 0...shoppingList.count - 1 {

//print("СМЕНИТЬ \(result[indexx].name) по индексу \(indexx) НА ШОП ЛИСТ\(shoppingList[indexx].name) по индексу \(indexx)")

                            if indexx == shoppingList.count - 1 {
                           // result[sourceIndexPath.row].setValue(shoppingList[destinationIndexPath.row].name, forKey: "name")
                           // result[destinationIndexPath.row].setValue(shoppingList[sourceIndexPath.row].name, forKey: "name")

                           // print("СМЕНИТЬ \(result[sourceIndexPath.row].name) по индексу \(sourceIndexPath.row) НА ШОП ЛИСТ\(shoppingList[destinationIndexPath.row].name) по индексу \(destinationIndexPath.row)")

                                result[sourceIndexPath.row].setValue(someArray[destinationIndexPath.row].name, forKey: "name")
                                result[indexx].setValue(someArray[sourceIndexPath.row].name, forKey: "name")



                    }
                            indexx += 1
                        }
                    do {
                        try viewContext.save()
                    } catch  let error as NSError {
                        print("error: \(error.localizedDescription)")
                    }
                }catch let error as NSError {
                    print("error: \(error.localizedDescription)")
                }
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
            self.navigationItem.leftBarButtonItem?.tintColor = .black
        }
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

    private func update(_ list: List, index: Int) {

        let fetchRequest: NSFetchRequest<List> = List.fetchRequest()
        do {
            let result = try viewContext.fetch(fetchRequest)
//            //старый продукт
//            let oldList = result[sourceIndexPath.row] as NSManagedObject as! List
//            //новый продукт
//            let newList = result[destinationIndexPath.row] as NSManagedObject as! List
//
//            newList.setValue(shoppingList[destinationIndexPath.row].name, forKey: "name")
//            oldList.setValue(shoppingList[sourceIndexPath.row].name, forKey: "name")

            //result[indexPath.row].setValue(list.name, forKey: "name")
            var indexx = 0
            if index == shoppingList.count - 1 && tableView.isEditing == true {
               // result[index].setValue(shoppingList[index].name, forKey: "name")
                for i in 0...shoppingList.count - 1 {
                    //print("СМЕНИТЬ \(result[indexx].name) по индексу \(indexx) НА ШОП ЛИСТ\(shoppingList[indexx].name) по индексу \(indexx)")
                    //result[indexx].setValue(shoppingList[indexx].name, forKey: "name")
                   // print("СМЕНИТЬ2 \(result[indexx].name) по индексу \(indexx) НА ШОП ЛИСТ2\(shoppingList[indexx].name) по индексу \(indexx)")
                    indexx += 1
                }
            }

            do {

                try viewContext.save()
            } catch  let error as NSError {
                print("error: \(error.localizedDescription)")
            }
        }catch let error as NSError {
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


    private func fetchData() {

        let fetchRequest: NSFetchRequest<List> = List.fetchRequest()

        do {
            shoppingList = try viewContext.fetch(fetchRequest)
        } catch let error {
            print(error)
        }
    }
}
