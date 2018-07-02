//
//  MyCollectionViewCell.swift
//  CustomerManager
//
//  Created by Wu hung-yi on 21/03/2018.
//  Copyright © 2018 Wu. All rights reserved.
//

import UIKit

protocol MyCollectionViewDelegate: AnyObject {
    func deleteButtonClick(AtIndexPath indexPath:IndexPath)
}

class MyCollectionViewCell: UICollectionViewCell,UIGestureRecognizerDelegate {
 
    var imageView: UIImageView!
    var titleLabel: UILabel!
    var deleteButton: UIButton!
    weak var delegate: MyCollectionViewDelegate!
    var isZoom = false
    var originImageCenter:CGPoint?
    var currentImage:UIImageView!
    weak var myViewController: UIViewController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = false
        //self.selectionStyle = .none
        setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("MyCollectionViewCell deinit")
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func onDeleteButtonClick(){
        let indexPath:IndexPath = (self.superview as! UICollectionView).indexPath(for: self)!
        delegate.deleteButtonClick(AtIndexPath: indexPath)
    }
    
    func setUpView(){
        let w = UIScreen.main.bounds.size.width/3 - 10.0
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: w, height: w))
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageFullScreen(_:)))
        imageView.addGestureRecognizer(tap)
        self.addSubview(imageView)
    
        deleteButton = UIButton(frame: CGRect(x: 0, y: 0, width: w/5, height: w/5))
        deleteButton.backgroundColor = UIColor.red
        deleteButton.setTitle("X", for: .normal)
        deleteButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        deleteButton.setTitleColor(UIColor.white, for: .normal)
        
        deleteButton.addTarget(self, action: #selector(onDeleteButtonClick), for: UIControlEvents.touchDown)
        deleteButton.layer.cornerRadius = 0.5 * deleteButton.bounds.size.width
        self.addSubview(deleteButton)
        
        titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: w, height: 40))
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.orange
        self.addSubview(titleLabel)
        
    }
    
    @objc func imageFullScreen(_ sender: UITapGestureRecognizer){
        print("imageFullScreen")
        currentImage = UIImageView(frame: UIScreen.main.bounds)
        currentImage.backgroundColor = .black
        currentImage.contentMode = .scaleAspectFit
        currentImage.clipsToBounds = true
        currentImage.image = imageView.image
        currentImage.isUserInteractionEnabled = true
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        swipe.direction = .down
        swipe.delegate = self
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(scaleTheImage(_:)))
        pinch.delegate = self
        let pan = UIPanGestureRecognizer(target: self, action: #selector(movetheImage(_:)))
        pan.delegate = self
        currentImage.addGestureRecognizer(pinch)
        currentImage.addGestureRecognizer(pan)
        currentImage.addGestureRecognizer(swipe)
        self.superview?.superview?.addSubview(currentImage)
        //viewcon
        myViewController?.navigationController?.isNavigationBarHidden = true
        myViewController?.tabBarController?.tabBar.isHidden = true
    }
    
    @objc func dismissFullscreenImage(_ sender: UISwipeGestureRecognizer) {
        print("dismissFullscreenImage")
        if sender.direction == .down {
            print("down")
            myViewController?.navigationController?.isNavigationBarHidden = false
            myViewController?.tabBarController?.tabBar.isHidden = false
            sender.view?.removeFromSuperview()
        }
    }
    
    @objc func scaleTheImage(_ sender: UIPinchGestureRecognizer){
        if sender.state == .began {
            let currentScale = self.currentImage.frame.size.width / self.currentImage.bounds.size.width
            let newScale = currentScale*sender.scale
            if newScale > 1{
                isZoom = true
            }
        }else if sender.state == .changed {
            guard let view = sender.view else { return }
            let pinchCenter = CGPoint(x: sender.location(in: view).x - view.bounds.midX,
                                      y: sender.location(in: view).y - view.bounds.midY)
            let transform = view.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                .scaledBy(x: sender.scale, y: sender.scale)
                .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
            let currentScale = self.currentImage.frame.size.width / self.currentImage.bounds.size.width
            var newScale = currentScale*sender.scale
            
            if newScale < 1{
                newScale = 1
                let transform = CGAffineTransform(scaleX: newScale, y: newScale)
                self.currentImage.transform = transform
                sender.scale = 1
            }else {
                view.transform = transform
                sender.scale = 1
            }
            
        }else if sender.state == .ended || sender.state == .failed || sender.state == .cancelled {
            //self.originImageCenter = sender.view?.center
            guard let center = self.originImageCenter else {
                print("send orignal is nil")
                return
            }
            UIView.animate(withDuration: 0.3, animations: {
                self.currentImage.transform = CGAffineTransform.identity
                self.currentImage.center = center
            },completion:{ _ in
                self.isZoom = false
            })
        }
    }
    
    @objc func movetheImage(_ sender: UIPanGestureRecognizer){
        if isZoom && sender.state == .began {
            print("set originImageCenter")
            self.originImageCenter = sender.view?.center
        } else if self.isZoom && sender.state == .changed {
            let translation = sender.translation(in: self)
            if let view = sender.view {
                view.center = CGPoint(x:view.center.x + translation.x,
                                      y:view.center.y + translation.y)
            }
            sender.setTranslation(CGPoint.zero, in: superview)
        }
    }
    
}
