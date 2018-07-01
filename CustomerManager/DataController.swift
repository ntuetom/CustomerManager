//
//  DataController.swift
//  CustomerManager
//
//  Created by Wu hung-yi on 2018/4/7.
//  Copyright © 2018 Wu. All rights reserved.
//
import UIKit
import CoreData

enum CustomerAttribute : String {
    case telephone = "telephone"
    case name = "name"
    case time = "time"
    case photo = "photo"
    case id = "id"
}

class DataController:NSObject{
    
    var manageContext: NSManagedObjectContext
    var customerFetch: NSFetchRequest<NSFetchRequestResult>
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    override init() {
        manageContext = appDelegate.persistentContainer.viewContext
        customerFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Customer")
        super.init()
    }
    
    func fetchCustomerData( complete: @escaping ( _ success: Bool, _ datas: [CustomerData]?, _ error: String? )->()) {
        let customers = try! manageContext.fetch(customerFetch) as! [Customer]
    
        var datas:[CustomerData] = []
        print("Customers number: \(customers.count))")
        if isEmpty() {
            complete(false,nil,"Empty Data")
        }
        for custom in customers{
            guard let name = custom.name else{
                print("data name is nil")
                continue
            }
            var customdata: CustomerData
            if let imageArray = custom.photo?.imageArray() {
                customdata = CustomerData(tel: custom.telephone!, name: name, lastId: Int(custom.id),currentTime:custom.time! as Date, photos: imageArray,isNew: false)
            } else {
                customdata = CustomerData(tel: custom.telephone!, name: name, lastId: Int(custom.id),currentTime:custom.time! as Date, isNew: false)
            }
            datas.append(customdata)
        }
        complete(true,datas,nil)
    }
    
    func fetchDataById(fetchId id: Int, completion: @escaping( _ datas: CustomerData?, _ error: String? )->()) {
        customerFetch.predicate = nil
        customerFetch.predicate = NSPredicate(format: "id = \(id)")
        do {
            let results = try manageContext.fetch(customerFetch) as! [Customer]
            if results.count > 0 {
                var customdata: CustomerData
                let custom = results[0]
                if let imageArray = custom.photo?.imageArray() {
                    customdata = CustomerData(tel: custom.telephone!, name: custom.name!, lastId: Int(custom.id),currentTime:custom.time! as Date, photos: imageArray,isNew: false)
                } else {
                    customdata = CustomerData(tel: custom.telephone!, name: custom.name!, lastId: Int(custom.id),currentTime:custom.time! as Date, isNew: false)
                }
                completion(customdata, nil)
            } else {
                completion(nil, "No thid id Data")
            }
        } catch let error as NSError {
            completion(nil, "Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func readCustomer() -> [CustomerData] {
        let customers = try! manageContext.fetch(customerFetch) as! [Customer]
        var datas:[CustomerData] = []
        print("Customers number: \(customers.count))")
        if isEmpty() {
            return datas
        }
        for custom in customers{
            guard let name = custom.name else{
                print("data name is nil")
                continue
            }
            var customdata: CustomerData
            if let imageArray = custom.photo?.imageArray() {
                customdata = CustomerData(tel: custom.telephone!, name: name, lastId: Int(custom.id),currentTime:custom.time! as Date, photos: imageArray,isNew: false)
            } else {
                customdata = CustomerData(tel: custom.telephone!, name: name, lastId: Int(custom.id),currentTime:custom.time! as Date, isNew: false)
            }
            datas.append(customdata)
        }
        return datas
    }
    
    func saveCustomer(saveData data:CustomerData,isNew new:Bool = true){
        let queue = DispatchQueue(label: "com.wu.customerManager")
        if !new {
            customerFetch.predicate = nil
            let updateID = data.id
            customerFetch.predicate = NSPredicate(format: "id = \(updateID)")
            print("update id \(data.id)")
            do {
                let results = try manageContext.fetch(customerFetch) as! [Customer]
                if results.count > 0 {
                    queue.async {
                        if data.images.coreDataRepresentation() != results[0].photo {
                            self.setCustomerValue(NSobject: results[0], saveData: data)
                        } else {
                            self.setCustomerValue(NSobject: results[0], saveData: data, shouldSaveImage: false)
                        }
                        self.appDelegate.saveContext()
                    }
                    
                }
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        } else {
            let entity = NSEntityDescription.entity(forEntityName: "Customer", in: manageContext)
            let object: NSManagedObject = NSManagedObject(entity: entity!, insertInto: manageContext)
            queue.async {
                self.setCustomerValue(NSobject: object,saveData: data)
                self.appDelegate.saveContext()
            }
        }
        
    
    }
    
    func setCustomerValue(NSobject: NSManagedObject, saveData data:CustomerData, shouldSaveImage: Bool = true){
        print("new id \(data.id)")
        NSobject.setValue(data.name, forKey: CustomerAttribute.name.rawValue)
        NSobject.setValue(data.id, forKey: CustomerAttribute.id.rawValue)
        NSobject.setValue(data.date, forKey: CustomerAttribute.time.rawValue)
        if shouldSaveImage {
            NSobject.setValue(data.images.coreDataRepresentation(), forKey: CustomerAttribute.photo.rawValue)
        }
        NSobject.setValue(data.tel, forKey: CustomerAttribute.telephone.rawValue)
    }
    
    func isEmpty() -> Bool{
        do {
            let count = try self.manageContext.count(for: customerFetch)
            print("data numbers \(count)")
            return count == 0 ? true : false
        } catch let err as NSError{
            print("Could not save. \(err), \(err.userInfo)")
            return true
        }
    }
}
