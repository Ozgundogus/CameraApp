//
//  CameraViewController.swift
//  CameraApp
//
//  Created by Ozgun Dogus on 31.07.2024.
//


import UIKit
import AVFoundation

final class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    var captureSession: AVCaptureSession!
    var captureDevice: AVCaptureDevice!
    var photoOutput: AVCapturePhotoOutput!
    var previewView: PreviewView!
    var timer: Timer?
    var captureTimer: Timer?
    var captureCounter = 0
    var maxCaptureCount = 4
    var isoSettings: [Float] = [50, 100, 200, 400, 800, 1600]
    var shutterSpeedSettings: [Double] = [1/1000, 1/500, 1/250, 1/125, 1/60, 1/30]
    var capturedFrames: [UIImage] = []
    var lastCapturedFrame: UIImage?
    
    let isoPicker = UIPickerView()
    let shutterSpeedPicker = UIPickerView()
    let capturedImageView = UIImageView()
    let pausePlayButton = UIButton(type: .custom)
    let showFramesButton = UIButton(type: .system)
    let uploadButton = UIButton(type: .system)
    let timerLabel = UILabel()
    let exitButton = UIButton(type: .system)
    let infoButton = UIButton(type: .system)
    let loadingIndicator = UIProgressView(progressViewStyle: .default)
    
    var isCapturing = false
    var remainingTime: Double = 0.0
    var videoDuration: Double = 30.0
    var totalImageSize: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        checkCameraAuthorizationStatus()
    }
    
    func checkCameraAuthorizationStatus() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.setupCamera()
                    }
                }
            }
        case .denied, .restricted:
            let alert = UIAlertController(title: "Camera Access Denied", message: "Please enable camera access in settings.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        @unknown default:
            fatalError("Unknown camera authorization status")
        }
    }
    
    func setupCamera() {
        captureSession = AVCaptureSession()
        
        guard let device = AVCaptureDevice.default(for: .video) else {
            print("No video device found")
            return
        }
        captureDevice = device
    
        var bestFormat: AVCaptureDevice.Format?
        var maxResolution: Int32 = 0
        
        for format in captureDevice.formats {
            for _ in format.videoSupportedFrameRateRanges {
                let description = format.formatDescription
                let dimensions = CMVideoFormatDescriptionGetDimensions(description)
                
                let resolution = dimensions.width * dimensions.height
                if resolution >= 4000 * 3000 && resolution > maxResolution {
                    maxResolution = resolution
                    bestFormat = format
                } else if resolution > maxResolution {
                    maxResolution = resolution
                    bestFormat = format
                }
            }
        }
        
        if let bestFormat = bestFormat {
            do {
                try captureDevice.lockForConfiguration()
                captureDevice.activeFormat = bestFormat
                captureDevice.unlockForConfiguration()
            } catch {
                print("Could not set the best format: \(error)")
            }
        }

        captureSession.sessionPreset = .high

        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            } else {
                print("Could not add video device input to the session")
                return
            }
        } catch {
            print("Could not create video device input: \(error)")
            return
        }

        photoOutput = AVCapturePhotoOutput()
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        } else {
            print("Could not add photo output to the session")
            return
        }

        previewView.videoPreviewLayer.session = captureSession
        previewView.videoPreviewLayer.videoGravity = .resizeAspectFill

        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
    
    func setupUI() {
        previewView = PreviewView()
        previewView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(previewView)
        
        isoPicker.translatesAutoresizingMaskIntoConstraints = false
        shutterSpeedPicker.translatesAutoresizingMaskIntoConstraints = false
        capturedImageView.translatesAutoresizingMaskIntoConstraints = false
        pausePlayButton.translatesAutoresizingMaskIntoConstraints = false
        showFramesButton.translatesAutoresizingMaskIntoConstraints = false
        uploadButton.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        isoPicker.dataSource = self
        isoPicker.delegate = self
        view.addSubview(isoPicker)
        
        shutterSpeedPicker.dataSource = self
        shutterSpeedPicker.delegate = self
        view.addSubview(shutterSpeedPicker)
        
        capturedImageView.contentMode = .scaleAspectFit
        view.addSubview(capturedImageView)
        
        pausePlayButton.backgroundColor = .clear
        pausePlayButton.layer.cornerRadius = 35
        pausePlayButton.layer.borderWidth = 2
        pausePlayButton.layer.borderColor = UIColor.white.cgColor
        pausePlayButton.addTarget(self, action: #selector(toggleCapture), for: .touchUpInside)
        pausePlayButton.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        pausePlayButton.addTarget(self, action: #selector(buttonTouchUp), for: [.touchUpInside, .touchUpOutside])
        
        let innerCircle = UIView()
        innerCircle.translatesAutoresizingMaskIntoConstraints = false
        innerCircle.backgroundColor = .red
        innerCircle.layer.cornerRadius = 15
        innerCircle.isUserInteractionEnabled = false
        pausePlayButton.addSubview(innerCircle)
        
        view.addSubview(pausePlayButton)
        
        showFramesButton.setTitle("Show Frames", for: .normal)
        showFramesButton.setTitleColor(.white, for: .normal)
        showFramesButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        showFramesButton.layer.cornerRadius = 8
        showFramesButton.layer.masksToBounds = true
        showFramesButton.addTarget(self, action: #selector(showCapturedFrames), for: .touchUpInside)
        showFramesButton.isHidden = true
        view.addSubview(showFramesButton)
        
        uploadButton.setTitle("Save Storage", for: .normal)
        uploadButton.setTitleColor(.white, for: .normal)
        uploadButton.backgroundColor = .purple
        uploadButton.layer.cornerRadius = 8
        uploadButton.layer.masksToBounds = true
        uploadButton.setImage(UIImage(systemName: "square.and.arrow.up.circle.fill"), for: .normal)
        uploadButton.tintColor = .yellow
        uploadButton.addTarget(self, action: #selector(uploadAction), for: .touchUpInside)
        uploadButton.isHidden = true
        uploadButton.semanticContentAttribute = .forceRightToLeft
        view.addSubview(uploadButton)
        
        exitButton.setTitle("Retake Video", for: .normal)
        exitButton.setTitleColor(.white, for: .normal)
        exitButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        exitButton.layer.cornerRadius = 8
        exitButton.layer.masksToBounds = true
        exitButton.addTarget(self, action: #selector(exitAction), for: .touchUpInside)
        view.addSubview(exitButton)
        exitButton.isHidden = true
        
        infoButton.setImage(UIImage(systemName: "info.circle.fill"), for: .normal)
        infoButton.tintColor = .white
        infoButton.addTarget(self, action: #selector(showInfo), for: .touchUpInside)
        view.addSubview(infoButton)
        infoButton.isHidden = true
        
        timerLabel.textColor = .white
        timerLabel.textAlignment = .center
        timerLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 18, weight: .medium)
        timerLabel.text = "00:00"
        view.addSubview(timerLabel)
        
        view.addSubview(loadingIndicator)
        loadingIndicator.isHidden = true
        
        NSLayoutConstraint.activate([
            previewView.topAnchor.constraint(equalTo: view.topAnchor),
            previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            previewView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            pausePlayButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            pausePlayButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pausePlayButton.widthAnchor.constraint(equalToConstant: 70),
            pausePlayButton.heightAnchor.constraint(equalToConstant: 70),
            
            innerCircle.centerXAnchor.constraint(equalTo: pausePlayButton.centerXAnchor),
            innerCircle.centerYAnchor.constraint(equalTo: pausePlayButton.centerYAnchor),
            innerCircle.widthAnchor.constraint(equalToConstant: 30),
            innerCircle.heightAnchor.constraint(equalToConstant: 30),
            
            isoPicker.trailingAnchor.constraint(equalTo: pausePlayButton.leadingAnchor, constant: -20),
            isoPicker.centerYAnchor.constraint(equalTo: pausePlayButton.centerYAnchor),
            isoPicker.widthAnchor.constraint(equalToConstant: 60),
            isoPicker.heightAnchor.constraint(equalToConstant: 60),
            
            shutterSpeedPicker.trailingAnchor.constraint(equalTo: isoPicker.leadingAnchor, constant: -10),
            shutterSpeedPicker.centerYAnchor.constraint(equalTo: pausePlayButton.centerYAnchor),
            shutterSpeedPicker.widthAnchor.constraint(equalToConstant: 60),
            shutterSpeedPicker.heightAnchor.constraint(equalToConstant: 60),
            
            showFramesButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            showFramesButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            showFramesButton.heightAnchor.constraint(equalToConstant: 40),
            showFramesButton.widthAnchor.constraint(equalToConstant: 120),
            
            uploadButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            uploadButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            uploadButton.heightAnchor.constraint(equalToConstant: 40),
            uploadButton.widthAnchor.constraint(equalToConstant: 140),
            
            timerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            exitButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            exitButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            exitButton.heightAnchor.constraint(equalToConstant: 40),
            exitButton.widthAnchor.constraint(equalToConstant: 120),
            
            infoButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 18),
            infoButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingIndicator.widthAnchor.constraint(equalToConstant: 200)
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewView.frame = view.bounds
        
        if let lastCapturedFrame = lastCapturedFrame {
            capturedImageView.image = lastCapturedFrame
            capturedImageView.frame = previewView.frame
            capturedImageView.contentMode = .scaleAspectFill
        }
    }
    
    func startCapturingPhotos() {
        isCapturing = true
        captureCounter = 0
        remainingTime = 0.0
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.updateTimerLabel()
        }
        
        captureTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { _ in
            self.capturePhoto()
        }
    }
    
    func stopCapturingPhotos() {
        isCapturing = false
        captureTimer?.invalidate()
        captureTimer = nil
        timer?.invalidate()
        timer = nil
        
        showFramesButton.isHidden = false
        uploadButton.isHidden = false
        infoButton.isHidden = false
        
        pausePlayButton.isHidden = true
        isoPicker.isHidden = true
        shutterSpeedPicker.isHidden = true
        exitButton.isHidden = false
    }

    func capturePhoto() {
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.flashMode = .off
        photoSettings.isAutoStillImageStabilizationEnabled = photoOutput.isStillImageStabilizationSupported
        
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
          AudioServicesDisposeSystemSoundID(1108)
      }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            return
        }

        DispatchQueue.global(qos: .background).async {
            if let imageData = photo.fileDataRepresentation(),
               let image = UIImage(data: imageData) {
                self.capturedFrames.append(image)
                self.totalImageSize += imageData.count
                
            }
        }
    }
    
    @objc func toggleCapture(sender: UIButton) {
        if isCapturing {
            stopCapturingPhotos()
        } else {
            startCapturingPhotos()
            lastCapturedFrame = nil
            capturedImageView.image = nil
        }
    }
    
    @objc func buttonTouchDown(sender: UIButton) {
        sender.alpha = 0.5
    }
    
    @objc func buttonTouchUp(sender: UIButton) {
        sender.alpha = 1.0
    }
    
    @objc func showCapturedFrames() {
        let framesViewController = FramesViewController()
        framesViewController.frames = capturedFrames
        navigationController?.pushViewController(framesViewController, animated: true)
    }
    
    @objc func exitAction() {
        stopCapturingPhotos()
        
        DispatchQueue.main.async {
            self.capturedFrames.removeAll()
            
            self.capturedImageView.image = nil
            self.lastCapturedFrame = nil
            
            self.pausePlayButton.isHidden = false
            self.isoPicker.isHidden = false
            self.shutterSpeedPicker.isHidden = false
            self.exitButton.isHidden = true
            self.showFramesButton.isHidden = true
            self.uploadButton.isHidden = true
            self.infoButton.isHidden = true
            
            self.remainingTime = 0.0
            self.timerLabel.text = String(format: "%02d:%02d", Int(self.remainingTime) / 60, Int(self.remainingTime) % 60)
            
            self.isCapturing = false
        }
    }

    @objc func uploadAction() {
        showLoadingIndicator()
        
        DispatchQueue.global(qos: .background).async {
            self.saveCapturedImagesToLocalStorage()
            
            DispatchQueue.main.async {
                self.hideLoadingIndicator()
                self.navigateToCapturedImagesViewController()
            }
        }
    }
    
    func showLoadingIndicator() {
        loadingIndicator.isHidden = false
        loadingIndicator.progress = 0.0
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if self.loadingIndicator.progress >= 1.0 {
                timer.invalidate()
            } else {
                self.loadingIndicator.progress += 0.01
            }
        }
    }
    
    func hideLoadingIndicator() {
        loadingIndicator.isHidden = true
    }
    
    func navigateToCapturedImagesViewController() {
        let capturedImagesViewController = CapturedImagesViewController()
        navigationController?.pushViewController(capturedImagesViewController, animated: true)
    }
    
    func saveCapturedImagesToLocalStorage() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        for (index, frame) in self.capturedFrames.enumerated() {
            if let imageData = frame.jpegData(compressionQuality: 1.0) {
                let fileName = "captured_frame_\(index).jpg"
                let fileURL = documentsPath.appendingPathComponent(fileName)
                
                do {
                    try imageData.write(to: fileURL)
                } catch {
                    print("Error saving image: \(error)")
                }
            }
        }
        
        DispatchQueue.main.async {
            self.capturedFrames.removeAll()
            self.capturedImageView.image = nil
        }
    }
    
    func updateTimerLabel() {
        remainingTime += 1.0
        let minutes = Int(remainingTime) / 60
        let seconds = Int(remainingTime) % 60
        timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
        
    }
    
    func updateCameraSettings() {
        guard let device = captureDevice else { return }
        do {
            try device.lockForConfiguration()
            
            let iso = isoSettings[isoPicker.selectedRow(inComponent: 0)]
            let minISO = device.activeFormat.minISO
            let maxISO = device.activeFormat.maxISO
            let adjustedISO = min(max(iso, minISO), maxISO)
            
            let selectedShutterSpeed = shutterSpeedSettings[shutterSpeedPicker.selectedRow(inComponent: 0)]
            let shutterSpeed = CMTimeMake(value: 1, timescale: Int32(1.0 / selectedShutterSpeed))
            
            let minDuration = device.activeFormat.minExposureDuration
            let maxDuration = device.activeFormat.maxExposureDuration
            let adjustedShutterSpeed = CMTimeMinimum(CMTimeMaximum(shutterSpeed, minDuration), maxDuration)
            
            device.setExposureModeCustom(duration: adjustedShutterSpeed, iso: adjustedISO, completionHandler: nil)
            device.unlockForConfiguration()
        } catch {
            print("Error updating camera settings: \(error)")
        }
    }

    
    @objc func showInfo() {
        let bottomSheet = FramesInfoBottomSheetViewController()
        bottomSheet.totalDuration = remainingTime
        bottomSheet.totalFrames = capturedFrames.count
        bottomSheet.totalSize = totalImageSize
        present(bottomSheet, animated: true, completion: nil)
    }
}
