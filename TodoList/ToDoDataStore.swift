//
//  ToDoDataStore.swift
//  TodoList
//
//  Created by MAHESHWARAN on 15/08/23.
//

import Combine
import SwiftUI

struct ToDoList: Identifiable, Codable {
  var id: String = UUID().uuidString
  var name: String
  var completed: Bool = false
  
  static var example: [ToDoList] {
    [ToDoList(name: "Get Groceries"), ToDoList(name: "Make Appointment", completed: true)]
  }
}

//MARK: - ToDoDataStore

class ToDoDataStore: ObservableObject {
  
  let fileName = "ToDoList.json"
  
  // MARK: - combine
  var toDos = CurrentValueSubject<[ToDoList], Never>([])
  var subscription = Set<AnyCancellable>()
  
  var addToDo = PassthroughSubject<ToDoList, Never>()
  var updateToDo = PassthroughSubject<ToDoList, Never>()
  var deleteToDo = PassthroughSubject<IndexSet, Never>()
  
  var loadToDos = Just(URL.documentsDirectory.appendingPathComponent("ToDoList.json"))
  
  // Init
  init() {
    addSubscriptions()
  }
  
  // MARK: - Combine
  
  private func addSubscriptions() {
    
    // MARK: Load Data
    loadToDos
      .filter { FileManager.default.fileExists(atPath: $0.path())}
      .tryMap { url in
        try Data(contentsOf: url)
      }
      .decode(type: [ToDoList].self, decoder: JSONDecoder())
      .subscribe(on: DispatchQueue(label: "background_ToDoList_queue"))
      .receive(on: DispatchQueue.main)
      .sink { [weak self] result in
        switch result {
        case .finished:
          print("Loading")
          self?.toDoSaveSubscription()
        case .failure(let error):
          print(error.localizedDescription)
        }
      } receiveValue: { item in
        self.objectWillChange.send()
        self.toDos.value = item
      }.store(in: &subscription)
    
    // MARK: add
    addToDo.sink { [unowned self] item in
      self.objectWillChange.send()
      toDos.value.append(item)
    }
    .store(in: &subscription)
    
    // MARK: update
    updateToDo.sink { [unowned self] item in
      guard let index = toDos.value.firstIndex(where: { $0.id == item.id }) else {
        return
      }
      self.objectWillChange.send()
      toDos.value[index] = item
    }.store(in: &subscription)
    
    // MARK: delete
    deleteToDo.sink { [unowned self] index in
      self.objectWillChange.send()
      toDos.value.remove(atOffsets: index)
    }.store(in: &subscription)
  }
  
  // MARK: Save
  
  private func toDoSaveSubscription() {
    toDos
      .subscribe(on: DispatchQueue(label: "background_ToDoList_queue"))
      .receive(on: DispatchQueue.main)
      .dropFirst()
      .encode(encoder: JSONEncoder())
      .tryMap { data in
        try data.write(to: URL.documentsDirectory.appendingPathComponent("ToDoList.json"))
      }.sink { result in
        switch result {
        case .finished:
          print("Saving Completed")
        case .failure(let error):
          print(error.localizedDescription)
        }
      } receiveValue: { _ in
        print("Saving File was successful")
      }
      .store(in: &subscription)
  }
}

// MARK: - ToDoModelType

enum ToDoModelType: Identifiable, View {
  
  case new, update(ToDoList)
  
  var id: String {
    switch self {
    case .new: return "New"
    case .update: return "Update"
    }
  }
  
  var body: some View {
    switch self {
    case .new: return ToDoListFormView(formVM: ToDoFormViewModel())
    case .update(let todo): return ToDoListFormView(formVM: ToDoFormViewModel(todo))
    }
  }
}

// MARK: - FileManager SaveDocument

extension FileManager {
  
  func saveDocument(_ contents: String, fileName: String, completion: (Error?) -> Void) {
    let documentURL = URL.documentsDirectory.appendingPathComponent(fileName)
    
    do {
      try contents.write(to: documentURL, atomically: true, encoding: .utf8)
    } catch {
      completion(error)
    }
  }
  
  func readDocument(fileName: String, completion: (Result<Data, Error>) -> Void) {
    let documentURL = URL.documentsDirectory.appendingPathComponent(fileName)
    do {
      let data = try Data(contentsOf: documentURL)
      completion(.success(data))
    } catch {
      completion(.failure(error))
    }
  }
  
  func isFileExist(for fileName: String) -> Bool {
    fileExists(atPath: URL.documentsDirectory.appendingPathComponent(fileName).path())
  }
}
