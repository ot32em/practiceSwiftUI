//
//  ContentView.swift
//  testCoreData
//
//  Created by OT Chen on 2020/3/3.
//  Copyright © 2020 OTChen. All rights reserved.
//

import SwiftUI
import CoreData


struct ContentView: View {
    @FetchRequest(
        entity: DiceRecordMO.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \DiceRecordMO.time, ascending: false)])
    private var records: FetchedResults<DiceRecordMO>

    @Environment(\.managedObjectContext)
    private var cxt: NSManagedObjectContext
    
    @State var player: Int = 0
    let players = ["Alice", "Bob", "Charlie", "Daniel"]

    var body: some View {
        VStack{
            HStack{
                Picker("Player", selection: $player) {
                    ForEach(players.indices, id: \.self) { i in
                        Text(self.players[i]).tag(Int(i))
                    }
                }.pickerStyle(SegmentedPickerStyle())
                Button("Roll", action: { self.addRecord() }).padding(.horizontal, 20)
            }.padding()

            List(records, id: \.self){ record in
                HStack{
                    Text("\(record.displayName)")
                    Text("\(record.dice)")
                    Spacer()
                    Text("\(record.displayTime)")
                    Button("Update", action: { self.updateRecord(of: record.uuid)}).buttonStyle(BorderlessButtonStyle())
                    Button("Delete", action: { self.deleteRecord(of: record.uuid)}).buttonStyle(BorderlessButtonStyle())
                }
            }
            Spacer()
            Button("Delete All", action: { self.deleteAllRecords() }).padding()
        }
    }

    func addRecord(){
        let record = DiceRecordMO(context: cxt)
        record.name = self.players[self.player]
        record.dice = Int32.random(in: 0..<6)
        record.time = Date()
        record.uuid = UUID()
        try! cxt.save()
    }
    func updateRecord(of uuid: UUID?) {
        guard let uuid = uuid else { return }
        records
            .filter{$0.uuid != nil && $0.uuid! == uuid}
            .forEach{ (record: DiceRecordMO) in
                record.dice = Int32.random(in: 0..<6)
                try! cxt.save()
            }
    }
    func deleteRecord(of uuid: UUID?) {
        guard let uuid = uuid else { return }
        records
            .filter{ $0.uuid != nil && $0.uuid == uuid }
            .forEach{ cxt.delete($0)}
    }
    func deleteAllRecords(){
        records
            .forEach{ cxt.delete($0) }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return ContentView().environment(\.managedObjectContext, context)
    }
}
