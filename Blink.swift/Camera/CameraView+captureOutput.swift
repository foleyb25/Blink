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

extension MultiCamSession: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate {
    
    func convert(cmage:CIImage) -> UIImage? {
        let context = CIContext.init(options: nil)
        guard let cgImage = context.createCGImage(cmage, from:cmage.extent) else {return nil}
        let image = UIImage.init(cgImage: cgImage)
        return image
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        if isCapturePhoto {
            guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
            let ciimage = CIImage(cvPixelBuffer: imageBuffer)
            guard let image = convert(cmage: ciimage) else {return}
            DispatchQueue.main.async {
                self.multiCamDelegate?.togglePreviewMode(url:nil, image: image)
            }
            isCapturePhoto = false
        }
        
        switch _captureState {
        
        //configure asset writer
        case .start:
            fileName = UUID().uuidString
            // Set the path as to where the video data will be saved
            let videoPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(fileName).mov")
            
            // initialize a new AssetWriter. This is the primary Controller for all assets
            assetWriter = try! AVAssetWriter(outputURL: videoPath, fileType: .mov)
            
            let settings = backVideoDataOutput.recommendedVideoSettingsForAssetWriter(writingTo: .mov)
            
            videoWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
            
            videoWriterInput.expectsMediaDataInRealTime = true
            
            if assetWriter.canAdd(videoWriterInput) {
                assetWriter.add(videoWriterInput)
            }
            
            assetWriter.startWriting()
            assetWriter.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
            _captureState = .running
            break;
            
        //capture CMSSampleBuffer
        case .running:
            
            if videoWriterInput?.isReadyForMoreMediaData == true {
                videoWriterInput?.append(sampleBuffer)
            }
            break;
            
        //end assetwriter and send url data
        case .finished:
            _captureState = .idle
            guard videoWriterInput?.isReadyForMoreMediaData == true, assetWriter!.status != .failed else { return }
            url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(fileName).mov")
            
            videoWriterInput?.markAsFinished()
            assetWriter?.finishWriting {
                DispatchQueue.main.async {
                    self.assetWriter = nil
                    self.videoWriterInput = nil
                    self.multiCamDelegate?.togglePreviewMode(url: self.url, image: nil)
                }
            }
            break;
        
        default:
            break
        }
    }

}
