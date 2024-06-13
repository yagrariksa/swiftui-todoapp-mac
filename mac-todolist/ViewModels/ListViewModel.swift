//
//  ListViewModel.swift
//  mac-todolist
//
//  Created by Daffa Yagrariksa on 13/06/24.
//

import Foundation
import Combine

class ListViewModel: ListViewModelProtocol {
    
    @Published private (set) var suggestionMode: SuggestionMode = .todo
    
    @Published var todos: [TodoItem] = [TodoItem]()
    @Published var todoInput: String = "" {
        didSet {
            let splitted = todoInput.split(separator: "@")
            guard splitted.count > 1 || todoInput.firstIndex(of: "@") == todoInput.startIndex,
                  let keyword = splitted.last
            else {
                if categoryInput != "" { categoryInput = "" }
                return
            }
            
            categoryInput = String(keyword)
        }
    }
    
    @Published var categoryInput: String = ""
    @Published var categories: [String] = [String]()
    @Published var selectedCategory: String = ""
   
    @Published var suggestion_todos_selection: String = ""
    
    var suggestions: [String] {
        switch suggestionMode {
        case .todo:
            return filteredTodos.map{ $0.title }
        case .category:
            return filteredCategoriesSuggestions
        }
    }
    
    var filteredCategoriesSuggestions: [String] {
        let splitted = todoInput.split(separator: "@")
        guard splitted.count > 1,
              let keyword = splitted.last
        else { return categories }
        
        return categories.filter({ $0.lowercased().contains(keyword.lowercased()) })
    }
    
    var filteredTodos: [TodoItem] {
        guard todoInput != "" else { return todos }
        return todos.filter({ $0.title.lowercased().contains(todoInput.lowercased()) })
    }
    
   

    private var cancellable = Set<AnyCancellable>()
    
    init() {
        $todoInput
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] string in
                guard let weakSelf = self else { return }
                if weakSelf.suggestionMode == .category &&
                    (string.last == Character(" ") || !string.contains("@"))
                {
                    weakSelf.suggestionMode = .todo
                    return
                }
                if string.last == Character("@") {
                    weakSelf.suggestionMode = .category
                    print("Switch suggestion")
                }
            }
            .store(in: &cancellable)
        
        populateData()
    }
    
    func handleSuggestion() {
        switch suggestionMode {
        case .todo:
            todoInput = suggestion_todos_selection
        case .category:
            if !categories.contains(where: {$0 == suggestion_todos_selection}) {
                categories.append(suggestion_todos_selection)
            }
            selectedCategory = suggestion_todos_selection
            var splitter = todoInput.split(separator: "@")
            if splitter.count > 1 || todoInput.firstIndex(of: "@") == todoInput.startIndex {
                splitter.removeLast()
            }
            todoInput = splitter.joined()
        }
    }
}

enum SuggestionMode {
    case todo
    case category
}

