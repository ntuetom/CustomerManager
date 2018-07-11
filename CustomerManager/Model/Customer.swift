//
//  Customer.swift
//  CustomerManager
//
//  Created by Wu hung-yi on 2018/6/27.
//  Copyright © 2018 Wu. All rights reserved.
//
import UIKit

typealias ImageDictionary = [String: [UIImage]]

struct CustomerData {
    
    init(tel t:String,name n:String,lastId myid:Int, photos: ImageDictionary = ImageDictionary(), pathes: [Date] = [],isNew new:Bool = true) {
        tel = t
        name = n
        imagesDictionary = photos
        datePath = pathes
        id = myid
    }
    
    var id : Int
    var tel:String
    var name:String
    var imagesDictionary: ImageDictionary
    var datePath: [Date]
    
    mutating func appendImage(at keyDate: String, newImag img:UIImage){
        //images.append(img)
        
    }
}
