//
//  ContentView.swift
//  testCoreData
//
//  Created by OT Chen on 2020/3/3.
//  Copyright © 2020 OTChen. All rights reserved.
//

import SwiftUI
import CoreData


struct Record : Identifiable {
    var id: Date { return timestamp }
    
    var bpm: Int16 = 0
    var timestamp: Date = Date()
}


struct ContentView: View {
    fileprivate var playCoreData = PlayCoreData()
    @State private var records: [Record] = [
        Record(bpm: 130, timestamp: Date() - 2),
        Record(bpm: 150, timestamp: Date() - 1),
        Record(bpm: 140, timestamp: Date())
    ]
    
    var body: some View {
        VStack {
            ForEach(records){ record in
                VStack{
                    Text("\(record.bpm)")
                        .font(.headline)
                    Text("\(record.timestamp)")
                        .font(.subheadline)
                }
            }
            Button(action: {
                self.playCoreData.add()
                self.records = self.playCoreData.query()
            }, label: {
                Text("Add")
            })
        }
        .onAppear{
            _ = self.playCoreData
            self.records = self.playCoreData.query()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


fileprivate class PlayCoreData {
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
    func query() -> [Record] {
        let recordFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Record")
        do {
            guard let records = try self.persistentContainer.viewContext.fetch(recordFetch) as? [RecordMO] else {
                fatalError()
            }
            return records.map{ (recordMO: RecordMO) in
                Record(bpm: recordMO.bpm , timestamp: recordMO.timestamp ?? Date())
            }
        }
        catch let e {
            print("fetch error: \(e)")
            return []
        }
        //self.persistentContainer.viewContext
    }
    func add() {
        guard let record = NSEntityDescription.insertNewObject(forEntityName: "Record", into: self.persistentContainer.viewContext) as? RecordMO else {
            fatalError()
        }
        
        record.bpm = 130 + Int16.random(in: 0..<40)
        record.timestamp = Date()
        do {
            try self.persistentContainer.viewContext.save()
        }
        catch let e {
            print("save error: \(e)")
        }
    }
}
