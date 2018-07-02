//
//  FileContainer.swift
//  CustomerManager
//
//  Created by 全勝發網路資訊 on 2018/7/2.
//  Copyright © 2018年 Wu. All rights reserved.
//

import Foundation

class FileContainer {
    
    let documentsDir = NSHomeDirectory().appending("Documents")
    let fileManager  = FileManager.default
    
    func createFolder() {

        let testDir = documentsDir.appending("test")
        
        do {
            try fileManager.createDirectory(atPath: testDir, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print("error:\(error)")
        }
    }
    
    func createFile() {
        var testDir = documentsDir.appending("test")
        
        var fileDir = testDir.appending("test.txt")
        
        var content = "this is a test"
        do {
            try content.write(to: fileDir, atomically: true)
        } catch let error as NSError {
            print("error:\(error)")
        }
        
    }
    
    func readFile() {
        
    }
    
    func writeFile() {
        
    }
    
    func deleteFile() {
        
    }
}
