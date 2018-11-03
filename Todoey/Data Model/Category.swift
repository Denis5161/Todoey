//
//  Category.swift
//  Todoey
//
//  Created by Denis Goldberg on 08.10.18.
//  Copyright © 2018 Denis Goldberg. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    
    @objc dynamic var name : String = ""
    @objc dynamic var color : String = ""
    
    let items = List<Item>()
}
