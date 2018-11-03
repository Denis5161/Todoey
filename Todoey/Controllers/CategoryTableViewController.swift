//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by Denis Goldberg on 07.10.18.
//  Copyright © 2018 Denis Goldberg. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryTableViewController: SwipeTableViewController {
    
    let realm = try! Realm()

    var categories: Results<Category>?
//     A collection of results that are <Category> objects. Marked as optional to be safe.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()


    }

    
    //    MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categories?.count ?? 1
//        So-called Nil Coalescing operator. Only get the count of categories if it is NOT nil.
//        If it IS nil it just returns 1.
    }
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! SwipeTableViewCell
//        cell.delegate = self
//        return cell
//    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = categories?[indexPath.row] {
            
        cell.textLabel?.text = category.name
        
        guard let categoryColor = HexColor(category.color) else {fatalError()}
        
        cell.backgroundColor = categoryColor
        
        cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
        }
        return cell
    }
    
    //    MARK: - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    //    MARK: - Data Manipulation Methods
    
    func loadCategories() {

        categories = realm.objects(Category.self)
    }
    
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
                }
        } catch {
            print("Error saving context, \(error)")
        }
        
        self.tableView.reloadData()
        }
    
    //    MARK: - Delete Date From Swipe
    
    override func updateModel(at indexPath: IndexPath) {

        if let categoryForDeletion = self.categories?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(categoryForDeletion)
                }
                } catch {
                    print("Error deleting category \(error)")
                }
            }
        }
    
    //    MARK: - Add New Categories

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Category", message:"", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.color = UIColor.randomFlat.hexValue()

            self.save(category: newCategory)
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new Category"
            textField = alertTextField
        }
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
}
