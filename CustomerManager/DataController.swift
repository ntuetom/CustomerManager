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
    case datePath = "datePath"
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
            let customdata = CustomerData(tel: custom.telephone!, name: name, lastId: Int(custom.id), isNew: false)
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
                var customdata: CustomerData!
                let custom = results[0]
                //get the first Date Images
                guard let datesPath = custom.datePath else {
                    completion(nil, "No thid datePath Data")
                    return
                }
                DispatchQueue.main.async {
                    if datesPath.count > 0 {
                        var arrayOfImagesDictionary: ImageDictionary = ImageDictionary()
                        var arrayOfImages: ImageArray = []
                        let keyWithName = "\(String(custom.id))"
                        let dateString = datesPath[datesPath.count - 1].toString()
                        let path = "\(keyWithName)/\(dateString)"
                        let file = AppFile(fileName: "")
                        let imageCount = file.getNumberOfFiles(at: path)
                        for count in 1...imageCount {
                            let fileToRead = AppFile(fileName: "image\(count-1).png")
                            
                            if let readImage = fileToRead.readCustomer(at: path) {
                                arrayOfImages.append(readImage)
                            }
                        }
                        arrayOfImagesDictionary[dateString] = arrayOfImages
                        customdata = CustomerData(tel: custom.telephone!, name: custom.name!, lastId: Int(custom.id), photos: arrayOfImagesDictionary, pathes: custom.datePath!, isNew: false)
                    }
                    completion(customdata, nil)
                }
            } else {
                completion(nil, "No thid id Data")
            }
        } catch let error as NSError {
            completion(nil, "Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func updateCustomer(saveData data: CustomerData, atImageKey keys: [Date: Int], image: UIImage, kind: DataChangeType, isNew new:Bool = true){
        
        if kind == .imageAdd {
            //Save to Filemanager
            let keyWithName = "\(String(data.id))"
            
            let dateString = keys.first?.key.toString()
            let path = "\(keyWithName)/\(dateString)"
            DispatchQueue.main.async {
                guard let imageRepresentation = UIImagePNGRepresentation(image.rotateImage()) else {
                    print("Unable to represent image as PNG")
                    return
                }
                let fileToWrite = AppFile(fileName: "image\(String(describing: keys.first?.value)).png")
                if !fileToWrite.writeToCustomer(data: imageRepresentation, path: "\(path)") {
                    print("Add Error")
                }
            }
            
        } else if kind == .imageRemove {
            let keyWithName = "\(String(data.id))"
            let dateString = keys.first?.key.toString()
            let path = "\(keyWithName)/\(dateString)"
            DispatchQueue.main.async {
                let fileToWrite = AppFile(fileName: "image\(String(describing: keys.first?.value)).png")
                if !fileToWrite.deleteCustomerImage(at: path) {
                    print("Delete Error")
                }
            }
        } else if kind == .text {
            // Save To CoreData
            //let queue = DispatchQueue(label: "com.wu.customerManager")
            if !new {
                customerFetch.predicate = nil
                let updateID = data.id
                customerFetch.predicate = NSPredicate(format: "id = \(updateID)")
                print("update id \(data.id)")
                do {
                    let context = persistentContainer.viewContext
                    let results = try context.fetch(customerFetch) as! [Customer]
                    if results.count > 0 {
                        //queue.async {
                        DispatchQueue.main.async {
                            self.setCustomerValue(NSobject: results[0], saveData: data)
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
                //queue.async {
                DispatchQueue.main.async {
                    self.setCustomerValue(NSobject: object,saveData: data)
                    self.saveContext()
                }
            }
        }
    
    }
    
    func setCustomerValue(NSobject: NSManagedObject, saveData data:CustomerData){
        print("new id \(data.id)")
        NSobject.setValue(data.name, forKey: CustomerAttribute.name.rawValue)
        NSobject.setValue(data.id, forKey: CustomerAttribute.id.rawValue)
        //NSobject.setValue(data.datePath, forKey: CustomerAttribute.datePath.rawValue)
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
