//
//  ViewController.swift
//  SceneTextDetection
//
//  Created by Dmytro Pavlenko on 10/4/18.
//  Copyright © 2018 Dmytro Pavlenko. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class ViewController: UIViewController {
    
    private var session: AVCaptureSession = AVCaptureSession()
    internal var requests = [VNRequest]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupVideoPreview()
        self.startTextDetection()
    }
    
    private func setupVideoPreview() {
        self.session.sessionPreset = .photo
        
        guard let captureDevice = self.getCaptureDevice() else {
            fatalError("Error while getting captureDevice")
        }
        
        guard let deviceInput = self.getCaptureDeviceInput(captureDevice) else {
            fatalError("Error while getting deviceInput")
        }
        
        let deviceOutput = self.getCaptureDeviceOutput()
        
        self.session.addInput(deviceInput)
        self.session.addOutput(deviceOutput)
        
        let capturePreviewLayer = self.view as! CameraPreviewView
        capturePreviewLayer.session = self.session
        capturePreviewLayer.videoPreviewLayer.videoGravity = .resize
        
        self.session.startRunning()
    }
    
    func startTextDetection() {
        let textDetectionRequest = VNDetectTextRectanglesRequest(completionHandler: self.detectTextHandler)
        textDetectionRequest.reportCharacterBoxes = true
        self.requests.append(textDetectionRequest)
    }
    
    func detectTextHandler(request: VNRequest, error: Error?) {
        guard let observations = request.results else {
            print("No Detected Blocks")
            return
        }
        
        let results = observations.map { $0 as? VNTextObservation }
        
        DispatchQueue.main.async {
            self.view.layer.sublayers?.removeSubrange(1...)
            
            for resultRegion in results {
                guard let region = resultRegion else {
                    continue
                }
                
                if let regionBox = region.characterBoxes {
                    self.highlightWord(box: region)
                    
                    for characterBox in regionBox {
                        self.highlightLetters(box: characterBox)
                    }
                }
            }
        }
    }
    
     func highlightWord(box: VNTextObservation) {
        guard let boxes = box.characterBoxes else {
            return
        }
        
        var maxX: CGFloat = CGFloat.greatestFiniteMagnitude
        var minX: CGFloat = 0.0
        var maxY: CGFloat = CGFloat.greatestFiniteMagnitude
        var minY: CGFloat = 0.0
        
        for char in boxes {
            if char.bottomLeft.x < maxX {
                maxX = char.bottomLeft.x
            }
            if char.bottomRight.x > minX {
                minX = char.bottomRight.x
            }
            if char.bottomRight.y < maxY {
                maxY = char.bottomRight.y
            }
            if char.topRight.y > minY {
                minY = char.topRight.y
            }
        }
        let xCord = maxX * self.view.frame.size.width
        let yCord = (1 - minY) * self.view.frame.size.height
        let width = (minX - maxX) * self.view.frame.size.width
        let height = (minY - maxY) * self.view.frame.size.height
        
        let outline = CALayer()
        outline.frame = CGRect(x: xCord, y: yCord, width: width, height: height)
        // outline.borderWidth = 2.0
        // outline.borderColor = UIColor.red.cgColor
        outline.backgroundColor = UIColor.red.withAlphaComponent(0.4).cgColor
        
        self.view.layer.addSublayer(outline)
    }
    
    func highlightLetters(box: VNRectangleObservation) {
        let xCord = box.topLeft.x * self.view.frame.size.width
        let yCord = (1 - box.topLeft.y) * self.view.frame.size.height
        let width = (box.topRight.x - box.bottomLeft.x) * self.view.frame.size.width
        let height = (box.topLeft.y - box.bottomLeft.y) * self.view.frame.size.height
        
        let outline = CALayer()
        outline.frame = CGRect(x: xCord, y: yCord, width: width, height: height)
        outline.borderWidth = 1.0
        outline.borderColor = UIColor.blue.cgColor
        
        self.view.layer.addSublayer(outline)
    }
   
}
