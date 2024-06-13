//
//  TodoItem.swift
//  mac-todolist
//
//  Created by Daffa Yagrariksa on 13/06/24.
//

import Foundation
import SwiftUI

struct TodoItem: Hashable {
    var id = UUID().uuidString
    var finished: Bool
    var title: String
    var category: String
    var categoryColor: Color?
    
    init(title: String, category: String, categoryColor: Color? = nil, finished: Bool = false) {
        self.finished = finished
        self.title = title
        self.category = category
        self.categoryColor = categoryColor
    }
}
