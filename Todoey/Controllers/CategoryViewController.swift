//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Giulio Gola on 06/06/2019.
//  Copyright © 2019 Giulio Gola. All rights reserved.
//
//  Table view with the todo categories set by the users
//  User can add new categories and delete a category by swiping right -> left (handled by editActionsForRowAt in SwipeTableViewController)

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {

    let realm = try! Realm()
    // Stores the persisted results in autoupdating container
    var categories : Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        promptUser()
    }
    
    // MARK: - Table view data source methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = categories?[indexPath.row].name ?? "Yay! You're all set here"
        let color = UIColor(hexString: categories?[indexPath.row].backgroundColor ?? "00B1FF")
        cell.backgroundColor = color!
        // ContrastColorOf is from Chameleon framework
        cell.textLabel?.textColor = ContrastColorOf(color!, returnFlat: true)
        cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 18)
        return cell
    }
    
    // MARK: - Table view delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Pass selected category
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        // .indexPathForSelectedRow: Grab current cell index and pass category
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    // MARK: - Data manipulation
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error persisting category \(error.localizedDescription)")
        }
        tableView.reloadData()
    }
    
    // Load data of Category type
    func loadCategories() {
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    // Delete data after swiping (overriding updateModel from SwipeTableViewController)
    override func updateModel(at indexPath: IndexPath) {
        // updateModel is doing nothing until here so no need to call super.updateModel(at: indexPath)
        if let categoryToDelete = categories?[indexPath.row] {
            do {
                try realm.write {
                    // Delete all category items and category
                    let categoryItems = categoryToDelete.items
                    realm.delete(categoryItems)
                    realm.delete(categoryToDelete)
                }
            } catch {
                print("Error deleting category \(error.localizedDescription)")
            }
            promptUser()
        }
    }
    
    // MARK: - Prompt user
    func promptUser() {
        if categories?.count == 0 {
            let alert = UIAlertController(title: "Yay! You're all set here", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Add a Todo", style: .default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
                self.addCategory()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Add category
    func addCategory() {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new a Todo", message: nil, preferredStyle: .alert)
        alert.addTextField { (textFieldAlert) in
            textFieldAlert.placeholder = "Todo's title"
            textField = textFieldAlert
        }
        alert.addAction(UIAlertAction(title: "Add Todo", style: .default, handler: { (action) in
            if textField.text != "" {
                let newCategory = Category()
                newCategory.name = textField.text!
                // Generate a randomFlat color - get Hex value
                let color = UIColor.randomFlat.hexValue()
                newCategory.backgroundColor = color
                // Realm runtime monitoring appends automatically newCategory to the autoupdating container Results<Category>
                // Save new category in local DB
                self.save(category: newCategory)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: - Add new items in category list
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        addCategory()
    }
}
