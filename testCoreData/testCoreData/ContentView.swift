//
//  ContentView.swift
//  testCoreData
//
//  Created by OT Chen on 2020/3/3.
//  Copyright © 2020 OTChen. All rights reserved.
//

import SwiftUI
import CoreData
import Combine


struct ContentView: View {
    var recordDB = RecordDB()
    
    @State private var records: [Record] = [
        Record(name: "Alice", dice: 5, time: Date() - 2),
        Record(name: "Bob", dice: 2, time: Date() - 1),
        Record(name: "Alice", dice: 4, time: Date())
    ]

    @State var myCancellabel: AnyCancellable? = nil
    
    var body: some View {
        VStack {
            HStack{
                Text("\(records.count) Records")
            }
            VStack {
                HStack{
                    Text("Name").font(.headline)
                        .frame(width: 120)
                    Text("Dice").font(.headline)
                    Spacer()
                    Text("Time").font(.subheadline)
                        .frame(width: 100, alignment: .leading)
                    Text("")
                        .foregroundColor(.primary)
                        .frame(width: 40, alignment: .leading)
                }.padding(.horizontal, 10)
                
                Divider()
                
                ForEach(records){ record in
                    HStack{
                        Text("\(record.name)").font(.headline)
                            .frame(width: 120, alignment: .leading)
                        Text("\(record.dice)").font(.headline)
                        Spacer()
                        Text("\(record.timestampStr)")
                            .font(.subheadline)
                            .frame(width: 100, alignment: .leading)
                        
                        Button(action: {
                            self.recordDB.update(id: record.uuid, newValues: ["dice": Int.random(in: 0..<6)])
                            self.myCancellabel = self.recordDB.getRecords()
                                .receive(on: RunLoop.main)
                                .sink(receiveCompletion: { result in
                                    if case .failure(let err) = result {
                                        print("err: \(err)")
                                    }
                                },receiveValue: { (records: [Record]) in
                                    self.records = records
                                })
                        }, label: {
                            Image(systemName: "gamecontroller")
                                .foregroundColor(.black)
                                .frame(width: 20, alignment: .leading)
                        })
                        Button(action: {
                            self.recordDB.delete(id: record.uuid)
                            self.myCancellabel = self.recordDB.getRecords()
                                .receive(on: RunLoop.main)
                                .sink(receiveCompletion: { result in
                                    if case .failure(let err) = result {
                                        print("err: \(err)")
                                    }
                                },receiveValue: { (records: [Record]) in
                                    self.records = records
                                })
                        }, label: {
                            Image(systemName: "x.circle.fill")
                                .foregroundColor(.red)
                                .frame(width: 20, alignment: .leading)
                        })

                    }.padding(.horizontal, 10)
                    Divider()
                }
            }
            Spacer()
            HStack {
                Group {
                    Button(action: {
                        _ = self.recordDB.add(record: Record(name: "Alice", dice: Int.random(in: 0..<6), time: Date()))
                        self.myCancellabel = self.recordDB.getRecords()
                            .receive(on: RunLoop.main)
                            .sink(receiveCompletion: { result in
                                if case .failure(let err) = result {
                                    print("err: \(err)")
                                }
                            },receiveValue: { (records: [Record]) in
                                self.records = records
                            })
                    }, label: {
                        Text("Add as Alice")
                            .padding(.init(top: 10, leading: 20, bottom: 10, trailing: 20))
                    })
                        .background(Color.green)
                    
                    Button(action: {
                        _ = self.recordDB.add(record: Record(name: "Bob", dice: Int.random(in: 0..<6), time: Date()))
                        self.myCancellabel = self.recordDB.getRecords()
                            .receive(on: RunLoop.main)
                            .sink(receiveCompletion: { result in
                                if case .failure(let err) = result {
                                    print("err: \(err)")
                                }
                            },receiveValue: { (records: [Record]) in
                                self.records = records
                            })
                        
                    }, label: {
                        Text("Add as Bob")
                            .padding(.init(top: 10, leading: 20, bottom: 10, trailing: 20))
                    })
                        .background(Color.yellow)
                    
                    Button(action: {
                        self.myCancellabel = self.recordDB.getRecords()
                            .receive(on: RunLoop.main)
                            .sink(receiveCompletion: { result in
                                if case .failure(let err) = result {
                                    print("err: \(err)")
                                }
                            },receiveValue: { (records: [Record]) in
                                self.records = records
                            })
                    }, label: {
                        Text("Refresh")
                            .padding(.init(top: 10, leading: 20, bottom: 10, trailing: 20))
                    })
                        .background(Color.blue)

                    Button(action: {
                        self.recordDB.deleteAll()
                        self.myCancellabel = self.recordDB.getRecords()
                            .receive(on: RunLoop.main)
                            .sink(receiveCompletion: { result in
                                if case .failure(let err) = result {
                                    print("err: \(err)")
                                }
                            },receiveValue: { (records: [Record]) in
                                self.records = records
                            })
                    }, label: {
                        Text("Delete All")
                            .padding(.init(top: 10, leading: 20, bottom: 10, trailing: 20))
                    })
                        .background(Color.red)
                }
                    .foregroundColor(.white)
                    .cornerRadius(CGFloat(10.0))
            }
            .padding()
        }
        .onAppear{
            // _ = self.playCoreData
            // self.records = self.playCoreData.query()
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

