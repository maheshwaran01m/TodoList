//
//  ToDoListFormView.swift
//  TodoList
//
//  Created by MAHESHWARAN on 15/08/23.
//

import SwiftUI

struct ToDoListFormView: View {
  
  @EnvironmentObject var dataStore: ToDoDataStore
  @Environment(\.presentationMode) var presentationMode
  
  @ObservedObject var formVM: ToDoFormViewModel
  
  var body: some View {
    NavigationStack {
      Form {
        VStack(alignment: .leading) {
          TextField("ToDo", text: $formVM.name)
          Toggle("Completed", isOn: $formVM.completed)
        }
      }
      .navigationTitle("To Do")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          updateSaveButton
        }
        ToolbarItem(placement: .navigationBarLeading) { cancelButton }
        
      }
    }
  }
}

extension ToDoListFormView {
  
  private func updateToDo() {
    let toDo = ToDoList(id: formVM.id ?? "", name: formVM.name,
                        completed: formVM.completed)
    dataStore.updateToDo.send(toDo)
    presentationMode.wrappedValue.dismiss()
  }
  
  private func addToDo() {
    let toDo = ToDoList(name: formVM.name)
    dataStore.addToDo.send(toDo)
    presentationMode.wrappedValue.dismiss()
  }
  
  var cancelButton: some View {
    Button("Cancel") {
      presentationMode.wrappedValue.dismiss()
    }
  }
  
  var updateSaveButton: some View {
    Button(formVM.updating ? "Update" : "Save", action: formVM.updating ? updateToDo : addToDo)
      .disabled(formVM.isDisabled)
  }
}

// MARK: - Preview
struct ToDoListFormView_Previews: PreviewProvider {
  
  static var previews: some View {
    ToDoListFormView(formVM: ToDoFormViewModel())
  }
}
