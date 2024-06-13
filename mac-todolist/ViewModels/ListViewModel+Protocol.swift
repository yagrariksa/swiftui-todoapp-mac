//
//  ListViewModel+Protocols.swift
//  mac-todolist
//
//  Created by Daffa Yagrariksa on 13/06/24.
//

import Foundation

protocol ListViewModelProtocol: ObservableObject {
    var suggestionMode: SuggestionMode { get }
    
    var todos: [TodoItem] { get set }
    var todoInput: String { get set }
    
    var categoryInput: String { get set }
    var categories: [String] { get set }
    var selectedCategory: String { get set }
    
    var suggestion_todos_selection: String { get set }
    
    var suggestions: [String] { get }
    var filteredCategoriesSuggestions: [String] { get }
    var filteredTodos: [TodoItem] { get }
    
    func handleSuggestion()
}


extension ListViewModelProtocol {
    internal func populateData() {
        [ "Work",
          "Schools",
          "Home",
          "Gym",
          "Personal"].forEach { category in
            categories.append(category)
        }
        
        ["Writing Article",
         "Cooking Dinner",
         "Running 5K",
         "Finishing Homework",
         "Reading Book",
         "Lorem Ipsum",
         "Dolor sit",
         "Amet",
         "Another Thing",
         "Cycling",
         "Swimming",
         "Coding"].forEach { title in
            guard let randomCategory = categories.randomElement() else { return }
            todos.append(.init(title: title, category: randomCategory))
        }
        
        guard let randomCategory = categories.randomElement() else { return }
        selectedCategory = randomCategory
    }
}