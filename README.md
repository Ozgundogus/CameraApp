# CameraApp

## Overview

CameraApp is an iOS application designed to capture high-resolution videos and extract frames from those videos. It includes various camera settings such as ISO and shutter speed adjustments to enhance the quality of the captured media.

Features

- High-Resolution Video Recording: Capture videos up to 4000x3000 resolution.
- Frame Extraction: Extract frames from the recorded video at 0.2-second intervals.
- ISO and Shutter Speed Adjustments: Customize ISO and shutter speed for better exposure control.
- User Interface Controls: Easy-to-use buttons for starting/stopping recording, showing frames, uploading data, and retaking videos.
 - Real-Time Camera Preview: Full-screen camera preview with real-time adjustments.
Installation

1- Clone the repository:
```bash
git clone https://github.com/your-repository/CameraApp.git
```
2-Open the project in Xcode:
```bash
cd CameraApp
open CameraApp.xcodeproj
```
3- Build and run the project on a physical iOS device.

## Functionality Explanation

### Main Components

CameraViewController

This is the main view controller that handles camera setup, recording, and frame extraction.

- _captureSession: Manages the flow of data from the input devices (camera) to the output (movie file)._
- _movieOutput: Manages the output for movie file recording._
- _captureDevice: Represents the physical camera device._
- _previewView: Displays the camera preview._
- _timer: A timer for countdown during video recording._
- _isoSettings and shutterSpeedSettings: Arrays of possible ISO values and shutter speeds._
- _capturedFrames: Stores the extracted frames from the video._
- _videoSegments: Stores the URLs of recorded video segments._
- _lastCapturedFrame: Stores the last captured frame as a UIImage._

## User Interface Elements

- _isoPicker, shutterSpeedPicker: Pickers for selecting ISO and shutter speed values._
- _capturedImageView: Displays the last captured frame._
- _pausePlayButton, showFramesButton, uploadButton, timerLabel, exitButton, infoButton, loadingIndicator: Various buttons and labels for controlling the app._

## Methods

- _checkCameraAuthorizationStatus(): Checks if the app has permission to use the camera._
- _setupCamera(): Configures the camera settings and starts the capture session._
- _setupUI(): Sets up the user interface layout and constraints._
- _startCapturingVideo(): Starts the video recording process._
- _stopCapturingVideo(): Stops the video recording process._
- _fileOutput(:didFinishRecordingTo:from:connections:error:): Handles the completion of video recording._
- _extractFrames(from:): Extracts frames from the recorded video._
- _toggleCapture(sender:): Toggles between starting and stopping video recording._
- _updateTimerLabel(): Updates the countdown timer during recording._
- _updateInnerCircleColor(isCapturing:): Updates the color of the inner circle on the pause/play button._
- _updateCameraSettings(): Applies the selected ISO and shutter speed settings to the camera._
- _showInfo(): Displays additional information about the recorded video._
- _uploadAction(): Manages the process of saving the captured images to local storage._
- _showLoadingIndicator(), hideLoadingIndicator(): Shows and hides the loading indicator._
- _navigateToCapturedImagesViewController(): Navigates to the view controller that displays captured images._
- _saveCapturedImagesToLocalStorage(): Saves the extracted frames to local storage._
- _getTotalDuration(): Calculates the total duration of the recorded video segments._

### ISO and Shutter Speed Usage

### ISO Settings:

- Use the isoPicker to select an ISO value. Higher values provide greater sensitivity in low light conditions.

### Shutter Speed Settings:

- Use the shutterSpeedPicker to select a shutter speed. Faster speeds (e.g., 1/1000) freeze motion, while slower speeds (e.g., 1/30) create motion blur.

## User Interface Controls

- Pause/Play Button: Starts or stops video recording.
- Show Frames Button: Displays the extracted frames from the recorded video.
- Upload Button: Saves the captured images to local storage.
- Exit Button: Resets the app and prepares it for a new video capture session.
- Info Button: Shows additional information about the recorded video.
- ISO and Shutter Speed Pickers: Adjusts camera settings for better exposure control.

## Save to Storage Functionality

The "Save Storage" functionality allows users to save extracted frames to the local storage and then delete them from memory to free up space.

- __**Saving Frames to Storage:**__

    - **The extracted frames are saved as JPEG files in the app's document directory.**
    - **The saveCapturedImagesToLocalStorage method iterates through the capturedFrames array, converts each UIImage to JPEG data, and writes it to a file in the document directory.**


- __**Deleting Frames from Memory:**__

    - **After saving the frames to local storage, the capturedFrames array is cleared to free up memory.**
- **This is done within the saveCapturedImagesToLocalStorage method after all frames are saved to disk.**

## Detailed Steps for Saving Frames

- **Extract Frames:**

    - _**Frames are extracted from the video using AVAssetImageGenerator and stored in the capturedFrames array.**_

- **Save Frames to Local Storage:**

    - _**The saveCapturedImagesToLocalStorage method is called, which:**_
        - _Iterates through the capturedFrames array._
        - _Converts each frame to JPEG data._
        - _Writes the JPEG data to a file in the document directory._

- **Clear Frames from Memory:**

    - **After successfully saving the frames, the capturedFrames array is cleared to free up memory.**
