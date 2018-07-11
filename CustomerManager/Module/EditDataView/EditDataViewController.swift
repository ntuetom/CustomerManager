//
//  EditDataViewController.swift
//  CustomerManager
//
//  Created by Wu hung-yi on 20/03/2018.
//  Copyright © 2018 Wu. All rights reserved.
//

import UIKit

//enum CorrectType {
//    case add
//    case edit
//}

class EditDataViewController: UIViewController, MyCollectionViewDelegate{
    
    @IBOutlet weak var InfoTextView: UIView!
    @IBOutlet weak var namefield: UITextField!
    @IBOutlet weak var telfield: UITextField!
    @IBOutlet weak var labelDate: UILabel!
    
    var barButton: UIBarButtonItem!
    var fullScreenSize: CGSize!
    var collectionView:UICollectionView!
    weak var delegate: EditDataDelegate!
    var viewModel: EditDataViewModel!
    var id: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("EditDataViewController")
    
        hideKeyboardWhenTappedAround()
        fullScreenSize = UIScreen.main.bounds.size
        setUpCollectionLayout()
        
        let title = "Done"

        barButton = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(onBarButtonClick))
        self.navigationItem.setRightBarButton(barButton, animated: true)
        initViewModel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initViewModel() {
        viewModel.dataUpdateClosure = { [weak self] () in
            self?.navigationController?.popViewController(animated: true)
        }
        viewModel.reloadCollectionViewClosure = { [weak self] () in
            self?.namefield.text = self?.viewModel.customerData.name
            self?.telfield.text = self?.viewModel.customerData.tel
            self?.collectionView.reloadData()
        }
        viewModel.errorClosure = { [weak self] () in
            if let message = self?.viewModel.alertMessage {
                self?.showAlert(message)
            }
        }
    }
    
    @objc func onBarButtonClick(){
        //savePhotoToLibrary()
        viewModel.updateData(tel: telfield.text!, name: namefield.text!)
        
    }
    
    func takeFromCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func takeFromLibrary(){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func savePhotoToLibrary(){
        guard viewModel.numberOfImages > 0 else {
            return;
        }

        for image in viewModel.getImages() {
            let imageData = UIImageJPEGRepresentation(image.image!, 0.6)
            let compressedJPGImage = UIImage(data: imageData!)
            UIImageWriteToSavedPhotosAlbum(compressedJPGImage!, nil, nil, nil)
        }

        let alert = UIAlertController(title: "Woo", message: "All your image has been saved to Photo Library!", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
    }
    
    func setUpCollectionLayout(){
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5)
        layout.minimumLineSpacing = 5
        
        let itemSize = fullScreenSize.width
        
        layout.itemSize = CGSize(width: itemSize/3 - 10.0, height: itemSize/3 - 10.0)
        layout.headerReferenceSize = CGSize(width: itemSize, height: 30)
        layout.footerReferenceSize = CGSize(width: itemSize, height: 30)
        
        collectionView = UICollectionView(frame: CGRect(x: 0,y: 0,width: fullScreenSize.width,height: fullScreenSize.height), collectionViewLayout: layout)
        self.view.addSubview(collectionView)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        let const:[NSLayoutConstraint] = [
            collectionView.topAnchor.constraint(equalTo: InfoTextView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ]
        NSLayoutConstraint.activate(const)
        collectionView.register(MyCollectionViewCell.self, forCellWithReuseIdentifier: "CollectionCell")
        collectionView.register(UICollectionReusableView.self,forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "CollectionHeader")
        collectionView.register(UICollectionReusableView.self,forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "CollectionFooter")
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func deleteButtonClick(AtIndexPath indexPath: IndexPath) {
        print("delet \(indexPath.item)")
        let alert = UIAlertController(title: "Delete Photo", message: "Are you sure you want to delete the picture?", preferredStyle: .alert)
        let confirmAtion = UIAlertAction(title: "Confirm", style: .destructive){
            UIAlertAction in
            self.viewModel.removeImages(at: indexPath)
            self.collectionView.reloadData()
        }
        alert.addAction(confirmAtion)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "警告", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension EditDataViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfImages + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath)as! MyCollectionViewCell
        
        // 設置 cell 內容 (即自定義元件裡 增加的圖片與文字元件)
            
        
        cell.delegate = self
        
        if indexPath.item == 0 {
            cell.imageView.image = UIImage(named: "add-icon")
            cell.titleLabel.text = ""
            cell.deleteButton.isHidden = true
            cell.imageView.isUserInteractionEnabled = false
        } else{
            DispatchQueue.main.async {
                cell.imageView.image = self.viewModel.getImage(at: (indexPath.item - 1)).image

            }
            cell.titleLabel.text = "0\(indexPath.item)"
            cell.deleteButton.isHidden = false
            cell.imageView.isUserInteractionEnabled = true
            cell.myViewController = self
        }
        print("\(indexPath.row) \(indexPath.section) \(cell.deleteButton.isHidden)")
        return cell
            
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        print("你選擇了第 \(indexPath.section + 1) 組的")
        viewModel.currentAddSection = indexPath.section
        print("第 \(indexPath.item + 1) 張圖片")
        if indexPath.item == 0 {
            let alert = UIAlertController(title: "Take Photo", message: "Let's take a Photo from your Library or Camera!", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { acion in self.takeFromCamera()}))
            alert.addAction(UIAlertAction(title: "Library", style: .default, handler:{ action in self.takeFromLibrary()}))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil ))
            self.present(alert, animated: true, completion: nil)
        }else {
            //imageFullScreen(TappedImage: saveImage[indexPath.item - 1].image!)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var reusableView = UICollectionReusableView()
        let label = UILabel(frame: CGRect(x: 0, y: 0,width: fullScreenSize.width, height: 30))
        label.textAlignment = .center
        
        if kind == UICollectionElementKindSectionFooter {
            reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter,withReuseIdentifier: "CollectionFooter",for: indexPath)
            reusableView.backgroundColor = UIColor.black
            label.text = "Footer";
            label.textColor = UIColor.white
        }else if kind == UICollectionElementKindSectionHeader {
            reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "CollectionHeader", for: indexPath)
            reusableView.backgroundColor = UIColor.darkGray
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd"
            let dateString = dateFormatter.string(from: Date())
            label.text = dateString
            label.textColor = UIColor.white
        }
        reusableView.addSubview(label)
        return reusableView
    }
}

extension EditDataViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        viewModel.addImages(newImage: image)
        collectionView.reloadData()
        dismiss(animated:true, completion: nil)
    }
}
