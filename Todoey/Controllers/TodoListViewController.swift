//
//  ViewController.swift
//  Todoey
//
//  Created by Denis Goldberg on 29.08.18.
//  Copyright © 2018 Denis Goldberg. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
//     An optional array of results that consists of item objects.
    var todoItems: Results<Item>?
    
    let realm = try! Realm()
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        

        }
    
    override func viewWillAppear(_ animated: Bool) {
        
        title = selectedCategory?.name
        
        //      A guard let statement checks, like an optional binding method if a constant (navBar) has a value.
        //      If it is nil it returns the function in the else statement.
        //      But unlike an if let statement, we expect that the code works close to 99% of the time.
        //      In that case, we can use the guard let statement.
        guard let colorHex = selectedCategory?.color else {fatalError()}

        
        updateNavBar(withHexCode: colorHex)

        
    }
    
    override func viewWillDisappear(_ animated: Bool) {

        updateNavBar(withHexCode: "1D9BF6")
    }
    
    
    //    MARK: - Nav Bar Setup Methods
    
    func updateNavBar(withHexCode colorHexCode: String) {
        
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Controller does not exist")}
        
        guard let navBarColor = HexColor(colorHexCode) else {fatalError()}
        navBar.barTintColor = navBarColor
        
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
        
        searchBar.barTintColor = navBarColor
        
        //Remove Borders (Extra code outside of module)
        navBar.backgroundImage(for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        navBar.shadowImage = UIImage()
        searchBar.isTranslucent = false
        searchBar.backgroundImage = UIImage()

        
    }

    //    MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
//        So-called Nil Coalescing operator. Only get the count of categories if it is NOT nil.
//        If it IS nil it just returns 1.
        return todoItems?.count ?? 1

    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            
            cell.textLabel?.text = item.title
            
            if let color = HexColor(selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            
            
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
    //     MARK: - Deleting Items
    
    override func updateModel(at indexPath: IndexPath) {
        
        if let item = self.todoItems?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(item)
                }
            } catch {
                print("Error deleting item \(error)")
            }
        }
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
