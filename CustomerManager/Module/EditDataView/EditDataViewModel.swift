//
//  EditDataViewModel.swift
//  CustomerManager
//
//  Created by Wu hung-yi on 2018/6/27.
//  Copyright © 2018 Wu. All rights reserved.
//

import Foundation
import UIKit

protocol EditDataDelegate: AnyObject {
    func onDataChange(newData data: CustomerData)
}

class EditDataViewModel {
    
    let dataController: DataController
    var customerData: CustomerData!
    
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
                guard let images = data?.images else {
                    print("imgaes are nil")
                    return
                }
                for image in images {
                    self?.saveImages.append(UIImageView(image: image))
                }
                
            } else {
                self?.customerData = CustomerData(tel: "", name: "", lastId: id)
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
                let file = AppFile(fileName: "image\(count).png")
                guard let imageRepresentation = UIImagePNGRepresentation(image.rotateImage()) else {
                    print("Unable to represent image as PNG")
                    return
                }
                if !file.write(data: imageRepresentation) {
                    print("Path Error")
                }
            }
        }
        passData = CustomerData(tel: tel, name: name, lastId: customerData.id, currentTime: customerData.date, photos: photos, isNew:false)
        delegate?.onDataChange(newData: passData)
        dataUpdateClosure?()
    }
    
    func updateImages(newImage image: UIImage) {
        saveImages.append(UIImageView(image: image))
    }
    
    func removeImages(at index: Int) {
        saveImages.remove(at: index)
    }
    
    func getImage(at index: Int) -> UIImageView {
        return saveImages[index]
    }
    
    func getImages() -> [UIImageView] {
        return saveImages
    }
}
