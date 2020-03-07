//
//  DiceRecord.swift
//  testCoreData
//
//  Created by Ot Chen on 2020/3/6.
//  Copyright © 2020 OTChen. All rights reserved.
//

import Foundation
import CoreData

@objc(DiceRecordMO)
class DiceRecordMO : NSManagedObject {
    @NSManaged var uuid: UUID?
    @NSManaged var name: String?
    @NSManaged var dice: Int32
    @NSManaged var time: Date?
    
    var displayGuid: String { (uuid ?? UUID()).uuidString }
    var displayName: String { name ?? "%unnamed%" }
    static var formatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss"
        return f
    }
    var displayTime: String { DiceRecordMO.formatter.string(from: time ?? Date()) }
}
