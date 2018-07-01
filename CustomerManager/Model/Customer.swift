//
//  Customer.swift
//  CustomerManager
//
//  Created by Wu hung-yi on 2018/6/27.
//  Copyright © 2018 Wu. All rights reserved.
//
import UIKit

struct CustomerData {
    
    init(tel t:String,name n:String,lastId myid:Int,currentTime mydate:Date = Date(),photos: [UIImage] = [],isNew new:Bool = true) {
        tel = t
        name = n
        images = photos
        date = mydate
        //if new{
            id = myid + 1
        //}else{
            id = myid
        //}
    }
    
    var id : Int
    var tel:String
    var name:String
    var date:Date
    var images:[UIImage]
    
    mutating func appendImage(newImag img:UIImage){
        images.append(img)
    }
}
