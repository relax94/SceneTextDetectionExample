//
//  CameraPreviewView.swift
//  SceneTextDetection
//
//  Created by Dmytro Pavlenko on 10/4/18.
//  Copyright © 2018 Dmytro Pavlenko. All rights reserved.
//

import UIKit
import AVFoundation

class CameraPreviewView : UIView {
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        guard let layer = layer as? AVCaptureVideoPreviewLayer else {
            fatalError("Expected `AVCaptureVideoPreviewLayer` type for layer. Check PreviewView.layerClass implementation.")
        }
        return layer
    }
    var session: AVCaptureSession? {
        get {
            return videoPreviewLayer.session
        }
        set {
            videoPreviewLayer.session = newValue
        }
    }
    // MARK: UIView
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
}
