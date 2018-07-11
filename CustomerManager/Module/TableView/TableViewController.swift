//
//  ViewController.swift
//  CustomerManager
//
//  Created by Wu hung-yi on 18/03/2018.
//  Copyright © 2018 Wu. All rights reserved.
//

import UIKit

class TableViewController: UIViewController, EditDataDelegate {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var backgroundView:UIView?
    var searchBar: UISearchBar!
    var tableView: UITableView!
    var newDataBarbutton: UIBarButtonItem?
    
    var datas:[CustomerData]!
    var dataController:DataController!
    
    lazy var viewModel: TableViewModel = {
        return TableViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("TableViewController")
        setupUI()
        initViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("TableViewController viewWillAppear")
        newDataBarbutton?.isEnabled = false
        newDataBarbutton?.isEnabled = true
        
        self.tableView.reloadData()
        
    }
    
    func initViewModel() {
        viewModel.showAlertClosure = { [weak self] () in
            DispatchQueue.main.async {
                if let message = self?.viewModel.alertMessage {
                    self?.showAlert(message)
                }
            }
        }
        
        viewModel.reloadTableViewClosure = { [weak self] () in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        viewModel.updateLoadingStatus = { [weak self] () in
            DispatchQueue.main.async {
                let isLoading = self?.viewModel.isLoading ?? false
                if isLoading {
                    self?.activityIndicator.startAnimating()
                    UIView.animate(withDuration: 0.2, animations: {
                        self?.tableView.alpha = 0.0
                    })
                } else {
                    self?.activityIndicator.stopAnimating()
                    UIView.animate(withDuration: 0.2, animations: {
                        self?.tableView.alpha = 1.0
                    })
                }
            }
        }
        viewModel.initFetch()
    }
    
    func onDataChange(newData: CustomerData, at key: [Date: Int]? , image: UIImage?, kind: DataChangeType) {
        viewModel.updateData(newData: newData, at: key, image: image,kind: kind)
    }
    
    @objc func onTap(recognizer:UITapGestureRecognizer){
        self.searchBar.endEditing(true)
        backgroundView?.removeFromSuperview()
    }
    
    @objc func onAddNewData(){
        let editVM = viewModel.getEditDataViewModel(at: nil, delegate: self)
        if let addDataViewController = self.storyboard?.instantiateViewController(withIdentifier:
            "EditDataViewController") as? EditDataViewController {
            addDataViewController.viewModel = editVM
            self.navigationController?.pushViewController(addDataViewController, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func sizetoFitTableView(table:UITableView){
        var frame = table.frame
        frame.size.height = table.contentSize.height
        table.frame = frame
        table.reloadData()
    }
    
    func setupUI(){
        newDataBarbutton = UIBarButtonItem(title: "New", style: .plain, target: self, action: #selector(onAddNewData))
        print((navigationController?.navigationBar.frame.height)!)
        //searchBar = UISearchBar(frame: CGRect(x: 0, y: (navigationController?.navigationBar.frame.height)!, width: self.view.frame.size.width,height:96))
        searchBar = UISearchBar()
        tableView = UITableView()
        //tableView = UITableView(frame: CGRect(x: 0, y: 120, width: self.view.frame.size.width, height: self.view.frame.size.height - searchBar.frame.height), style: .plain)
        self.view.addSubview(self.searchBar!)
        self.view.addSubview(self.tableView!)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        let searchBarconst:[NSLayoutConstraint] = [
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 50),
            searchBar.bottomAnchor.constraint(equalTo: tableView.topAnchor)
        ]
        NSLayoutConstraint.activate(searchBarconst)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        let tableViewconst:[NSLayoutConstraint] = [
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        NSLayoutConstraint.activate(tableViewconst)
        
        backgroundView = UIView(frame: CGRect(x:self.view.frame.minX,y: 120,width:self.view.frame.width,height:self.view.frame.height))
        backgroundView?.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.67)
        
        self.searchBar.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap(recognizer:)))
        backgroundView!.addGestureRecognizer(tapGesture)
        
        let nib = UINib.init(nibName: "CustomerCell",bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "CustomerCell")
        self.tableView?.backgroundColor = UIColor.white
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        
        self.navigationItem.setRightBarButton(newDataBarbutton, animated: true)
    }

    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "警告", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension TableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfShowCells
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CustomerCell",for: indexPath) as? CustomerCell else {
                fatalError("Cell not exists in storyboard")
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none // 選取的時侯無背景色
            cell.labelName?.font = UIFont.systemFont(ofSize: 30)
            cell.labelTel?.font = UIFont.systemFont(ofSize: 30)
            
            let cellVM = viewModel.getCellViewModel(at: indexPath)
            cell.labelTel?.text = cellVM.telText
            cell.labelName?.text = cellVM.nameText
            return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let editVM = viewModel.getEditDataViewModel(at: indexPath, delegate: self)
    
        if let editViewController = self.storyboard?.instantiateViewController(withIdentifier: "EditDataViewController") as? EditDataViewController{
            editViewController.viewModel = editVM
            self.navigationController?.pushViewController(editViewController, animated: true)

        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

extension TableViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("searchBarTextDidBeginEditing")
        let backgroundViewconst:[NSLayoutConstraint] = [
            backgroundView!.topAnchor.constraint(equalTo: searchBar.safeAreaLayoutGuide.bottomAnchor),
            backgroundView!.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            backgroundView!.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            backgroundView!.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ]
        self.view.addSubview(backgroundView!)
        NSLayoutConstraint.activate(backgroundViewconst)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("textDidChange" + searchText)
        viewModel.filterSearchData(input: searchText)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("searchBarTextDidEndEditing")
        viewModel.filterSearchData(input: searchBar.text!)
    }
}

