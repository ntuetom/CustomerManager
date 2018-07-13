//
//  TableViewModel.swift
//  CustomerManager
//
//  Created by Wu hung-yi on 2018/6/27.
//  Copyright © 2018 Wu. All rights reserved.
//

import Foundation
import UIKit

class TableViewModel {
    
    var dataController: DataController
    //var customerDatas:[CustomerData]!
    
    init() {
        dataController = DataController()
    }
    
    var isLoading: Bool = false {
        didSet {
            self.updateLoadingStatus?()
        }
    }
    
    var numberOfShowCells: Int {
        return showCellViewModels.count
    }
    
    private var numberOfOriginCells: Int {
        return originCellViewModels.count
    }
    
    private var showCellViewModels: [CustomerCellViewModel] = [CustomerCellViewModel]() {
        didSet {
            self.reloadTableViewClosure?()
        }
    }
    
    private var originCellViewModels: [CustomerCellViewModel] = [CustomerCellViewModel]()
    
    var alertMessage: String? {
        didSet {
            self.showAlertClosure?()
        }
    }
    
    var reloadTableViewClosure: (()->())?
    var updateLoadingStatus: (()->())?
    var showAlertClosure: (()->())?
    
    func initFetch() {
        self.isLoading = true
        dataController.fetchCustomerData { [weak self] (success, datas, error) in
            self?.isLoading = false
            if let error = error {
                self?.alertMessage = error
            } else if let datas = datas{
                self?.processFetchData(datas: datas)
            } else {
                self?.alertMessage = "Data incorrect!"
            }
        }
    }
    
    func getEditDataViewModel(at index: IndexPath?, delegate: EditDataDelegate) -> EditDataViewModel {
        var dataCount = 0
        if numberOfOriginCells > 0 {
            dataCount = numberOfOriginCells
        }
        var editVM: EditDataViewModel
        if let indexPath = index {
            editVM = EditDataViewModel(dataId: originCellViewModels[indexPath.row].id, toDelegate: delegate)
        } else {
            editVM = EditDataViewModel(dataId: dataCount, toDelegate: delegate)
        }
        return editVM
    }
    
    func getCellViewModel(at indexPath: IndexPath) -> CustomerCellViewModel {
        return showCellViewModels[indexPath.row]
    }
    
    func getCellViewModels() -> [CustomerCellViewModel] {
        return showCellViewModels
    }
    
    func processFetchData( datas: [CustomerData] ){
        //self.customerDatas = datas
        var vms = [CustomerCellViewModel]()
        for data in datas {
            let cellViewModel = CustomerCellViewModel(id: data.id,nameText: data.name, telText: data.tel)
            vms.append(cellViewModel)
        }
        self.originCellViewModels = vms
        self.showCellViewModels = vms
    }
    
    func filterSearchData(input text: String) {
        var filterList = [CustomerCellViewModel]()
        if text != ""{
            for content in originCellViewModels{
                if (content.telText.contains(text)) || (content.nameText.contains(text)){
                    filterList.append(content)
                }
            }
            showCellViewModels = filterList
        }else{
            showCellViewModels = originCellViewModels
        }
    }
    
    func updateData(newData: CustomerData, at key: Date?, image: UIImage? = nil, kind: DataChangeType) {
        if numberOfOriginCells <= 0 {
            originCellViewModels.append(CustomerCellViewModel(id: newData.id, nameText: newData.name, telText: newData.tel))
            dataController.updateCustomer(saveData: newData, atImageKey: key, image: image, kind: kind)
        }else {
            var count = 0
            for vm in originCellViewModels {
                //new data
                if newData.id > numberOfOriginCells - 1 {
                    dataController.updateCustomer(saveData: newData, atImageKey: key, image: image, kind: kind)
                    originCellViewModels.append(CustomerCellViewModel(id: newData.id, nameText: newData.name, telText: newData.tel))
                    break
                }
                // override old data
                if newData.id == vm.id {
                    dataController.updateCustomer(saveData: newData,atImageKey: key, image: image, kind: kind, isNew : false)
                    originCellViewModels[count].nameText = newData.name
                    originCellViewModels[count].telText = newData.tel
                    break
                }
                count += 1
            }
        }
        showCellViewModels = originCellViewModels
    }
}

struct CustomerCellViewModel {
    let id: Int
    var nameText: String
    var telText: String
}
