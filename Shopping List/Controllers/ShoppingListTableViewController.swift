
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
    @IBOutlet weak var deleteList: UIBarButtonItem!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    
    @IBOutlet weak var priceView: UIView!
    @IBOutlet weak var priceLabel: UILabel!
    
    private let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var shoppingList: [List]  = []
    
    private var styleDark: Bool = false
    private let defaults = UserDefaults.standard
    private var costAccounting: Bool = false
    private var pictures = [String]()
    
    private let footView = UIView()
    private let button = UIButton()
    
    var selectedCategory: Category? {
        didSet {
            fetchData()
        }
    }
    
    //MARK: - LifeCicleView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        NotificationCenter.default.addObserver(self,
                                                     selector: #selector(didBecomeActive),
                                                     name: UIApplication.didBecomeActiveNotification,
                                                     object: nil)
        
        setupUI()
        //  fetchData()
        createButton()
        
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        tableView.dragInteractionEnabled = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        setupCost()
        setupViewWillAppear()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        settingFotterView()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    //MARK: - Notification
    
    
    @objc func didBecomeActive(_ notification: Notification) {
        DispatchQueue.main.async {
            self.setupUI()
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return shoppingList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "shoppingList", for: indexPath) as! ShoppingListTableViewCell
        let list = shoppingList[indexPath.row]
        cell.set(list: list)
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    // MARK: - Actions
    
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
                self.showAddPositionAleft(title: NSLocalizedString("CostOfGoods", comment: ""), message: NSLocalizedString("EnterСost", comment: ""), shoppingList: self.shoppingList[indexPath.row])
            } else {
                self.updatePurchases(self.shoppingList[indexPath.row])
            }
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
            self.updateBadgeValue()
            complete(true)
        }
        
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .red
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
    
    // MARK: - DeleteAllInBusket
    
    
    @IBAction func deleteListButton(_ sender: Any) {
        
        if shoppingList.isEmpty == false && isPurchasedItemsInList(true) == true {
            
            deleteListInBusketAleft()
            
        } else {
            let alertTitle = NSLocalizedString("NotToDelete", comment: "")
            let alert = UIAlertController(title: alertTitle, message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ок", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true)
        }
        
    }
    
    private func deleteListInBusketAleft() {
        let alert = UIAlertController(title: NSLocalizedString("DeletingItems", comment: ""), message: NSLocalizedString("AreYouSure", comment: ""), preferredStyle: .alert)
        let saveAction = UIAlertAction(title: NSLocalizedString("Del", comment: ""), style: .default) { _ in
            for (_,list) in self.shoppingList.enumerated() {
                if list.isBuy {
                    if let index = self.shoppingList.firstIndex(of: list) {
                        self.delete(self.shoppingList[index])
                        self.shoppingList.remove(at: index)
                        self.updateBadgeValue()
                    }
                    self.tableView.reloadData()
                }
            }
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .destructive)
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        present(alert, animated: true)
    }
    
    // MARK: - Show edit Alert
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Change the selected background view of the cell.
        tableView.deselectRow(at: indexPath, animated: true)
        
        showEditAlert(title: NSLocalizedString("EditPosition", comment: ""), message: NSLocalizedString("WhatToChange", comment: ""), shoppingList: shoppingList[indexPath.row])
    }
    
    // MARK: - Copy List
    
    @IBAction func copyAllList(_ sender: Any) {
        
        if shoppingList.isEmpty == false && isPurchasedItemsInList(false) == false {
            
            var items:[String] = []
            var index = 1
            var listString = ""
            for names in shoppingList  {
                if names.isBuy == false {
                    guard let name = names.name else { return }
                    
                    listString += "\(index).\(name)\n"
                    index += 1
                }
            }
            
            let title = (NSLocalizedString("ShoppingList", comment: "")+":\n----------\n")
            let message = title + listString
            items.append(message)
            let shareController = UIActivityViewController(activityItems: items, applicationActivities: nil)
            present(shareController, animated: true, completion: nil)
            
        } else {
            let alertTitle = NSLocalizedString("NotToBuy", comment: "")
            let alert = UIAlertController(title: alertTitle, message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ок", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true)
        }
    }
    
    // MARK: - setupViewWillAppear
    
    
    private func setupViewWillAppear() {
        costAccounting = defaults.bool(forKey: "costAccounting")
        
        priceLabel.layer.cornerRadius = 8
        priceLabel.clipsToBounds = true
        
        if costAccounting {
            priceView.isHidden = false
            priceView.frame.size.height = 30
        } else {
            priceView.isHidden = true
            priceView.frame.size.height = 0
        }
        
        sutupButton()
        tableView.reloadData()
    }
    
    // MARK: - closeKayboard
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func goToSettingsView(_ sender: Any) {
        
        let settingsVC = SettingsTableViewController()
        //settingsVC.modalPresentationStyle = .fullScreen
        //settingsVC.delegate = self
        present(settingsVC, animated: true, completion: nil)
    }
}


// MARK: - SetupUI
extension ShoppingListTableViewController {
    
