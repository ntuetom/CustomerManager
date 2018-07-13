//
//  EditDataViewModel.swift
//  CustomerManager
//
//  Created by Wu hung-yi on 2018/6/27.
//  Copyright © 2018 Wu. All rights reserved.
//

import Foundation
import UIKit

enum DataChangeType {
    case text, imageAdd, imageRemove
}

protocol EditDataDelegate: AnyObject {
    func onDataChange(newData: CustomerData, at key: Date?, image: UIImage?, kind: DataChangeType)
}

class EditDataViewModel {
    
    let dataController: DataController
    var customerData: CustomerData! {
        didSet {
            reloadCollectionViewClosure?()
        }
    }
    var currentAddSection: Int = 0
    var changedImagesKey: [Date] = []
    
    private var saveImages: [UIImageView] = {
        return [UIImageView]()
    }() {
        didSet {
            reloadCollectionViewClosure?()
        }
    }
    
    var alertMessage: String? {
        didSet {
            self.errorClosure?()
        }
    }
    
    var errorClosure: (()->())?
    var dataUpdateClosure: (()->())?
    var reloadCollectionViewClosure: (()->())?
    weak var delegate: EditDataDelegate?
    
    var numberOfImages: Int {
        return saveImages.count
    }
    
    deinit {
        print("deinit EditDataViewModel")
    }
    
    init (dataId id: Int, toDelegate: EditDataDelegate) {
        dataController = DataController()
        delegate = toDelegate
        DispatchQueue.main.async {
            
        
        self.dataController.fetchDataById(fetchId: id, completion: { [weak self] (data, error) in
            if error == nil {
                self?.customerData = data
                guard let imagedictoinaries = data?.imagesDictionary else {
                    print("imagesDictionary are nil")
                    return
                }
                let firstKey = imagedictoinaries.first?.key
                guard let images = imagedictoinaries.first?.value else{
                    print("first imagedictoinaries are nil")
                    return
                }
                if self?.customerData.datePath.count == 0 {
                    self?.customerData.datePath.append(Date())
                }
                for image in images {
                    //image.key
                    self?.saveImages.append(UIImageView(image: image))
                }
                
            } else {
                self?.customerData = CustomerData(tel: "", name: "", lastId: id)
                self?.customerData.datePath.append(Date())
                self?.errorClosure?()
            }
        })
            
        }
    }
    
    func updateData(tel: String, name: String) {
        guard name != "" else {
            alertMessage = "Please fill the Name info"
            return
        }
        guard tel != "" else {
            alertMessage = "Please fill the Tel info"
            return
        }
        let passData:CustomerData
        
        var photos: [UIImage] = []
        if numberOfImages > 0 {
            var count = 0
            for photo in saveImages {
                count += 1
                guard let image = photo.image else {
                    return
                }
                photos.append(image)
            }
        }
        passData = CustomerData(tel: tel, name: name, lastId: customerData.id, photos: customerData.imagesDictionary, pathes: customerData.datePath, isNew:false)
        delegate?.onDataChange(newData: passData, at: nil, image: nil, kind: .text)
        dataUpdateClosure?()
    }
    
    func addImages(newImage image: UIImage) {
        if !changedImagesKey.contains(customerData.datePath[currentAddSection]) {
            changedImagesKey.append(customerData.datePath[currentAddSection])
        }
        for date in customerData.datePath {
            if customerData.imagesDictionary[date.toString()] == nil {
                customerData.imagesDictionary[date.toString()] = [image]
            } else {
                customerData.imagesDictionary[date.toString()]?.append(image)
            }
        }
        saveImages.append(UIImageView(image: image))
        delegate?.onDataChange(newData: customerData, at: customerData.datePath[currentAddSection], image: image, kind: .imageAdd)
    }
    
    func removeImages(at index: IndexPath) {
        if !changedImagesKey.contains(customerData.datePath[index.section]) {
            changedImagesKey.append(customerData.datePath[index.section])
        }
        customerData.imagesDictionary[customerData.datePath[index.section].toString()]?.remove(at: index.row - 1)
        saveImages.remove(at: index.row - 1)
        delegate?.onDataChange(newData: customerData, at: customerData.datePath[index.section], image: nil, kind: .imageRemove)
    }
    
    func getImage(at index: Int) -> UIImageView {
        return saveImages[index]
    }
    
    func getImages() -> [UIImageView] {
        return saveImages
    }
}
