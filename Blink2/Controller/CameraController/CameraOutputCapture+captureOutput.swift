//
//  CameraVideoOutputCapture+extension.swift
//  Blink2
//
//  Created by Brian Foley on 5/25/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//

import UIKit
import AVFoundation
import ImageIO

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer).seconds
            //print(timestamp)
           switch _captureState {
           case .start:
                fileName = UUID().uuidString
                let videoPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(fileName).mov")
                videoWriter = try! AVAssetWriter(outputURL: videoPath, fileType: .mov)
                let settings = videoDataOutput.recommendedVideoSettingsForAssetWriter(writingTo: .mov)
                videoWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: settings) // [AVVideoCodecKey: AVVideoCodecType.h264, AVVideoWidthKey: 1920, AVVideoHeightKey: 1080])
                videoWriterInput.transform = CGAffineTransform(rotationAngle: .pi/2)
                adapter = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoWriterInput, sourcePixelBufferAttributes: nil)
                videoWriterInput.mediaTimeScale = CMTimeScale(bitPattern: 600)
                
                videoWriterInput.expectsMediaDataInRealTime = true
                if videoWriter.canAdd(videoWriterInput) {
                    videoWriter.add(videoWriterInput)
                }
                
                audioWriterInput = AVAssetWriterInput(mediaType: .audio, outputSettings: [
                    AVFormatIDKey: kAudioFormatMPEG4AAC,
                    AVNumberOfChannelsKey: 1,
                    AVSampleRateKey: 44100,
                    AVEncoderBitRateKey: 64000,
                ])

                if videoWriter.canAdd(audioWriterInput) {
                    videoWriter.add(audioWriterInput)
                }
                //_time = timestamp
                videoWriter.startWriting()
                videoWriter.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
                _captureState = .capturing
           case .capturing:
                if videoWriterInput?.isReadyForMoreMediaData == true && output == videoDataOutput{
                    let epsilon = 0.15506712302235
                    let time = CMTime(seconds: timestamp-epsilon, preferredTimescale: CMTimeScale(600))
                    adapter?.append(CMSampleBufferGetImageBuffer(sampleBuffer)!, withPresentationTime: time)
                    //videoWriterInput.append(sampleBuffer)
                }
                if audioWriterInput.isReadyForMoreMediaData && output == audioDataOutput{
                    audioWriterInput.append(sampleBuffer)
                }
           case .end:
               guard videoWriterInput?.isReadyForMoreMediaData == true, videoWriter!.status != .failed else { break }
               let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(fileName).mov")
               videoWriterInput?.markAsFinished()
               _captureState = .idle
               videoWriter?.finishWriting { [weak self] in
                   self?.player = AVPlayer(url: url)
                   self?.player?.actionAtItemEnd = .none
                   DispatchQueue.main.async {
                        self?.setMediaPreview(isVideo: true)
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
            self.setMediaPreview(isVideo: false)
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
