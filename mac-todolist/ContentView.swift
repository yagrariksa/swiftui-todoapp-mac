//
//  ContentView.swift
//  mac-todolist
//
//  Created by Daffa Yagrariksa on 12/06/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ListView(viewModel: ListViewModel())
            .padding(.all, 32.0)
    }
}

#Preview {
    ContentView()
}
