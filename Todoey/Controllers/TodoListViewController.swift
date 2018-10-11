//
//  ViewController.swift
//  Todoey
//
//  Created by Denis Goldberg on 29.08.18.
//  Copyright © 2018 Denis Goldberg. All rights reserved.
//

import UIKit
import RealmSwift

class TodoListViewController: UITableViewController {
    
    var todoItems: Results<Item>?
//     An optional array of results that consists of item objects.
    
    let realm = try! Realm()
    
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        }

    //    MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
//        So-called Nil Coalescing operator. Only get the count of categories if it is NOT nil.
//        If it IS nil it just returns 1.
        return todoItems?.count ?? 1

    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            
                    cell.textLabel?.text = item.title
            
            //                  A Ternary Operator.
            //                  value = condition ? valueIfTrue : valueIfFalse
            cell.accessoryType = item.done ? .checkmark : .none

        } else {
            cell.textLabel?.text = "No Items Added"
        }

        return cell
    }
    
    //    MARK: - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
//                    realm.delete(item)
//                    This deletes the item, instead of marking it as done
            
                }
                } catch {
                    print("Error saving done status, \(error)")
                }
            }
        
        
        tableView.reloadData()
        
//        When I used CoreData to update the database, I needed a context and it was far more convoluted than Realm.
//        todoItems[indexPath.row].done = !todoItems[indexPath.row].done
//
//        context.delete(todoItems[indexPath.row])
//        itemArray.remove(at: indexPath.row)
//        This deletes items from the context. This isn't a very good UX though.
//        You need to call saveItems() when changing the persistent container to update the database.
//
//        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    //    MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
//            What will happen once the user taps on the Add Item button on our UIAlert
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                    let newItem = Item()
                    newItem.title = textField.text!
                    newItem.dateCreated = Date()
                    currentCategory.items.append(newItem)
            
                    }
                } catch {
                    print("Error saving new items, \(error)")
                }
            }
            
            self.tableView.reloadData()
          
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    //    MARK: - Model Manipulation Methods
    

    func loadItems() {
        
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    }
}

// MARK: - Search bar methods

//A so-called extension to separate the class into different functions.
//Very important to modularize! Reduce bug-checking. Group protocol methods together-> Very Swifty way of programming.

extension TodoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: false)
        tableView.reloadData()
        
//    Realm replaces these lines of code into one line. The items also don't need to be called like before, because we just filter the items.
//        let request : NSFetchRequest<Item> = Item.fetchRequest()
//
//        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
//
//        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//
//        loadItems(with: request, predicate: predicate)

    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
//          Remove the keyboard after clicking on the little x button in the search bar.
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
}
