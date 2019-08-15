//
//  ViewController.swift
//  VideoCapture
//
//  Created by 刘金萌 on 2019/8/15.
//  Copyright © 2019 刘金萌. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    fileprivate lazy var videoQueue = DispatchQueue.global()
    fileprivate lazy var audioQueue = DispatchQueue.global()
    
    fileprivate lazy var session: AVCaptureSession = AVCaptureSession()
    fileprivate lazy var previewLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.session)
    
    fileprivate var connection : AVCaptureConnection?
    fileprivate var videoInput : AVCaptureDeviceInput?
    
    fileprivate var videoOutput : AVCaptureVideoDataOutput?
}

// MARK:- 视频的开始采集&停止采集
extension ViewController {
    
    @IBAction func startCapture(_ sender: Any) {
        // 1.设置视频的输入&输出
        setupVideo()
        
        // 2.设置音频的输入&输出
        setupAudio()
        
        // 3.给用户创建一个预览图层（可选）
        previewLayer.frame = view.bounds
        view.layer.insertSublayer(previewLayer, at: 0)
        
        // 4.开始采集
        session.startRunning()
        
    }
    
    @IBAction func endCapture(_ sender: Any) {
        session.stopRunning()
        previewLayer.removeFromSuperlayer()
    }
    
    @IBAction func switchScene(_ sender: Any) {
        // 1.获取当前显示的镜头
        guard var position = videoInput?.device.position else { return }
        
        // 2.获取切换后应该显示的镜头
        position = position == .front ? .back : .front
        
        // 3.根据新的镜头创建新的device
        let devices = AVCaptureDevice.devices(for: .video) as? [AVCaptureDevice]
        guard let device = devices?.filter({ $0.position == position }).first else { return }
        
        // 4.根据新的device创建新的input
        guard let videoInput = try? AVCaptureDeviceInput(device: device) else { return }
        
        // 5.在section里切换input
        session.beginConfiguration()
        session.removeInput(self.videoInput!)
        session.addInput(videoInput)
        session.commitConfiguration()
        self.videoInput = videoInput
    }
    
}

extension ViewController {
    fileprivate func setupVideo() {
        // 1.给捕捉会话创建输入源(摄像头📹)
        // 1.1获取摄像头设备
        guard let devices = AVCaptureDevice.devices(for: .video) as? [AVCaptureDevice] else {
            print("摄像头不可用")
        }
        guard let device = devices.filter({ $0.position == .front }).first else { return }
        // 1.2通过device创建AVCaptureInput对象
        guard let videoInput = try? AVCaptureDeviceInput(device: device) else { return }
        self.videoInput = videoInput
        // 1.3将input添加到会话中
        session.addInput(videoInput)
        
        // 2.给捕捉会话创建输出源
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: videoQueue)
        session.addOutput(videoOutput)
        
        // 3.获取video对应的connection
        self.videoOutput = videoOutput
    }
    fileprivate func setupAudio() {
        // 1.设置音频的输入（话筒🎙️）
        guard let device = AVCaptureDevice.default(for: .audio) else { return }
        
        guard let audioInput = try? AVCaptureDeviceInput(device: device) else { return }
        
        session.addInput(audioInput)
        
        let audioOutput = AVCaptureAudioDataOutput()
        audioOutput.setSampleBufferDelegate(self, queue: audioQueue)
        session.addOutput(audioOutput)
        
    }
}

// MARK:- 获取数据
extension ViewController : AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate{
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if connection == videoOutput?.connection(with: .video) {
            print("采集到视频画面")
        }else {
            print("采集到音频")
        }
    }
}
