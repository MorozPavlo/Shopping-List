
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
    @IBOutlet weak var copyAll: UIBarButtonItem!
    @IBOutlet weak var priceView: UIView!
    @IBOutlet weak var priceLabel: UILabel!

    private let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var shoppingList: [List]  = []
    private var styleDark: Bool = false
    private let defaults = UserDefaults.standard
    private var costAccounting: Bool = false

    //MARK: - ViewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didBecomeActive(_:)),
                                               name: Notification.Name(rawValue: "didBecomeActive"),
                                               object: nil)

        setupUI()
        fetchData()
    }
    

    @objc func didBecomeActive(_ notification: Notification) {
        DispatchQueue.main.async {
            self.setupUI()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        costAccounting = defaults.bool(forKey: "costAccounting")

        if costAccounting {
            priceView.isHidden = false
            priceView.frame.size.height = 30
        } else {
            priceView.isHidden = true
            priceView.frame.size.height = 0
        }
        tableView.reloadData()

        priceLabel.layer.cornerRadius = 8
        priceLabel.clipsToBounds = true
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

    // MARK: - Add new List Func

    @IBAction func addNewProduct(_ sender: Any) {

        showAlert(title: NSLocalizedString("AddingPosition", comment: ""), message: NSLocalizedString("WhatToAdd", comment: ""))
    }

    // MARK: - Buy Actions

    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let done = doneAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [done])
    }

    // MARK: - Buy Actions configuration
    func doneAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Done") { (action, view, completion) in
            if self.costAccounting && self.shoppingList[indexPath.row].cost == 0.0 {
                self.showAddPositionAleft(title: "Стоимость товара", message: "Укажите стоимость", shoppingList: self.shoppingList[indexPath.row])
            } else {
                self.updatePurchases(self.shoppingList[indexPath.row])
            }
            //self.updatePurchases(self.shoppingList[indexPath.row])
            //self.tableView.reloadData()
            completion(true)
        }
        if shoppingList[indexPath.row].isBuy == false {
            action.backgroundColor = .systemGreen
            action.image = UIImage(systemName: "cart.badge.plus")
        } else {
            action.backgroundColor = .red
            action.image = UIImage(systemName: "cart.badge.minus")
        }
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

    // MARK: - Swipe Action (Delete)
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

    // MARK: - Change Style and UpdateOrders
    @objc private func toggleEditing() {


        self.tableView.setEditing(!self.tableView.isEditing, animated: true)

        if(self.tableView.isEditing == true)
        {
            self.navigationItem.leftBarButtonItem?.image = UIImage(systemName: "checkmark")
            self.navigationItem.leftBarButtonItem?.tintColor = .systemGreen
        }
        else
        {
            self.navigationItem.leftBarButtonItem?.image = UIImage(systemName: "arrow.up.arrow.down")
            self.navigationItem.leftBarButtonItem?.tintColor = styleDark ? .white : .black

            updateOrders()
        }
    }

    // MARK: - Show edit Alert

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        showEditAlert(title: NSLocalizedString("EditPosition", comment: ""), message: NSLocalizedString("WhatToChange", comment: ""), shoppingList: shoppingList[indexPath.row])
    }

    // MARK: - Copy List

    @IBAction func copyAllList(_ sender: Any) {

        UIPasteboard.general.strings?.removeAll()
        for names in shoppingList  {
            if names.isBuy == false {
                guard let name = names.name else { return }
                UIPasteboard.general.strings?.append("\n\(name)")
            }
        }
        UIPasteboard.general.strings?.insert(NSLocalizedString("ShoppingList", comment: "")+":\n----------", at: 0)


        var alertTitle = ""
        if shoppingList.isEmpty == false {
            alertTitle = NSLocalizedString("ListSaveToBufer", comment: "")
        } else {
            alertTitle = NSLocalizedString("ListDontSaveToBufer", comment: "")
        }

        let alert = UIAlertController(title: alertTitle, message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ок", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}


// MARK: - SetupUI
extension ShoppingListTableViewController {

    func setupUI() {
        self.title = NSLocalizedString("ShoppingList", comment: "")

        self.costAccounting = defaults.bool(forKey: "costAccounting")

        navigationItem.leftBarButtonItem = editButtonItem
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(toggleEditing))

        if self.traitCollection.userInterfaceStyle  == .dark {
            styleDark = true
        } else {
            styleDark = false
        }

        if styleDark {
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            editButton.image = UIImage(systemName: "arrow.up.arrow.down")
            editButton.tintColor = .white
            navigationItem.leftBarButtonItem = editButton // assign button
            addButton.tintColor = .white
            copyAll.tintColor = .white
            tableView.separatorColor = .systemYellow
            priceLabel.textColor = .black
            tabBarController?.tabBar.unselectedItemTintColor = .white
            tabBarController?.tabBar.tintColor = .systemOrange

        } else {
            navigationController?.navigationBar.barStyle = .default
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemOrange]
            editButton.image = UIImage(systemName: "arrow.up.arrow.down")
            editButton.tintColor = .black
            addButton.tintColor = .black
            copyAll.tintColor = .black
            navigationItem.leftBarButtonItem = editButton // assign button
            tableView.separatorColor = .systemYellow
            tabBarController?.tabBar.unselectedItemTintColor = .black
            tabBarController?.tabBar.tintColor = .systemOrange

        }
        setupCost()
    }

    // MARK: - UpdateCost

    func setupCost() {
        var total: Double = 0.0
        for cost in shoppingList {
            if cost.isBuy == true {
            total += cost.cost
            }
        }
        let currency = defaults.string(forKey: "currency") ?? "₴"

        //priceLabel.text = "Всего чек: \(total) \(currency)"

        let formatString = NSLocalizedString("CurrencyTotal", comment: "") + (" \(currency)")
        priceLabel.text = String.localizedStringWithFormat(formatString, total)
    }
}

