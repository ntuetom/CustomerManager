//
//  Customer+CoreDataProperties.swift
//  CustomerManager
//
//  Created by Wu hung-yi on 2018/4/11.
//  Copyright © 2018 Wu. All rights reserved.
//
//

import Foundation
import CoreData


extension Customer {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Customer> {
        return NSFetchRequest<Customer>(entityName: "Customer")
    }

    @NSManaged public var photo: NSData?
    @NSManaged public var name: String?
    @NSManaged public var telephone: String?
    @NSManaged public var time: NSDate?
    @NSManaged public var id: Int16

}