    func setupUI() {
        self.title = NSLocalizedString("ShoppingList", comment: "")
        
        self.costAccounting = defaults.bool(forKey: "costAccounting")
        
        navigationItem.leftItemsSupplementBackButton = true
        
        
        if self.traitCollection.userInterfaceStyle  == .dark {
            styleDark = true
        } else {
            styleDark = false
        }
        
        //editButton.image = UIImage(systemName: "arrow.up.arrow.down")
        //tableView.separatorColor = .lightGray
        
        if styleDark {
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            addButton.tintColor = .white
            settingsButton.tintColor = .white
            copyAll.tintColor = .white
            deleteList.tintColor = .white
            priceLabel.textColor = .black
            tabBarController?.tabBar.unselectedItemTintColor = .white
            tabBarController?.tabBar.tintColor = .systemOrange
            priceLabel.backgroundColor = UIColor.systemYellow.withAlphaComponent(1)
            navigationController?.navigationBar.tintColor = .white
            
        } else {
            navigationController?.navigationBar.barStyle = .default
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemOrange]
            addButton.tintColor = .black
            settingsButton.tintColor = .black
            copyAll.tintColor = .black
            deleteList.tintColor = .black
            tabBarController?.tabBar.unselectedItemTintColor = .black
            tabBarController?.tabBar.tintColor = .systemOrange
            priceLabel.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.45)
            navigationController?.navigationBar.tintColor = .black
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
        
        let currency = defaults.string(forKey: "currency") ?? NSLocalizedString("CurrentCurrency", comment: "")
        let formatString = NSLocalizedString("CurrencyTotal", comment: "") + (" \(currency)")
        
        priceLabel.text = String.localizedStringWithFormat(formatString, total)
        
    }
    
    private func isPurchasedItemsInList (_ statusList:Bool) -> Bool {
        
        //Если true, то нам важно, что в списке есть купленные, чтоб удалить
        switch  statusList {
        case true :
            var isPurchasedItemsInList = false
            for list in shoppingList {
                if list.isBuy {
                    isPurchasedItemsInList = true
                    break
                }
            }
            return isPurchasedItemsInList
            
        case false :
            var isPurchasedItemsInList = true
            for list in shoppingList {
                if !list.isBuy {
                    isPurchasedItemsInList = false
                    break
                }
            }
            return isPurchasedItemsInList
        }
    }
    
    // MARK: - CreateBotton
    
    func createButton() {
        
        //let color = UIColor(red: 247/255, green: 110/255, blue: 13/255, alpha: 1)
        let color = UIColor.systemOrange
        //image
        guard let image = UIImage(systemName: "plus.circle") else { return }
        button.setImage(image, for: .normal)
        //button.imageView?.backgroundColor = .systemOrange
        button.imageView?.clipsToBounds = true
        button.imageView?.layer.cornerRadius = 8
        button.imageView?.tintColor = color
        
        button.addTarget(self, action: #selector(addPosition), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.centerTextAndImage(spacing: 10)
        button.contentHorizontalAlignment  = .left
        
        button.setTitle(NSLocalizedString("NewPosition", comment: ""), for: .normal)
        button.setTitleColor(color, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20.0, weight: .bold)
        
        
        footView.alpha = 0
        view.addSubview(footView)
        view.addSubview(button)
        footView.translatesAutoresizingMaskIntoConstraints = false
        footView.backgroundColor = .systemGray6
        
        
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: footView.leadingAnchor, constant: 32),
            button.trailingAnchor.constraint(equalTo: footView.trailingAnchor, constant: -8),
            button.topAnchor.constraint(equalTo: footView.topAnchor, constant: 0),
            button.heightAnchor.constraint(equalToConstant: 30),
            button.widthAnchor.constraint(equalToConstant: 300)
        ])
        
        
        let guide = self.view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            //footView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 10),
            footView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            footView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            footView.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: 40),
            footView.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    
    //               let bottomOffset = CGPoint(x: 0, y: self.tableView.contentSize.height + 10 - self.tableView.frame.size.height)
    //               self.tableView.setContentOffset(bottomOffset, animated: false)
    
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        settingFotterView()
    }
    
    override func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        
        settingFotterView()
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        settingFotterView()
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        settingFotterView()
    }
    
    private func settingFotterView() {
        
        guard let tableViewFrameMaxY = tableView.visibleCells.last?.frame.maxY else { return }
        
        if tableViewFrameMaxY >= footView.frame.minY && footView.frame.minY != 0 {
            
            footView.alpha = 1
        } else {
            footView.alpha = 0
        }
    }
    
}

