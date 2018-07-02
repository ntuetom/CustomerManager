//
//  Array+Data_Extention.swift
//  CustomerManager
//
//  Created by Wu hung-yi on 2018/6/26.
//  Copyright © 2018 Wu. All rights reserved.
//
import UIKit

typealias ImageArray = [UIImage]
typealias ImageArrayRepresentation = Data

extension Array where Element: UIImage {
    // Given an array of UIImages return a Data representation of the array suitable for storing in core data as binary data that allows external storage
    func coreDataRepresentation() -> ImageArrayRepresentation? {
        let CDataArray = NSMutableArray()
        
        for img in self {
            
            guard let imageRepresentation = UIImagePNGRepresentation(img.rotateImage()) else {
                print("Unable to represent image as PNG")
                return nil
            }
            CDataArray.add(imageRepresentation)
        }
        
        return NSKeyedArchiver.archivedData(withRootObject: CDataArray)
    }
}

extension ImageArrayRepresentation {
    // Given a Data representation of an array of UIImages return the array
    func imageArray() -> ImageArray? {
        if let mySavedData = NSKeyedUnarchiver.unarchiveObject(with: self) as? NSArray {
            // TODO: Use regular map and return nil if something can't be turned into a UIImage
            let imgArray = mySavedData.flatMap({
                return UIImage(data: $0 as! Data)
            })
            return imgArray
        }
        else {
            print("Unable to convert data to ImageArray")
            return nil
        }
    }
}

extension UIImage {
    func rotateImage() -> UIImage {
        
        if (imageOrientation == UIImageOrientation.up ) {
            return self
        }
        
        UIGraphicsBeginImageContext(size)
        
        draw(in: CGRect(origin: CGPoint.zero, size: size))
        let copy = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return copy!
    }
}
