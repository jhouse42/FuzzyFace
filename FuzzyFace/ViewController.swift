//
//  ViewController.swift
//  FuzzyFace
//
//  Created by Jeanie House on 12/1/15.
//  Copyright © 2015 Jeanie House. All rights reserved.
//

import UIKit
import CoreImage

class ViewController: UIViewController {
    @IBOutlet weak var selectorView: UIView!
    
    private weak var selectorVC: ImageSelectorViewController?
    @IBAction func toggleImageSelectorAction() {
        if selectorVC == .None {
            let selectorVC = ImageSelectorViewController()
            
            addChildViewController(selectorVC)
            
            selectorView.addSubview(selectorVC.view)
            selectorVC.view.frame = selectorView.bounds
            
            selectorVC.didMoveToParentViewController(self)
            
            self.selectorVC = selectorVC
        } else {
            let selectorVC = self.selectorVC!
            selectorVC.willMoveToParentViewController(nil)
            selectorVC.view.removeFromSuperview()
            selectorVC.removeFromParentViewController()
            
            self.selectorVC = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.toggleImageSelectorAction()
    }
    
    @IBAction func processImage() {
        let maybeImage = selectorVC?.selectedImage
        if (maybeImage == nil) {
            return
        }
        let image = maybeImage!
        
        let inputImage = ((image.CGImage != nil)
            ? CIImage(CGImage: image.CGImage!)
            : image.CIImage!)
        let context = CIContext(options:nil)
        let faces = faceFeaturesInImage(inputImage, context: context)
        print("found faces: \(faces)")
        if (faces.isEmpty) {
            print("found no faces :(")
            return
        }
        
        let outputImage = faces.reduce(inputImage) {
            image, face in
            let pixellatedFace = self.pixellatedImage(image,
                ofRect: face.bounds)
            
            let parameters = [
                kCIInputImageKey: pixellatedFace
                , kCIInputBackgroundImageKey: image
            ]
            let overFilter = CIFilter(name: "CISourceOverCompositing",
                withInputParameters: parameters)
            let imageWithBlurredFace = overFilter!.outputImage!
            
            let renderedImage = context.createCGImage(imageWithBlurredFace,
                fromRect: imageWithBlurredFace.extent)
            let nextImage = CIImage(CGImage: renderedImage)
            return nextImage
        }
        
        let processedImage: UIImage? = UIImage(CIImage: outputImage,
            scale: image.scale, orientation: image.imageOrientation)
        selectorVC?.selectedImage = processedImage
    }
    
    func pixellatedImage(image: CIImage, ofRect rect: CGRect) -> CIImage {
        let imageInBounds = image.imageByCroppingToRect(rect)
        let pixellateOptions = [
            kCIInputImageKey: imageInBounds
            , kCIInputScaleKey: 16.0
            , kCIInputCenterKey: CIVector(x: 0, y: 0)
        ]
        let filter = CIFilter(name: "CIPixellate",
            withInputParameters:pixellateOptions)
        let outputImage = filter!.outputImage!
        return outputImage
    }
    
    func faceFeaturesInImage(image: CIImage, context: CIContext)
        -> [CIFaceFeature] {
            let highAccuracy = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
            let faceDetector = CIDetector(ofType: CIDetectorTypeFace,
                context: context, options: highAccuracy)
            let faceFeatures = faceDetector.featuresInImage(image)
                as! [CIFaceFeature]
            return faceFeatures
    }
}