extension UIButton {
    func centerTextAndImage(spacing: CGFloat) {
        let insetAmount = spacing / 2
        imageEdgeInsets = UIEdgeInsets(top: 0, left: -insetAmount, bottom: 0, right: insetAmount)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: -insetAmount)
        contentEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: insetAmount)
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
        alert.addTextField { [weak self] (textFeild) in
            textFeild.delegate = self
        }
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        present(alert, animated: true)
    }
    
    private func showEditAlert(title: String, message: String, shoppingList: List) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: NSLocalizedString("Save", comment: ""), style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else {
                print("The text field is empty1")
                return
            }
            
            var doubleValue: Double? = nil
            
            if self.defaults.bool(forKey: "costAccounting") {
                let count = alert.textFields?[1].text
                if let doubleCont = count {
                    let newDouble = doubleCont.replacingOccurrences(of: ",", with: ".", options: .literal, range: nil)
                    doubleValue = Double(newDouble) ?? 0.0
                }
            }
            
            self.updateList(task, listCost: doubleValue , order: Int(shoppingList.order))
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .destructive)
        alert.addTextField { [weak self] (textFeild) in
            textFeild.delegate = self
        }
        alert.textFields?.first?.text = shoppingList.name
        if costAccounting {
            alert.addTextField { (textFeild) in
                
                textFeild.keyboardType = .decimalPad
                if shoppingList.cost == 0.0 {
                    textFeild.placeholder = NSLocalizedString("EnterСost", comment: "")
                } else {
                    textFeild.text = "\(shoppingList.cost)"
                }
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        present(alert, animated: true)
    }
    
    private func showAddPositionAleft(title: String, message: String, shoppingList: List) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: NSLocalizedString("Save", comment: ""), style: .default) { _ in
            
            let count = alert.textFields?.first?.text
            var doubleValue: Double = 0.0
            if let doubleCont = count {
                let newDouble = doubleCont.replacingOccurrences(of: ",", with: ".", options: .literal, range: nil)
                doubleValue = Double(newDouble) ?? 0.0
            }
            
            self.updateList(shoppingList.name, listCost: doubleValue  , order: Int(shoppingList.order))
            
            self.updatePurchases(shoppingList)
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .destructive)
        
        alert.addTextField { (textFeild) in
            textFeild.keyboardType = .decimalPad
            if shoppingList.cost == 0.0 {
                textFeild.placeholder = NSLocalizedString("EnterСost", comment: "")
            } else {
                textFeild.text = "\(shoppingList.cost)"
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
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
        list.name = listName.capitalizingFirstLetter()
        list.parentCategory = selectedCategory
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
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.settingFotterView()
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
        updateBadgeValue()
        
        settingFotterView()
    }
    
    
    
    private func updateList(_ listName: String?, listCost: Double?, order: Int) {
        
        viewContext.setValue(listName, forKey: "name")
        
        for (_,list) in shoppingList.enumerated() {
            
            if list.order == Int32(order) {
                list.name = listName
                if let cost = listCost {
                    list.cost = cost
                }
                
                self.tableView.reloadData()
            }
        }
        do {
            try viewContext.save()
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
        setupCost()
        updateBadgeValue()
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
        updateBadgeValue()
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
        updateBadgeValue()
    }
    
    private func fetchData() {
        
        let fetchRequest: NSFetchRequest<List> = List.fetchRequest()
        
        let sort = NSSortDescriptor(key: "order", ascending: true)
        let predicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        fetchRequest.predicate = predicate
        
        fetchRequest.sortDescriptors = [sort]
        do {
            shoppingList = try viewContext.fetch(fetchRequest)
            
        } catch let error {
            print(error)
        }
        updateBadgeValue()
    }
}

// MARK: - Work with UITextField

extension ShoppingListTableViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 30
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
        currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
}

// MARK: - Work with String

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

extension ShoppingListTableViewController {
    
    func updateBadgeValue() {
        
        var count = 0
        
        shoppingList.forEach { (list) in
            if !list.isBuy {
                count += 1
            }
        }
        
        if shoppingList.isEmpty { count = 0 }
        tabBarController?.tabBar.items?[0].badgeValue = "\(count)"
    }
}

// MARK: - UITableViewDragDelegate, UITableViewDropDelegate

extension ShoppingListTableViewController: UITableViewDragDelegate, UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        
        let dragItem = self.dragItem(forDataAt: indexPath)
        return [dragItem]
    }
    
    /// Helper method
    private func dragItem(forDataAt indexPath: IndexPath) -> UIDragItem {
        
        let imageName = self.shoppingList[indexPath.row].name
        let data = shoppingList[indexPath.row]
        let string = data.name
        let itemProvider = NSItemProvider(object: string! as NSItemProviderWriting)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = imageName
        return dragItem
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        
    }
    
    func tableView(_ tableView: UITableView, dragSessionDidEnd session: UIDragSession) {
        updateOrders()
    }
}

extension ShoppingListTableViewController {
    
    @objc func addPosition() {
        
        showAlert(title: NSLocalizedString("AddingPosition", comment: ""), message: NSLocalizedString("WhatToAdd", comment: ""))
    }
}


extension ShoppingListTableViewController {
    
    func sutupButton() {
        
        let buttonOnFoot = defaults.bool(forKey: "addButton")
        
        if buttonOnFoot {
            addButton.image = nil
            addButton.isEnabled = false
            footView.isHidden = false
            button.isHidden = false
        } else {
            let image = UIImage(systemName: "plus")
            addButton.image = image
            addButton.isEnabled = true
            footView.isHidden = true
            button.isHidden = true
        }
    }
}

