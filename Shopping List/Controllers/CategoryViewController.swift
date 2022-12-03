//
//  CategoryViewController.swift
//  Shopping List
//
//  Created by Admin on 30/11/2022.
//  Copyright © 2022 Pavel Moroz. All rights reserved.
//

import UIKit
import CoreData

let cellReuseIdentifier = "CategoryCell"

enum SectionCategory: Int, CaseIterable {
    
    case categorySection
    
    func desription(categoryCount: Int) -> String {
        switch self {
            
        case .categorySection:
            return "\(categoryCount) category"
        }
    }
}

class CategoryViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var addCategoryButton: UIBarButtonItem!
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var categoryItem: [CategoryItem] = []
    private var category: [Category] = []
    private var styleDark: Bool = false
    private let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<SectionCategory, CategoryItem>!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchData()
        setupNavigationBar()
        setupSearchBar()
        setupCollectionView()
        createDataSourse()
        reloadData(with: nil)
    }
    
    // MARK: - Action
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        showAlert(title: NSLocalizedString("AddingCategory", comment: ""), message: NSLocalizedString("EnterName", comment: ""))
    }
    
    // MARK: - Helperві
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .white
        collectionView.register(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.reuseId)
        
        view.addSubview(collectionView)
        
    }
    
    private func setupSearchBar() {
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }
    
    private func reloadData(with searchText: String?) {
        
        fetchData()
        
        let filtered = categoryItem.filter { (category) -> Bool in
            category.contains(filter: searchText)
        }
        var snapshot = NSDiffableDataSourceSnapshot<SectionCategory, CategoryItem>()
        snapshot.appendSections([.categorySection])
        snapshot.appendItems(filtered, toSection: .categorySection)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    
    private func setupNavigationBar() {
        title = NSLocalizedString("Categories", comment: "")
        // navigationController?.navigationBar.
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        checkStyle()
        
    }
    
    private func checkStyle() {
        if styleDark {
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            addCategoryButton.tintColor = .white
            
        } else {
            navigationController?.navigationBar.barStyle = .default
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemOrange]
            addCategoryButton.tintColor = .black
        }
        
        if self.traitCollection.userInterfaceStyle  == .dark {
            styleDark = true
        } else {
            styleDark = false
        }
    }
}


// MARK: - Setup layout
extension CategoryViewController {
    
    private func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            
            guard let section = SectionCategory(rawValue: sectionIndex) else { fatalError("Unknown section kind") }
            
            switch section {
                
            case .categorySection:
                return self.createCategorySection()
            }
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        layout.configuration = config
        
        return layout
    }
    
    private func createCategorySection() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.6))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        
        let spacing = CGFloat(15)
        group.interItemSpacing = .fixed(spacing)
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets.init(top: 16, leading: 15, bottom: 0, trailing: 15)
        
        return section
    }
}

// MARK: - UICollectionViewDiffableDataSource
extension CategoryViewController {
    private func createDataSourse() {
        
        dataSource = UICollectionViewDiffableDataSource<SectionCategory, CategoryItem>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, category) -> UICollectionViewCell? in
            
            guard let section = SectionCategory(rawValue: indexPath.section) else { fatalError("Unknown section kind") }
            
            switch section {
                
            case .categorySection:
                
                return self.configure(collectionView: collectionView, cellType: CategoryCell.self, with: category, for: indexPath)
            }
        })
    }
}

//MARK: - UISearchBarDelegate
extension CategoryViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        reloadData(with: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        reloadData(with: nil)
    }
}

//MARK: - CategoryViewController Configure
extension CategoryViewController {
    
    func configure<T: SelfConfiguringCell, U: Hashable>(collectionView: UICollectionView, cellType: T.Type, with value: U, for indexPath: IndexPath) -> T {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellType.reuseId, for: indexPath) as? T else { fatalError("Unable to dequeue \(cellType)") }
        cell.configure(with: value)
        return cell
    }
}

// MARK: - CoreData

extension CategoryViewController {
    
    private func fetchData() {
        
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        
        let sort = NSSortDescriptor(key: "order", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        do {
            category = try viewContext.fetch(fetchRequest)
            
            categoryItem = category.map { CategoryItem(categoryStorage: $0) }
            
            
        } catch let error {
            print(error)
        }
    }
    
    private func save(_ categoryName: String) {
        guard let entityDescription = NSEntityDescription.entity(
            forEntityName: "Category",
            in: viewContext
        )
        else { return }
        
        let categor = NSManagedObject(entity: entityDescription, insertInto: viewContext) as! Category
        categor.name = categoryName.capitalizingFirstLetter()
        let minList = category.max { a, b in a.order < b.order }
        
        categor.order = (minList?.order ?? 0) + 1
        
        do {
            try viewContext.save()
            category.append(categor)
        } catch let error {
            print(error)
        }
        DispatchQueue.main.async {
            self.reloadData(with: nil)
        }
    }
}

// MARK: - Alert controller
extension CategoryViewController {
    
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
}

extension CategoryViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 30
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
        currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
}
