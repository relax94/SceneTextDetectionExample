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
    }
    
}
