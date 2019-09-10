//
//  SwipeTableViewController.swift
//  Todoey
//
//  Created by Giulio Gola on 07/06/2019.
//  Copyright © 2019 Giulio Gola. All rights reserved.
//
//  This is the superclass that manages the tableViews of the CategoryVC and TodoListVC
//  SwipeCellKit is used to implement the swipe-to-delete functionality

import UIKit
import SwipeCellKit

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        // Parameters are passed to the cell by overriding this method in CategoryVC and TodoListVC
        return cell
    }
    
    // Delegate methods from SwipeCellKit
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        // Valid swipe is only rigth to left
        guard orientation == .right else { return nil }
        // SwipeAction is a SwipeCellKit method
        let deleteAction = SwipeAction(style: .destructive, title: nil) { action, indexPath in
            // updateModel is overridden in the classes inheriting from this class
            self.updateModel(at: indexPath)
        }
        deleteAction.image = UIImage(named: "deleteCircle")
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
    
    // This method is here declared just so it can be overridden in the class inheriting from this class
    func updateModel(at indexPath: IndexPath) {
    }
}
