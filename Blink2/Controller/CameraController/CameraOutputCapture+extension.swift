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

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer).seconds
            //print(timestamp)
           switch _captureState {
           case .start:
                /*
               // Set up recorder
               fileName = UUID().uuidString
               let videoPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(fileName).mov")
               let writer = try! AVAssetWriter(outputURL: videoPath, fileType: .mov)
               let settings = videoDataOutput!.recommendedVideoSettingsForAssetWriter(writingTo: .mov)
               let input = AVAssetWriterInput(mediaType: .video, outputSettings: settings) // [AVVideoCodecKey: AVVideoCodecType.h264, AVVideoWidthKey: 1920, AVVideoHeightKey: 1080])
               input.mediaTimeScale = CMTimeScale(bitPattern: 600)
               input.expectsMediaDataInRealTime = true
               input.transform = CGAffineTransform(rotationAngle: .pi/2)
               let adapter = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: nil)
               if writer.canAdd(input) {
                   writer.add(input)
               }
               writer.startWriting()
               writer.startSession(atSourceTime: .zero)
               assetWriter = writer
               assetWriterInput = input
               adpater = adapter
               _captureState = .capturing
               
                */
                fileName = UUID().uuidString
                let videoPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(fileName).mov")
                videoWriter = try! AVAssetWriter(outputURL: videoPath, fileType: .mov)
                let settings = videoDataOutput!.recommendedVideoSettingsForAssetWriter(writingTo: .mov)
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
                    //let epsilon = 0.14306712302235
                    let epsilon = 0.15506712302235
                    print(timestamp-epsilon - _time)
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
                   //self?.assetWriter = nil
                   //self?.assetWriterInput = nil
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
}
