//
//  CameraVideoOutputCapture+extension.swift
//  Blink2
//
//  Created by Brian Foley on 5/25/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//
//
// TODO: Research Live Recording video projects similar to facetime or zoom to see how to enable recording while flipping camera
// TODO: Delete File from file manager after video recording. Look into memory usage when a video has been recorded and saved
// TODO: Look into using captureOutput for photo capture as well. On stop shop for media capture

import UIKit
import AVFoundation
import ImageIO

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate {
    
    // for video and audio data capture. data flows in at different intervals but it is hardly noticable on preview
    // @Override
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer).seconds
           switch _captureState {
           case .start:
                if (fileName != "") {
                    print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(fileName).mov"))
                }
                // file name used to store temporary video data for sending/retrieval
                fileName = UUID().uuidString
                // Set the path as to where the video data will be saved
                let videoPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(fileName).mov")
                // initialize a new AssetWriter. This is the primary Controller for all assets
                videoWriter = try! AVAssetWriter(outputURL: videoPath, fileType: .mov)
                // set the settings for the asset writer to .mov extension
                let settings = videoDataOutput.recommendedVideoSettingsForAssetWriter(writingTo: .mov)
                // Initialize AssetWriterInput. This is video capture Input
                videoWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: settings) // [AVVideoCodecKey: AVVideoCodecType.h264, AVVideoWidthKey: 1920, AVVideoHeightKey: 1080])
                // The default capture settings for asset writer is landscape. Rotate the capture input 90 degrees clockwise
                var transform = CGAffineTransform(rotationAngle: .pi/2)

                // Mirror the image if the current camera is the front camera
                if currentCamera == .front {
                    transform = transform.scaledBy(x: 1.0, y: -1.0)
                }
            
                // Apply transform to writer input
                videoWriterInput.transform = transform
            
                // adapter is used to continuously collect input data from multiple capture devices. Need this for capture while camera changes
                adapter = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoWriterInput, sourcePixelBufferAttributes: nil)
            
                //Set TimeScale to 3000 for smooth recording
                videoWriterInput.mediaTimeScale = CMTimeScale(3000)
            
                videoWriterInput.expectsMediaDataInRealTime = true
                if videoWriter.canAdd(videoWriterInput) {
                    videoWriter.add(videoWriterInput)
                }
                
                // Initialize AssetWriterInput. This is audio capture Input
                audioWriterInput = AVAssetWriterInput(mediaType: .audio, outputSettings: [
                    AVFormatIDKey: kAudioFormatMPEG4AAC,
                    AVNumberOfChannelsKey: 1,
                    AVSampleRateKey: 44100,
                    AVEncoderBitRateKey: 64000,
                ])

                if videoWriter.canAdd(audioWriterInput) {
                    videoWriter.add(audioWriterInput)
                }
                videoWriter.startWriting()
            videoWriter.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
                _captureState = .capturing
           case .capturing:
                //check to see if data stream is video
                if videoWriterInput?.isReadyForMoreMediaData == true && output == videoDataOutput{
                    //epsilon is used to skip frames captured in the first milliseconds of recording. If frames are skipped, the capture time on the adapter is not in synce with the duration of the actual duration of video stored. This creates a gap when recording in the preview layer
                    let epsilon = 0.20
                    let time = CMTime(seconds: timestamp-epsilon, preferredTimescale: CMTimeScale(3000))
                    //apend imagebuffer to adapter
                    adapter?.append(CMSampleBufferGetImageBuffer(sampleBuffer)!, withPresentationTime: time)
                }
                // check to see if data stream is audio
                if audioWriterInput.isReadyForMoreMediaData && output == audioDataOutput{
                    audioWriterInput.append(sampleBuffer)
                }
            
           case .end:
                //check to see if videowriter is recording and has not failed. Then we can stop recording.
               guard videoWriterInput?.isReadyForMoreMediaData == true, videoWriter!.status != .failed else { break }
               let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(fileName).mov")
               videoWriterInput?.markAsFinished()
               
               videoWriter?.finishWriting { [weak self] in
                   
                self?._captureState = .idle
                   DispatchQueue.main.async {
                        self?.setMediaPreview(url: url)
                   }
               }
           default:
               break
           }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
           //photoProcessingHandler(false)
        if let imageData = photo.fileDataRepresentation() {
           let dataProvider = CGDataProvider(data: imageData as CFData)
           let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
            image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: getImageOrientation(forCamera: self.currentCamera))
            //
           DispatchQueue.main.async {
            self.setMediaPreview(url: nil)
           }
       }
    }
    
    func capturePhoto() {
        //Capture picture in a thread
        if self.isRecording {
            return
        }
        
        sessionQueue.async {
            
            var photoSettings = AVCapturePhotoSettings()
            
            // Capture HEIF photos when supported. Enable auto-flash and high-resolution photos.
            if  self.photoOutput.availablePhotoCodecTypes.contains(.jpeg) {
                photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
            }
            
            if self.videoDeviceInput.device.isFlashAvailable {
                switch self.flashMode {
                case .auto:
                    photoSettings.flashMode = .auto
                case .on:
                    photoSettings.flashMode = .on
                case .off:
                    photoSettings.flashMode = .off
                }
            }
            
            photoSettings.isHighResolutionPhotoEnabled = true
            if !photoSettings.__availablePreviewPhotoPixelFormatTypes.isEmpty {
                photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoSettings.__availablePreviewPhotoPixelFormatTypes.first!]
            }
            self.photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
    
    func record() {
       switch _captureState {
        
       case .idle:
           Animations.animateRecordButton(videoButton: videoButton, captureButton: captureButton)
           _captureState = .start
       case .capturing:
            isRecording = false
           _captureState = .end
           Animations.animateMoveRecordButtonBack(button: videoButton)
       default:
            print("unknown capture state")
       }
               
    }
}
