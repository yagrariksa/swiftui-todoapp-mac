//
//  ListView.swift
//  mac-todolist
//
//  Created by Daffa Yagrariksa on 12/06/24.
//

import SwiftUI
import Combine

struct ListView: View {
    
    @FocusState private var focusView: FocusView?
    
    @ObservedObject private var viewModel = ListViewModel()
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Picker(selection: $viewModel.selectedCategory) {
                ForEach(viewModel.categories, id: \.self) { category in
                    Text(category)
                        .tag(category)
                }
            } label: { }

            textField
            
            VStack {
                List(selection: $viewModel.suggestion_todos_selection) {
                    switch viewModel.suggestionMode {
                    case .todo:
                        ForEach(viewModel.filteredTodos, id: \.self) { suggestion in
                            Text(suggestion)
                                .frame(height: 36)
                                .listRowSeparator(.hidden, edges: .all)
                                .tag(suggestion)
                        }
                        
                    case .category:
                        ForEach(viewModel.filteredCategoriesSuggestions, id: \.self) { suggestion in
                            CategoryLabelView(category: .constant(suggestion), color: .constant(.green))
                                .frame(height: 36)
                                .listRowSeparator(.hidden, edges: .all)
                                .tag(suggestion)
                        }
                        
                        if viewModel.categoryInput != "" {
                            Text("Create \"\(viewModel.categoryInput)\"")
                                .foregroundStyle(TintShapeStyle())
                                .tint(.secondary)
                                .tag(viewModel.categoryInput)
                        }
                    }
                }
                .scrollIndicators(.automatic)
                .cornerRadius(8)
                .focused($focusView, equals: .suggestion)
                .onKeyPress(action: suggestionHandler(keyPress:))
            }
            .padding(.top, 16)
            
        }
        .onChange(of: viewModel.focusView, { focusView = viewModel.focusView})
    }
    
    @ViewBuilder
    var textField: some View {
        VStack {
            TextField("Writing Articles", text: $viewModel.todoInput)
                .onKeyPress(action: fieldHandler(keyPress:))
                .focused($focusView, equals: .field)
                .textFieldStyle(.plain)
                .font(.system(size: 14))
        }
        .modifier(textViewModifier())
    }
}

extension ListView {
    private func fieldHandler(keyPress: KeyPress) -> KeyPress.Result {
        guard keyPress.phase == .down else { return .ignored }
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
    
    private func suggestionHandler(keyPress: KeyPress) -> KeyPress.Result {
        guard focusView == .suggestion else { return .ignored }
        
        if keyPress.key == .return {
            viewModel.handleSuggestion()
            focusView = .field
            return .handled
        }  else if keyPress.key == .upArrow && viewModel.suggestion_todos_selection == viewModel.suggestions.first {
            focusView = .field
            return .ignored
        } else {
            return .ignored
        }
    }
}

extension ListView {
    enum FocusView: Hashable, Equatable {
        case noFocus
        case field
        case suggestion
    }
    
    struct textViewModifier: ViewModifier {
        func body(content: Content) -> some View {
            content
                .padding(.horizontal, 18)
                .padding(.vertical, 11.5)
                .background(LinearGradient(colors: [ Color(nsColor: .controlBackgroundColor)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .cornerRadius(8)
                .foregroundColor(.primary)
        }
    }
}

class ListViewModel: ObservableObject {
    
    @Published var selectedCategory: String = "A"
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
    @Published private (set) var focusView: ListView.FocusView?
    @Published var suggestion_todos_selection: String = ""
    @Published private (set) var suggestionMode: SuggestionMode = .todo
    
    @Published var categoryInput: String = ""
    
    var suggestions: [String] {
        switch suggestionMode {
        case .todo:
            return filteredTodos
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
    
    var filteredTodos: [String] {
        guard todoInput != "" else { return todos }
        return todos.filter({ $0.lowercased().contains(todoInput.lowercased()) })
    }
    
    var categories: [String] = ["A", "B", "C"]
    
    var todos: [String] = [
        "Writing Article",
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
        "Coding"
    ]
    
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

extension ListViewModel {
    enum SuggestionMode {
        case todo
        case category
    }
}

#Preview {
    ListView()
        .padding(.all, 32)
        .frame(width: 400, height: 600)
}
