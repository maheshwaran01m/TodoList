//
//  TodoListApp.swift
//  TodoList
//
//  Created by MAHESHWARAN on 13/08/23.
//

import SwiftUI

@main
struct TodoListApp: App {
  
  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(ToDoDataStore())
    }
  }
}
