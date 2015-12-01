//
//  ImageSelectorViewController.swift
//  FuzzyFace
//
//  Created by Jeanie House on 12/1/15.
//  Copyright © 2015 Jeanie House. All rights reserved.
//

import UIKit

class ImageSelectorViewController:
UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var selectedImage: UIImage? {
        didSet {
            imageView.image = selectedImage
            
            let hasImage = (nil != selectedImage)
            imageView.hidden = !hasImage
            libraryButton.hidden = hasImage
        }
    }
    
    @IBAction func selectFromLibrary() {
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(
        picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [String : AnyObject]) {
            dismissViewControllerAnimated(true, completion: nil)
            selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
    }
    
    
    @IBOutlet weak var libraryButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    lazy var picker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.sourceType = .PhotoLibrary
        picker.delegate = self
        return picker
    }()
}
