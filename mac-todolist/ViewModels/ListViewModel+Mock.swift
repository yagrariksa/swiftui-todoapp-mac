//
//  ListViewModel+Mock.swift
//  mac-todolist
//
//  Created by Daffa Yagrariksa on 13/06/24.
//

import Foundation
import Combine

class MockListViewModel: ListViewModelProtocol {
    @Published var suggestionMode: SuggestionMode = .todo
    
    @Published var todos: [TodoItem] = [TodoItem]()
    
    @Published var selectedCategory: String = ""
    
    @Published var todoInput: String = ""
    
    @Published var categoryInput: String = ""
    
    @Published var categories: [String] = [String]()
     
    @Published var suggestion_todos_selection: String = ""
    
    var suggestions: [String] {
        switch suggestionMode {
        case .todo:
            return filteredTodos.map { $0.title }
        case .category:
            return filteredCategoriesSuggestions
        }
    }
    
    var filteredCategoriesSuggestions: [String] {
        return categories
    }
    
    var filteredTodos: [TodoItem] {
        return todos
    }
    
    func handleSuggestion() {
        // no-op
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
    
}
