//
//  ViewController.swift
//  CameraApp
//
//  Created by Ozgun Dogus on 31.07.2024.
//


import UIKit
import AVFoundation

class CameraViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    var captureSession: AVCaptureSession!
    var movieOutput: AVCaptureMovieFileOutput!
    var captureDevice: AVCaptureDevice!
    
    var previewView: PreviewView!
    var timer: Timer?
    var captureCounter = 0
    var maxCaptureCount = 150
    
    var isoSettings: [Float] = [50, 100, 200, 400, 800, 1600]
    var shutterSpeedSettings: [Double] = [1/1000, 1/500, 1/250, 1/125, 1/60, 1/30]
    
    var capturedFrames: [UIImage] = []
    
    let isoPicker = UIPickerView()
    let shutterSpeedPicker = UIPickerView()
    let capturedImageView = UIImageView()
    let pausePlayButton = UIButton(type: .custom)
    let showFramesButton = UIButton(type: .system)
    let timerLabel = UILabel()
    
    var isCapturing = false
    var remainingTime: Double = 30.0
    
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
        captureSession.sessionPreset = .high
        
        guard let device = AVCaptureDevice.default(for: .video) else {
            print("No video device found")
            return
        }
        captureDevice = device
        
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
        
        movieOutput = AVCaptureMovieFileOutput()
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
        } else {
            print("Could not add movie file output to the session")
            return
        }
        
        previewView.videoPreviewLayer.session = captureSession
        previewView.videoPreviewLayer.videoGravity = .resizeAspectFill
        
        captureSession.startRunning()
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
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        
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
        
        let innerCircle = UIView()
        innerCircle.translatesAutoresizingMaskIntoConstraints = false
        innerCircle.backgroundColor = .red
        innerCircle.layer.cornerRadius = 15
        pausePlayButton.addSubview(innerCircle)
        
        view.addSubview(pausePlayButton)
        
        showFramesButton.setTitle("Show Frames", for: .normal)
        showFramesButton.addTarget(self, action: #selector(showCapturedFrames), for: .touchUpInside)
        view.addSubview(showFramesButton)
        
        timerLabel.textColor = .white
        timerLabel.textAlignment = .center
        timerLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 18, weight: .medium)
        timerLabel.text = "00:30"
        view.addSubview(timerLabel)
        
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
            
            showFramesButton.leadingAnchor.constraint(equalTo: pausePlayButton.trailingAnchor, constant: 20),
            showFramesButton.centerYAnchor.constraint(equalTo: pausePlayButton.centerYAnchor),
            
            timerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewView.frame = view.bounds
    }
    
    func startCapturingVideo() {
        isCapturing = true
        captureCounter = 0
        remainingTime = 30.0
        let outputFilePath = NSTemporaryDirectory() + UUID().uuidString + ".mov"
        let outputURL = URL(fileURLWithPath: outputFilePath)
        movieOutput.startRecording(to: outputURL, recordingDelegate: self)
        updateInnerCircleColor(isCapturing: true)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.updateTimerLabel()
        }
    }
    
    func stopCapturingVideo() {
        isCapturing = false
        timer?.invalidate()
        timer = nil
        movieOutput.stopRecording()
        updateInnerCircleColor(isCapturing: false)
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if error == nil {
            extractFrames(from: outputFileURL)
        } else {
            print("Error recording movie: \(error!.localizedDescription)")
        }
    }
    
    func extractFrames(from videoURL: URL) {
        let asset = AVAsset(url: videoURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        let duration = asset.duration
        let durationTime = CMTimeGetSeconds(duration)
        
        var times = [NSValue]()
        for i in 0..<Int(durationTime * 5) {
            let cmTime = CMTime(seconds: Double(i) * 0.2, preferredTimescale: 600)
            times.append(NSValue(time: cmTime))
        }
        
        imageGenerator.generateCGImagesAsynchronously(forTimes: times) { requestedTime, image, actualTime, result, error in
            if let cgImage = image, result == .succeeded {
                let uiImage = UIImage(cgImage: cgImage)
                self.capturedFrames.append(uiImage)
                DispatchQueue.main.async {
                    self.capturedImageView.image = uiImage
                }
            }
        }
    }
    
    @objc func toggleCapture(sender: UIButton) {
        if isCapturing {
            stopCapturingVideo()
        } else {
            startCapturingVideo()
        }
    }
    
    @objc func showCapturedFrames() {
        let framesViewController = FramesViewController()
        framesViewController.frames = capturedFrames
        navigationController?.pushViewController(framesViewController, animated: true)
    }
    
    func updateTimerLabel() {
        remainingTime -= 1.0
        let minutes = Int(remainingTime) / 60
        let seconds = Int(remainingTime) % 60
        timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
        
        if remainingTime <= 0 {
            stopCapturingVideo()
        }
    }
    
    func updateInnerCircleColor(isCapturing: Bool) {
        if let innerCircle = pausePlayButton.subviews.first {
            innerCircle.backgroundColor = isCapturing ? .red : .gray
        }
    }
    
    func updateCameraSettings() {
        guard let device = captureDevice else { return }
        do {
            try device.lockForConfiguration()
            let iso = isoSettings[isoPicker.selectedRow(inComponent: 0)]
            let shutterSpeed = CMTimeMake(value: 1, timescale: Int32(shutterSpeedSettings[shutterSpeedPicker.selectedRow(inComponent: 0)] * 1000000))
            device.setExposureModeCustom(duration: shutterSpeed, iso: iso, completionHandler: nil)
            device.unlockForConfiguration()
        } catch {
            print("Error updating camera settings: \(error)")
        }
    }
}

extension CameraViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == isoPicker {
            return isoSettings.count
        } else if pickerView == shutterSpeedPicker {
            return shutterSpeedSettings.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == isoPicker {
            return "\(isoSettings[row])"
        } else if pickerView == shutterSpeedPicker {
            return "1/\(Int(1/shutterSpeedSettings[row]))"
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        if pickerView == isoPicker {
            label.text = "\(isoSettings[row])"
        } else if pickerView == shutterSpeedPicker {
            label.text = String(format: "1/%.0f", 1/shutterSpeedSettings[row])
        }
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        updateCameraSettings()
    }
}
