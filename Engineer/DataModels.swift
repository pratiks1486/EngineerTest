//
//  DataModels.swift
//  Engineer
//
//  Created by Abhishek Dave on 30/08/19.
//  Copyright © 2019 Apple Developer. All rights reserved.
//

import Foundation

//Mark: Algolia - Main data wrapper class
class Algolia: Codable {
    var hits: [Post] = []
    var page: Int = 0
    var nbPages: Int = 0
}

//Mark: Post - Data Class
class Post: Codable {
    var title: String = ""
    var author: String = ""
    var created_at: String = ""
}

extension Post {
    struct PostKeys {
        static var isSelected : String = "Selectable.isSelected"
    }
    
    var isSelected: Bool {
        get{
            return (objc_getAssociatedObject(self, &PostKeys.isSelected) as? Bool) ?? false
        }
        set{
            objc_setAssociatedObject(self, &PostKeys.isSelected, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}


extension Array where Element: Post {
    var allSelectedValues: [Element] {
        return self.filter({ (element) -> Bool in
            return element.isSelected
        })
    }
    
    func select(at index: Int){
        let element = self[index]
        element.isSelected = true
    }
    func deselect(at index: Int){
        let element = self[index]
        element.isSelected = false
    }
    
    private func selectDeselectAll(select: Bool){
        self.forEach { (element) in
            element.isSelected = select
        }
    }
}
