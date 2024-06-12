//
//  ListView.swift
//  mac-todolist
//
//  Created by Daffa Yagrariksa on 12/06/24.
//

import SwiftUI
import Combine

struct ListView: View {
    
    
    @State private var selectedCategory: Int = 0
    
    @FocusState private var focusView: FocusView?
    
    @ObservedObject private var viewModel = ListViewModel()
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Picker(selection: $viewModel.selectedCategory) {
                ForEach(viewModel.categories, id: \.self) { category in
                    Text(category)
                        .tag(category)
                }
            } label: {
                
            }

            TextField("Writing Articles", text: $viewModel.input)
                .onKeyPress(action: viewModel.handler(keyPress:))
                .focused($focusView, equals: .field)
            
            VStack {
                List(selection: $viewModel.suggestion_todos_selection) {
                    ForEach(viewModel.suggestions, id: \.self) { suggestion in
                        Text(suggestion)
                            .tag(suggestion)
                    }
                }
                .cornerRadius(8)
                .shadow(radius: 64)
                .focused($focusView, equals: .suggestion)
                .onKeyPress(action: viewModel.suggestionHandler(keyPress:))
            }
            .padding(.top, 16)
            
        }
        .onChange(of: viewModel.focusView, { focusView = viewModel.focusView})
    }
    
}

extension ListView {
    enum FocusView: Hashable, Equatable {
        case noFocus
        case field
        case suggestion
    }
}

class ListViewModel: ObservableObject {
    
    @Published var selectedCategory: String = "A"
    @Published var input: String = ""
    @Published private (set) var focusView: ListView.FocusView?
    @Published var suggestion_todos_selection: String = ""
    @Published private (set) var suggestionMode: SuggestionMode = .todo
    
    var suggestions: [String] {
        switch suggestionMode {
        case .todo:
            return filteredTodos
        case .category:
            return filteredCategoriesSuggestions
        }
    }
    
    var filteredCategoriesSuggestions: [String] {
        let splitted = input.split(separator: "@")
        guard splitted.count > 1,
              let keyword = splitted.last
        else { return categories }
        
        return categories.filter({ $0.lowercased().contains(keyword.lowercased()) })
    }
    
    var filteredTodos: [String] {
        guard input != "" else { return todos }
        return todos.filter({ $0.lowercased().contains(input.lowercased()) })
    }
    
    var categories: [String] = ["A", "B", "C"]
    
    var todos: [String] = [
        "Writing Article",
        "Cooking Dinner",
        "Running 5K",
        "Finishing Homework"
    ]
    
    private var cancellable = Set<AnyCancellable>()
    
    init() {
        $input
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] string in
                guard let weakSelf = self else { return }
                if weakSelf.suggestionMode == .category && string.last == Character(" ") {
                    weakSelf.suggestionMode = .todo
                    return
                }
                if string.last == Character("@") {
                    weakSelf.suggestionMode = .category
                    print("Switch suggestion")
                } else {
                    print(string)
                }
            }
            .store(in: &cancellable)
    }
    
    func handler(keyPress: KeyPress) -> KeyPress.Result {
        switch keyPress.key {
        case .upArrow:
            return .handled
        case .downArrow:
            focusView = .suggestion
            return .handled
        default:
            return .ignored
        }
    }
    
    func suggestionHandler(keyPress: KeyPress) -> KeyPress.Result {
        guard focusView == .suggestion else { return .ignored }
        
        if keyPress.key == .return {
            handleSuggestion()
            focusView = .field
            return .handled
        }  else if keyPress.key == .upArrow && suggestion_todos_selection == categories.first {
            focusView = .field
            return .ignored
        } else {
            return .ignored
        }
    }
    
    private func handleSuggestion() {
        switch suggestionMode {
        case .todo:
            input = suggestion_todos_selection
        case .category:
            selectedCategory = suggestion_todos_selection
            var splitter = input.split(separator: "@")
            if splitter.count > 1 {
                splitter.removeLast()
            }
            input = splitter.joined()
        }
    }
}

extension ListViewModel {
    enum SuggestionMode {
        case todo
        case category
    }
}

#Preview {
    ListView()
        .padding(.all, 64)
        .frame(width: 400, height: 600)
}