// MARK: - Alert controller
extension ShoppingListTableViewController {

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: NSLocalizedString("Add", comment: ""), style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else {
                print("The text field is empty")
                return
            }

            self.save(task)
        }

        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .destructive)
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }

    private func showEditAlert(title: String, message: String, shoppingList: List) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: NSLocalizedString("Edit", comment: ""), style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else {
                print("The text field is empty1")
                return
            }

            let count = alert.textFields?[1].text
            var doubleValue: Double = 0.0
            if let doubleCont = count {
                let newDouble = doubleCont.replacingOccurrences(of: ",", with: ".", options: .literal, range: nil)
                doubleValue = Double(newDouble) ?? 0.0
            }

            self.updateList(task, listCost: doubleValue , order: Int(shoppingList.order))

        }

        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .destructive)
        alert.addTextField()
        alert.textFields?.first?.text = shoppingList.name
        if costAccounting {
            alert.addTextField { (textFeild) in

                textFeild.keyboardType = .decimalPad
                if shoppingList.cost == 0.0 {
                    textFeild.placeholder = "Введите стоимость"
                } else {
                    textFeild.text = "\(shoppingList.cost)"
                }
            }
        }
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }

    private func showAddPositionAleft(title: String, message: String, shoppingList: List) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Сохранить", style: .default) { _ in

            let count = alert.textFields?.first?.text
            var doubleValue: Double = 0.0
            if let doubleCont = count {
                let newDouble = doubleCont.replacingOccurrences(of: ",", with: ".", options: .literal, range: nil)
                doubleValue = Double(newDouble) ?? 0.0
            }

            self.updateList(shoppingList.name, listCost: doubleValue , order: Int(shoppingList.order))
            
            self.updatePurchases(shoppingList)
        }

        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .destructive)

        alert.addTextField { (textFeild) in
            textFeild.keyboardType = .decimalPad
            if shoppingList.cost == 0.0 {
                textFeild.placeholder = "Введите стоимость"
            } else {
                textFeild.text = "\(shoppingList.cost)"
            }
        }
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
        let minList = shoppingList.min { a, b in a.order < b.order }
        list.order = (minList?.order ?? 0) - 1

        do {
            try viewContext.save()
            shoppingList.append(list)
            let cellIndex = IndexPath(row: self.shoppingList.count - 1, section: 0)
            self.tableView.insertRows(at: [cellIndex], with: .automatic)
            fetchData()
            tableView.reloadData()
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
        setupCost()
    }

    private func updateList(_ listName: String?, listCost: Double, order: Int) {

        viewContext.setValue(listName, forKey: "name")

        for (_,list) in shoppingList.enumerated() {

            if list.order == Int32(order) {
                list.name = listName
                list.cost = listCost

                self.tableView.reloadData()
            }
        }
        do {
            try viewContext.save()
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
        setupCost()
    }

    private func updatePurchases(_ listName: List) {


        if listName.isBuy == false {
            listName.isBuy = true
            listName.order = Int32(shoppingList.count + 1)
            fetchData()
            tableView.reloadData()


        } else {
            listName.isBuy = false

            let minList = shoppingList.min { a, b in a.order < b.order }
            listName.order = (minList?.order ?? 0) - 1
            fetchData()
            tableView.reloadData()
        }

        do {
            try viewContext.save()
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
        updateOrders()
        setupCost()
    }

    private func updateOrders() {
        for (index,list) in shoppingList.enumerated() {
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

