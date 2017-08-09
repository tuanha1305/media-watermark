//
//  ViewController.swift
//  MediaWatermark
//
//  Created by Sergei on 03/05/2017.
//  Copyright © 2017 rubygarage. All rights reserved.
//

import UIKit
import MobileCoreServices
import Player
import MBProgressHUD
import MediaWatermark

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var resultImageView: UIImageView!
    
    var imagePickerController: UIImagePickerController! = nil
    var videoPlayer = Player()
    
    // MARK: - view controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    // MARK: - setup
    func setup() {
        imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
    }
    
    // MARK: - actions
    @IBAction func openMediaButtonDidTap(_ sender: Any) {
        present(imagePickerController, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        picker.dismiss(animated: true, completion: nil)
        
        if (mediaType == kUTTypeVideo as String) || (mediaType == kUTTypeMovie as String) {
            let videoUrl = info[UIImagePickerControllerMediaURL] as! URL
            processVideo(url: videoUrl)
        } else {
            let image = info[UIImagePickerControllerOriginalImage] as? UIImage
            processImage(image: image!)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - processing
    func processImage(image: UIImage) {
        resultImageView.image = nil
        resultImageView.subviews.forEach({$0.removeFromSuperview()})
        
        let item = MediaItem(image: image)
        
        let logoImage = UIImage(named: "logo")
        
        let firstElement = MediaElement(image: logoImage!)
        firstElement.frame = CGRect(x: 0, y: 0, width: logoImage!.size.width, height: logoImage!.size.height)
        
        let secondElement = MediaElement(image: logoImage!)
        secondElement.frame = CGRect(x: 100, y: 100, width: logoImage!.size.width, height: logoImage!.size.height)
        
        item.add(elements: [firstElement, secondElement])
        
        let mediaProcessor = MediaProcessor()
        mediaProcessor.processElements(item: item) { [weak self] (result, error) in
            self?.resultImageView.image = result.image
        }
    }
    
    func processVideo(url: URL) {
        resultImageView.image = nil
        resultImageView.subviews.forEach({$0.removeFromSuperview()})
        
        videoPlayer.view.frame = resultImageView.bounds
        resultImageView.addSubview(videoPlayer.view)
        
        if let item = MediaItem(url: url) {
            let logoImage = UIImage(named: "logo")
            
            let firstElement = MediaElement(image: logoImage!)
            firstElement.frame = CGRect(x: 0, y: 0, width: logoImage!.size.width, height: logoImage!.size.height)
            
            let secondElement = MediaElement(image: logoImage!)
            secondElement.frame = CGRect(x: 150, y: 150, width: logoImage!.size.width, height: logoImage!.size.height)
            
            MBProgressHUD.showAdded(to: view, animated: true)
            
            item.add(elements: [firstElement, secondElement])
            
            let mediaProcessor = MediaProcessor()
            mediaProcessor.processElements(item: item) { [weak self] (result, error) in
                DispatchQueue.main.async {
                    MBProgressHUD.hide(for: (self?.view)!, animated: true)
                }
                
                self?.videoPlayer.url = result.processedUrl
                self?.videoPlayer.playFromBeginning()
            }
        }
    }
}

