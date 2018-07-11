//
//  FileContainer.swift
//  CustomerManager
//
//  Created by 全勝發網路資訊 on 2018/7/2.
//  Copyright © 2018年 Wu. All rights reserved.
//

import Foundation
import UIKit

enum AppDirectories : String
{
    case Documents = "Documents"
    case Customer = "Customer"
    case Library = "Library"
    case Temp = "tmp"
}

protocol AppDirectoryNames {
    func documentsDirectoryURL() -> URL
    
    func customerDirectoryURL() -> URL
    
    func libraryDirectoryURL() -> URL
    
    func tempDirectoryURL() -> URL
    
    func getURL(for directory: AppDirectories) -> URL
    
    func buildFullPath(forFileName name: String, inDirectory directory: AppDirectories) -> URL
}

extension AppDirectoryNames {
    func documentsDirectoryURL() -> URL
    {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        //return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func libraryDirectoryURL() -> URL
    {
        return FileManager.default.urls(for: FileManager.SearchPathDirectory.libraryDirectory, in: .userDomainMask).first!
    }
    
    func tempDirectoryURL() -> URL
    {
        return FileManager.default.temporaryDirectory
        //urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(AppDirectories.Temp.rawValue) //"tmp")
    }
    
    func customerDirectoryURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(AppDirectories.Customer.rawValue) // "Inbox")
    }
    
    func getURL(for directory: AppDirectories) -> URL
    {
        switch directory
        {
        case .Documents:
            return documentsDirectoryURL()
        case .Customer:
            return customerDirectoryURL()
        case .Library:
            return libraryDirectoryURL()
        case .Temp:
            return tempDirectoryURL()
        }
    }
    
    func buildFullPath(forFileName name: String, inDirectory directory: AppDirectories) -> URL
    {
        return getURL(for: directory).appendingPathComponent(name)
    }
}

protocol AppFileStatusChecking
{
    func isWritable(file at: URL) -> Bool
    
    func isReadable(file at: URL) -> Bool
    
    func exists(file at: URL) -> Bool
}

extension AppFileStatusChecking {
    func isWritable(file at: URL) -> Bool
    {
        if FileManager.default.isWritableFile(atPath: at.path)
        {
            print(at.path)
            return true
        }
        else
        {
            print(at.path)
            return false
        }
    }
    
    func isReadable(file at: URL) -> Bool
    {
        if FileManager.default.isReadableFile(atPath: at.path)
        {
            print(at.path)
            return true
        }
        else
        {
            print(at.path)
            return false
        }
    }
    
    func exists(file at: URL) -> Bool
    {
        if FileManager.default.fileExists(atPath: at.path)
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    func exists(file at: String) -> Bool
    {
        if FileManager.default.fileExists(atPath: at)
        {
            return true
        }
        else
        {
            return false
        }
    }
}

protocol AppFileSystemMetaData
{
    func list(directory at: URL) -> Bool
    
    func attributes(ofFile atFullPath: URL) -> [FileAttributeKey : Any]
}

extension AppFileSystemMetaData
{
    func list(directory at: URL) -> Bool
    {
        let listing = try! FileManager.default.contentsOfDirectory(atPath: at.path)
        
        if listing.count > 0
        {
            print("\n----------------------------")
            print("LISTING: \(at.path)")
            print("")
            for file in listing
            {
                print("File: \(file.debugDescription)")
            }
            print("")
            print("----------------------------\n")
            
            return true
        }
        else
        {
            return false
        }
    }
    
    func attributes(ofFile atFullPath: URL) -> [FileAttributeKey : Any]
    {
        return try! FileManager.default.attributesOfItem(atPath: atFullPath.path)
    }
}


protocol AppFileManipulation : AppDirectoryNames
{
    func writeFile(containing: String, to path: AppDirectories, withName name: String) -> Bool
    
    func writeFile(containing: Data, to path: String, withName name: String) -> Bool
    
    func readFile(at path: AppDirectories, withName name: String) -> String
    
    func readFile(at path: String) -> UIImage?
    
    func deleteFile(at path: AppDirectories, withName name: String) -> Bool
    
    func deleteFile(at path: String) -> Bool
    
    func renameFile(at path: AppDirectories, with oldName: String, to newName: String) -> Bool
    
    func moveFile(withName name: String, inDirectory: AppDirectories, toDirectory directory: AppDirectories) -> Bool
    
    func copyFile(withName name: String, inDirectory: AppDirectories, toDirectory directory: AppDirectories) -> Bool
    
    func changeFileExtension(withName name: String, inDirectory: AppDirectories, toNewExtension newExtension: String) -> Bool
    
    func createFolder(at path: AppDirectories, withName name: String) -> Bool
}

extension AppFileManipulation
{
    func writeFile(containing: String, to path: AppDirectories, withName name: String) -> Bool
    {
        let filePath = getURL(for: path).path + "/" + name
        let rawData: Data? = containing.data(using: .utf8)
        return FileManager.default.createFile(atPath: filePath, contents: rawData, attributes: nil)
    }
    
