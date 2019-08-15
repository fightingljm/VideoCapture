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
    fileprivate lazy var session: AVCaptureSession = AVCaptureSession()
    fileprivate lazy var previewLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.session)
}

// MARK:- 视频的开始采集&停止采集
extension ViewController {
    
    @IBAction func startCapture(_ sender: Any) {
        
        // 1.创建捕捉会话
        
        // 2.给捕捉会话创建输入源(摄像头)
        // 获取摄像头设备
        guard let devices = AVCaptureDevice.devices(for: AVMediaType.video) as? [AVCaptureDevice] else {
            print("摄像头不可用")
        }
        guard let device = devices.filter({ $0.position == .front }).first else { return }
        // 通过device创建AVCaptureInput对象
        guard let videoInput = try? AVCaptureDeviceInput(device: device) else { return }
        // 将input添加到会话中
        session.addInput(videoInput)
        
        // 3.给捕捉会话创建输出源
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: videoQueue)
        session.addOutput(videoOutput)
        
        // 4.给用户创建一个预览图层（可选）
        previewLayer.frame = view.bounds
        view.layer.insertSublayer(previewLayer, at: 0)
        
        // 5.开始采集
        session.startRunning()
        
    }
    
    @IBAction func endCapture(_ sender: Any) {
        session.stopRunning()
        previewLayer.removeFromSuperlayer()
    }
    
}

extension ViewController : AVCaptureVideoDataOutputSampleBufferDelegate{
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        print("已经采集到画面")
    }
}
