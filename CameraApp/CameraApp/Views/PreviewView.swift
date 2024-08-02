//
//  PreviewView.swift
//  CameraApp
//
//  Created by Ozgun Dogus on 1.08.2024.
//


import UIKit
import AVFoundation

class PreviewView: UIView {
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
}
