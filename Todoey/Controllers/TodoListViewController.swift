//
//  ViewController.swift
//  Todoey
//
//  Created by Giulio Gola on 05/06/2019.
//  Copyright © 2019 Giulio Gola. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    // Stores the persisted results in autoupdating container
    var todoItems : Results<Item>?
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    // load items as soon as the category is received from Category class
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        // Set Navigation bar layout after the VC has been stacked in the NavController
        guard let colorHex = selectedCategory?.backgroundColor else { fatalError("Todo color does not exist") }
        updateNavBar(withHexColor: colorHex)
        // Set title of navigation bar
        title = selectedCategory?.name
    }
    
    // Reset navBar to previous state when VC is dismissed
    override func viewWillDisappear(_ animated: Bool) {
        updateNavBar(withHexColor: "00B1FF")
        title = "Todoey"
    }
    
    // MARK - Update navigation bar
    func updateNavBar(withHexColor colorHexCode: String) {
        // Make sure navBar and color exist
        guard let navBar = navigationController?.navigationBar else { fatalError("Nav Bar does not exist") }
        guard let color = UIColor(hexString: colorHexCode) else { fatalError("HEX color does not exist") }
        // navBar background color
        navBar.barTintColor = color
        // Set color of NavBar buttons and large title to contrast with backgroundColor
        navBar.tintColor = ContrastColorOf(color, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(color, returnFlat: true)]
        // Set search bar background color
        searchBar.barTintColor = UIColor.white
    }
    
    // MARK - TableView Datasource methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
            cell.accessoryType = item.done ? .checkmark : .none
            if let color = UIColor(hexString: selectedCategory?.backgroundColor ?? "00B1FF")?.darken(byPercentage: 0.4 * CGFloat(indexPath.row)/CGFloat(todoItems!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
        } else {
            // No items in this category
            cell.textLabel?.text = "You're all set up for \(selectedCategory!.name)"
        }
        return cell
    }
    
    // MARK - TableView Delegate method
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Update item.done
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status \(error.localizedDescription)")
            }
        }
        tableView.reloadData()
    }
    
    // MARK - Add item
    func addItem() {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add a new item to \(selectedCategory!.name)", message: nil, preferredStyle: .alert)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "New item"
            textField = alertTextField
        }
        alert.addAction(UIAlertAction(title: "Add item", style: .default, handler: { (action) in
            if textField.text != "" {
                // Make sure a category has been passed to the VC
                if let currentCategory = self.selectedCategory {
                    do {
                        try self.realm.write {
                            // NOTE: when the new Realm Object (Item) is defined within the .write method it get automatically saved in the corresponding Realm class (Item) (no need to call .add(:Object))
                            let newItem = Item()
                            newItem.title = textField.text!
                            newItem.dateCreated = Date()
                            currentCategory.items.append(newItem)
                            // Realm runtime monitoring appends automatically newItem to the auto updating container todoItems (automatically sorted by dateCreated as initially done in loadItems())
                        }
                    } catch {
                        print("Error persisting item \(error.localizedDescription)")
                    }
                    self.tableView.reloadData()
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK - Add new items to tableView
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        addItem()
    }
    
    // MARK - Data manipulation
    func loadItems() {
        // Sorted by creation date
        todoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    
    // Override SwipeTableViewController method updateModel
    override func updateModel(at indexPath: IndexPath) {
        if let itemToDelete = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(itemToDelete)
                }
            } catch {
                print("Error deleting item \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Extension: Search bar delegate
extension TodoListViewController: UISearchBarDelegate {

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // Retrieve all todoItems
        loadItems()
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchItems(with: searchBar.text!)
    }

    // Handles when user deletes all the text or clicks the X
    // In this cases: reload all items
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        } else {
            // Start searching after an offset delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.searchItems(with: searchText)
            }
        }
    }
    
    // MARK - Search items
    func searchItems(with title: String) {
        // Reload all items
        loadItems()
        // Filter them with the current search text
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", title).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
}

