//
//  ToDoFormViewModel.swift
//  TodoList
//
//  Created by MAHESHWARAN on 15/08/23.
//

import SwiftUI

class ToDoFormViewModel: ObservableObject {
  
  @Published var name = ""
  @Published var completed = false
  var id: String?
  
  var updating: Bool {
    id != nil
  }
  
  var isDisabled: Bool {
    name.isEmpty
  }
  
  init() {}
  
  init(_ currentToDo: ToDoList) {
    self.name = currentToDo.name
    self.completed = currentToDo.completed
    id = currentToDo.id
  }
}
