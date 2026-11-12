//
//  CoreDataPersistable.swift
//  Chakame
//
//  Created by Milad on 2024-01-24.
//

import CoreData

protocol UUIDIdentifiable: Identifiable {
  var id: Int { get set }
}

protocol CoreDataPersistable: UUIDIdentifiable {
  associatedtype ManagedType
  init()
  init(managedObject: ManagedType?)
  var keyMap: [PartialKeyPath<Self>: String] { get }
  mutating func toManagedObject(context: NSManagedObjectContext) -> ManagedType

  func save(context: NSManagedObjectContext) throws
}

// MARK: - Managed Object
extension CoreDataPersistable where ManagedType: NSManagedObject {
  init(managedObject: ManagedType?) {
    self.init()
    guard let managedObject = managedObject else { return }
    for attribute in managedObject.entity.attributesByName {  // this gets attributes, not relationships
      if let keyP = keyMap.first(where: { $0.value == attribute.key })?.key {
        let value = managedObject.value(forKey: attribute.key)
        storeValue(value, toKeyPath: keyP)
      }
    }
  }

  private mutating func storeValue(_ value: Any?, toKeyPath partial: AnyKeyPath) {
    switch partial {
    case let keyPath as WritableKeyPath<Self, URL?>:
      self[keyPath: keyPath] = value as? URL
    case let keyPath as WritableKeyPath<Self, Int?>:
      self[keyPath: keyPath] = value as? Int
    case let keyPath as WritableKeyPath<Self, String?>:
      self[keyPath: keyPath] = value as? String
    case let keyPath as WritableKeyPath<Self, Bool?>:
      self[keyPath: keyPath] = value as? Bool
    case let keyPath as WritableKeyPath<Self, Double?>:
      self[keyPath: keyPath] = value as? Double
    case let keyPath as WritableKeyPath<Self, Int16?>:
      self[keyPath: keyPath] = value as? Int16
    case let keyPath as WritableKeyPath<Self, Int32?>:
      self[keyPath: keyPath] = value as? Int32

    default:
      return
    }
  }
  private func setValuesFromMirror(persistedValue: ManagedType) -> ManagedType {
    let mirror = Mirror(reflecting: self)
    for case let (label?, value) in mirror.children {
      let value2 = Mirror(reflecting: value)
      if value2.displayStyle != .optional || !value2.children.isEmpty {
        persistedValue.setValue(value, forKey: label)
      }
    }

    return persistedValue
  }

  func save(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) throws {
    try context.save()
  }
}
