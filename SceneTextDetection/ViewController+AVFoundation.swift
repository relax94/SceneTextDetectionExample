//
//  ViewController+AVFoundation.swift
//  SceneTextDetection
//
//  Created by Dmytro Pavlenko on 10/4/18.
//  Copyright © 2018 Dmytro Pavlenko. All rights reserved.
//

import Foundation
import AVFoundation
import Vision

extension ViewController : AVCaptureVideoDataOutputSampleBufferDelegate {
    
    internal func getCaptureDevice() -> AVCaptureDevice? {
        return AVCaptureDevice.default(for: .video)
    }
    
    internal func getCaptureDeviceInput(_ device: AVCaptureDevice) -> AVCaptureDeviceInput? {
        return try? AVCaptureDeviceInput(device: device)
    }
    
    internal func getCaptureDeviceOutput() -> AVCaptureVideoDataOutput {
        let deviceOutput = AVCaptureVideoDataOutput()
        deviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        deviceOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
        
        return deviceOutput
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        var requestOptions:[VNImageOption : Any] = [:]
        
        if let camData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) {
            requestOptions = [.cameraIntrinsics:camData]
        }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: CGImagePropertyOrientation(rawValue: 6)!, options: requestOptions)
        
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
        self.recognizeViaTesseract(pixelBuffer: pixelBuffer)
    }
    
    func recognizeViaTesseract(pixelBuffer: CVImageBuffer) {
        var ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let transform = ciImage.orientationTransform(for: CGImagePropertyOrientation(rawValue: 6)!)
        ciImage = ciImage.transformed(by: transform)
        let size = ciImage.extent.size
        
        for textObservation in textObservations {
            guard let rects = textObservation.characterBoxes else {
                continue
            }
            
            var xMin = CGFloat.greatestFiniteMagnitude
            var xMax: CGFloat = 0
            var yMin = CGFloat.greatestFiniteMagnitude
            var yMax: CGFloat = 0
            for rect in rects {
                
                xMin = min(xMin, rect.bottomLeft.x)
                xMax = max(xMax, rect.bottomRight.x)
                yMin = min(yMin, rect.bottomRight.y)
                yMax = max(yMax, rect.topRight.y)
            }
            
            let imageRect = CGRect(x: xMin * size.width, y: yMin * size.height, width: (xMax - xMin) * size.width, height: (yMax - yMin) * size.height)
            let context = CIContext(options: nil)
            guard let cgImage = context.createCGImage(ciImage, from: imageRect) else {
                continue
            }
            let uiImage = UIImage(cgImage: cgImage)
            tesseract?.image = uiImage
            tesseract?.recognize()
            guard var text = tesseract?.recognizedText else {
                continue
            }
            text = text.trimmingCharacters(in: CharacterSet.newlines)
            if !text.isEmpty {
                print(text)
            }
            self.textObservations.removeAll()
            
        }
    }
    
}


