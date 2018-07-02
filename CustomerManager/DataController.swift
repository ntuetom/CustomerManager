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

class DataController: NSObject {
    
    var customerFetch: NSFetchRequest<NSFetchRequestResult>
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "CustomerManager")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    override init() {
        customerFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Customer")
        super.init()
    }
    
    func fetchCustomerData( complete: @escaping ( _ success: Bool, _ datas: [CustomerData]?, _ error: String? )->()) {
        let context = persistentContainer.viewContext
        let customers = try! context.fetch(customerFetch) as! [Customer]
    
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
            let context = persistentContainer.viewContext
            let results = try context.fetch(customerFetch) as! [Customer]
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
        let context = persistentContainer.viewContext
        let customers = try! context.fetch(customerFetch) as! [Customer]
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
                let context = persistentContainer.viewContext
                let results = try context.fetch(customerFetch) as! [Customer]
                if results.count > 0 {
                    queue.async {
                        if data.images.coreDataRepresentation() != results[0].photo {
                            self.setCustomerValue(NSobject: results[0], saveData: data)
                        } else {
                            self.setCustomerValue(NSobject: results[0], saveData: data, shouldSaveImage: false)
                        }
                        self.saveContext()
                    }
                    
                }
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        } else {
            let context = persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "Customer", in: context)
            let object: NSManagedObject = NSManagedObject(entity: entity!, insertInto: context)
            queue.async {
                self.setCustomerValue(NSobject: object,saveData: data)
                self.saveContext()
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
            let context = persistentContainer.viewContext
            let count = try context.count(for: customerFetch)
            print("data numbers \(count)")
            return count == 0 ? true : false
        } catch let err as NSError{
            print("Could not save. \(err), \(err.userInfo)")
            return true
        }
    }
}
