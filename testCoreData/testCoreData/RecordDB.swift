//
//  Model.swift
//  testCoreData
//
//  Created by OT Chen on 2020/3/5.
//  Copyright © 2020 OTChen. All rights reserved.
//

import Foundation
import CoreData
import Combine


struct Record: Identifiable {
    var uuid: UUID = UUID()
    var name: String = ""
    var dice: Int = 0
    var time: Date = Date()
    
    var id: Date { return time }
    var timestampStr: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: time)
    }
    
}

extension Record {
    init(fromDb recordMO: RecordMO) {
        self.uuid = recordMO.uuid ?? UUID()
        self.name = recordMO.name ?? "N/A Name"
        self.dice = Int(recordMO.dice)
        self.time = recordMO.timestamp ?? Date()
    }
    
    func assign(to recordMO: RecordMO) {
        recordMO.uuid = self.uuid
        recordMO.name = self.name
        recordMO.dice = Int32(self.dice)
        recordMO.timestamp = self.time
    }
}

enum DBError : Error {
    case insertError(_ err: Error)
    case insertWrongType
    
    case fetchError(_ err: Error)
    case fetchWrongType
    
    case updateError(_ err: Error)
    case updateWrongType
    
    case deleteError(_ err: Error)
    case deleteWrongType
}

let recordEntityName = "Record"
class RecordDB {
    var persistentContainer: NSPersistentContainer
    init() {
        persistentContainer = NSPersistentContainer(name: "testCoreData")
        persistentContainer.loadPersistentStores { (desc: NSPersistentStoreDescription, error: Error?) in
            if error != nil {
                print("PlayCoreData init NG, error: \(String(describing: error))")
            }
            else {
                print("PlayCoreData desc: \(desc)")
            }
        }
    }
    
    func getRecords() -> Future<[Record], DBError> {
        Future<[Record], DBError> { (promise: @escaping (Result<[Record], DBError>) -> Void) in
            let cxt = self.persistentContainer.newBackgroundContext()
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: recordEntityName)
            request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
            do {
                if let records = try cxt.fetch(request) as? [RecordMO] {
                    promise(.success( records.map{Record(fromDb: $0)} ) )
                }
                else {
                    promise(.failure(.fetchWrongType))
                }
            }
            catch let e {
                promise(.failure(.fetchError(e)))
            }
        }
    }
    
    func add(record: Record) -> DBError? {
        guard let recordMo = NSEntityDescription.insertNewObject(forEntityName: recordEntityName,
                                                                 into: self.persistentContainer.viewContext) as? RecordMO else {
            return .insertWrongType
        }
        
        record.assign(to: recordMo)
        do {
            try self.persistentContainer.viewContext.save()
            return nil
        }
        catch let e {
            return .insertError(e)
        }
    }
    
    func delete(id: UUID) -> DBError? {
        let cxt = self.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: recordEntityName)
        request.predicate = NSPredicate(format: "uuid == %@", id.uuidString)
        request.resultType = .managedObjectIDResultType
        do {
            guard let ids = try cxt.fetch(request) as? [NSManagedObjectID] else {
                return .deleteWrongType
            }
            for id in ids {
                let obj = cxt.object(with: id)
                cxt.delete(obj)
                try cxt.save()
            }
            return nil
        }
        catch let e {
            return .deleteError(e)
        }
    }
    
    func deleteAll() -> DBError? {
        let cxt = self.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: recordEntityName)
        request.resultType = .managedObjectIDResultType
        do {
            guard let ids = try cxt.fetch(request) as? [NSManagedObjectID] else {
                return .deleteWrongType
            }
            for id in ids {
                let obj = cxt.object(with: id)
                cxt.delete(obj)
                try cxt.save()
            }
            return nil
        }
        catch let e {
            return .deleteError(e)
        }
    }
    
    
    func update(id: UUID, newValues: [String: Any]) -> DBError? {
        let cxt = self.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: recordEntityName)
        request.predicate = NSPredicate(format: "uuid == %@", id.uuidString)
        request.resultType = .managedObjectResultType
        do {
            guard let records = try cxt.fetch(request) as? [RecordMO] else {
                return .updateWrongType
            }
            for var record in records {
                if let val = newValues["dice"] as? Int {
                    record.dice = Int32(val)
                }
                if let val = newValues["timestamp"] as? Date {
                    record.timestamp = val
                }
                if let val = newValues["name"] as? String {
                    record.name = val
                }
                try cxt.save()
            }
            return nil
        }
        catch let e {
            return .updateError(e)
        }
    }
}