    func writeFile(containing: Data, to path: String, withName name: String) -> Bool {
        let filePath = path + "/" + name
        return FileManager.default.createFile(atPath: filePath, contents: containing, attributes: nil)
    }
    
    func readFile(at path: AppDirectories, withName name: String) -> String
    {
        let filePath = getURL(for: path).path + "/" + name
        let fileContents = FileManager.default.contents(atPath: filePath)
        let fileContentsAsString = String(bytes: fileContents!, encoding: .utf8)
        print(fileContentsAsString!)
        return fileContentsAsString!
    }
    
    func readFile(at path: String) -> UIImage? {
        guard let image = UIImage(contentsOfFile: path) else {
            return nil
        }
        return image
    }
    
    func deleteFile(at path: AppDirectories, withName name: String) -> Bool
    {
        let filePath = buildFullPath(forFileName: name, inDirectory: path)
        try! FileManager.default.removeItem(at: filePath)
        return true
    }
    
    func deleteFile(at path: String) -> Bool {
        try! FileManager.default.removeItem(atPath: path)
        return true
    }
    
    func renameFile(at path: AppDirectories, with oldName: String, to newName: String) -> Bool
    {
        let oldPath = getURL(for: path).appendingPathComponent(oldName)
        let newPath = getURL(for: path).appendingPathComponent(newName)
        try! FileManager.default.moveItem(at: oldPath, to: newPath)
        
        // highlights the limitations of using return values
        return true
    }
    
    func moveFile(withName name: String, inDirectory: AppDirectories, toDirectory directory: AppDirectories) -> Bool
    {
        let originURL = buildFullPath(forFileName: name, inDirectory: inDirectory)
        let destinationURL = buildFullPath(forFileName: name, inDirectory: directory)
        // warning: constant 'success' inferred to have type '()', which may be unexpected
        // let success =
        try! FileManager.default.moveItem(at: originURL, to: destinationURL)
        return true
    }
    
    func copyFile(withName name: String, inDirectory: AppDirectories, toDirectory directory: AppDirectories) -> Bool
    {
        let originURL = buildFullPath(forFileName: name, inDirectory: inDirectory)
        let destinationURL = buildFullPath(forFileName: name+"1", inDirectory: directory)
        try! FileManager.default.copyItem(at: originURL, to: destinationURL)
        return true
    }
    
    func changeFileExtension(withName name: String, inDirectory: AppDirectories, toNewExtension newExtension: String) -> Bool
    {
        var newFileName = NSString(string:name)
        newFileName = newFileName.deletingPathExtension as NSString
        newFileName = (newFileName.appendingPathExtension(newExtension) as NSString?)!
        let finalFileName:String =  String(newFileName)
        
        let originURL = buildFullPath(forFileName: name, inDirectory: inDirectory)
        let destinationURL = buildFullPath(forFileName: finalFileName, inDirectory: inDirectory)
        
        try! FileManager.default.moveItem(at: originURL, to: destinationURL)
        
        return true
    }
    
    func createFolder(at path: AppDirectories, withName name: String = "") -> Bool {
        var appendPath = ""
        if name != "" {
            appendPath = getURL(for: path).path + "/" + name
        } else {
            appendPath = getURL(for: path).path
        }
        do {
            try FileManager.default.createDirectory(atPath: appendPath, withIntermediateDirectories: true, attributes: nil)
            return true
        } catch let error as NSError {
            print("create folder error \(error)")
            return false
        }
    }
} // end extension AppFileManipulation


class AppFile: AppDirectoryNames, AppFileStatusChecking, AppFileManipulation, AppFileSystemMetaData {
    
    let fileName: String
    
    init(fileName: String)
    {
        self.fileName = fileName
    }
    
    func moveToDocuments()
    {
        if exists(file: getURL(for: .Customer)) {
            _ = moveFile(withName: fileName, inDirectory: .Customer, toDirectory: .Documents)
        } else {
            print("Create Customer Folder")
            
        }
    }
    
    func writeToCustomer(data: Data,path: String) -> Bool {
        let currentPath = getURL(for: .Customer).path + "/\(path)"
        if exists(file: currentPath) {
            return writeFile(containing: data, to: currentPath, withName: fileName)
        } else {
            createFolder(at: .Customer,withName: path)
            return writeFile(containing: data, to: currentPath, withName: fileName)
        }
    }
    
    func readCustomer(at path: String) -> UIImage? {
        let currentPath = getURL(for: .Customer).path + "/\(path)/\(fileName)"
        if exists(file: currentPath) {
            return readFile(at: currentPath)
        } else {
            return nil
        }
    }

    func deleteCustomerImage(at path: String) -> Bool {
        let currentPath = getURL(for: .Customer).path + "/\(path)/\(fileName)"
        return deleteFile(at: currentPath)
    }
    
    func getNumberOfFiles(at path: String) -> Int {
        let fileManager = FileManager.default
        let currentPath = getURL(for: .Customer).path + "/\(path)"
        let dirContents = try? fileManager.contentsOfDirectory(atPath: currentPath)
        return dirContents?.count ?? 0
    }
}
