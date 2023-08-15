//
//  ContentView.swift
//  TodoList
//
//  Created by MAHESHWARAN on 13/08/23.
//

import SwiftUI
import Combine

struct ContentView: View {
  @EnvironmentObject var dataStore: ToDoDataStore
  
  @State private var modelType: ToDoModelType? = nil
  
  var body: some View {
    NavigationStack {
      listView
        .listStyle(.insetGrouped)
        .toolbar {
          addButton
        }
        .navigationTitle("Task")
        .navigationBarTitleDisplayMode(.automatic)
        .sheet(item: $modelType) { $0 }
    }
  }
  
  private var listView: some View {
    List {
      ForEach(dataStore.toDos.value) { toDo in
        Button {
          modelType = .update(toDo)
        } label: {
          Text(toDo.name)
            .font(.title3)
            .strikethrough(toDo.completed)
            .foregroundColor(toDo.completed ? .green : Color(.label))
        }
      }.onDelete(perform: dataStore.deleteToDo.send)
    }
  }
  
  private var addButton: some ToolbarContent {
    ToolbarItem(placement: .navigationBarTrailing) {
      Button {
        modelType = .new
      } label: {
        Image(systemName: "plus.circle")
          .font(.title2)
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
