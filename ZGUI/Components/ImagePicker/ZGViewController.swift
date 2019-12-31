//
//  ZGViewController.swift
//  ZGCamera
//
//  Created by zhaogang on 2018/3/30.
//  Copyright © 2018年 zhaogang. All rights reserved.
//

import UIKit
import AVFoundation
let main_screen_w = UIScreen.main.bounds.width
let main_screen_h = UIScreen.main.bounds.height


class ZGViewController: UIViewController {
    
    fileprivate lazy var btnSwitch: UIButton = {
        let btn = UIButton(frame: CGRect(x: main_screen_w - 70, y: 30, width: 40, height: 40))
        
        
        btn.setImage(ZGUIUtil.bundleForImage("rotate.png"), placeholderImage: nil, for: .normal)
        btn.addTarget(self, action:#selector(switchScene), for: .touchUpInside)
        return btn
    }()
    
    fileprivate lazy var btnBack: UIButton = {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        btn.setImage(#imageLiteral(resourceName: "hVideo_back"), for: .normal)
        btn.addTarget(self, action:#selector(back), for: .touchUpInside)
        return btn
    }()
    
    fileprivate lazy var btnCamera: UIButton = {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        btn.setImage(#imageLiteral(resourceName: "hVideo_take"), for: .normal)
        btn.addTarget(self, action:#selector(actionForCamera), for: .touchUpInside)
        return btn
    }()
    
    lazy var bgView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width:main_screen_w , height: main_screen_h))
        return imageView
    }()
    
    /// 相机相关属性
    /*  设备相关属性 */
    let device = AVCaptureDevice.default(for: AVMediaType.video)
    
    /*输入设备 调用所有的输入硬件 如摄像头、麦克风*/
    var deviceInput : AVCaptureDeviceInput? = nil
    
    /*照片流输出 用于输出图像*/
    let imageOutput = AVCaptureStillImageOutput()
    
    /*镜头捕捉到的预览图层*/
    var previewLayer = AVCaptureVideoPreviewLayer()
    
    /*session通过AVCaptureConnection链接AVCaptureStillImageOutput进行图片输出*/
    var connection : AVCaptureConnection?
    
    /*记录屏幕的旋转方向*/
    var deviceOrientation = UIDeviceOrientation(rawValue: 0)
    
    /* 用来执行输入设备和输出设备之间的数据交换*/
    var session = AVCaptureSession()
    
    /*记录开始的缩放比例*/
    var beginGestureScale :CGFloat = 0.0
    
    /*最后的缩放比例*/
    var effectiveScale :CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //1.设置UI
        setupUI()
        
        //2.设置相机预览图层
        setupCamera()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        session.startRunning()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if session.isRunning {
            session.stopRunning()
            // previewLayer.removeFromSuperlayer()
        }
    }
    
}


// MARK: - 设置UI
extension ZGViewController{
    
    private func setupUI(){
        self.view.backgroundColor = UIColor.black
        self.view.addSubview(btnBack)
        self.view.addSubview(btnCamera)
        self.view.addSubview(btnSwitch)
        // self.view.addSubview(bgView)
        btnCamera.center = CGPoint(x: self.view.center.x, y: main_screen_h * 4/5)
        btnBack.center = CGPoint(x: btnCamera.center.x - 100, y: main_screen_h * 4/5)
        
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            print("sorry, no camera or camera is unavailable.")
            return
        }
    }
    
    private func setupCamera(){
        
        if session.canSetSessionPreset(AVCaptureSession.Preset.photo) {
            session.sessionPreset = AVCaptureSession.Preset.photo
        }
        if let device = device{
            //初始化输入设备
            deviceInput = try? AVCaptureDeviceInput(device: device)
        }
        //输出格式设置
        // let outputSettings = AVCapturePhotoSettings()
        
        //判断输入输出设备是否可用
        if let deviceInput = deviceInput{
            if session.canAddInput(deviceInput) {
                session.addInput(deviceInput)
            }
        }
        
        if session.canAddOutput(imageOutput) {
            session.addOutput(imageOutput)
        }
        
        //初始化预览图层
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        previewLayer.frame = CGRect(x: 0, y: 0, width: main_screen_w, height: main_screen_h)
        view.layer.insertSublayer(previewLayer, at: 0)
        
        
        deviceOrientation = UIDeviceOrientation.portrait
        effectiveScale = 1.0
        beginGestureScale = 1.0
    }
}


// MARK: - 按钮点击事件
extension ZGViewController{
    
    //切换镜头
    @objc private func switchScene(){
        //翻转
        UIView.beginAnimations("animation", context: nil)
        UIView.setAnimationDuration(0.5)
        UIView.setAnimationCurve(.easeInOut)
        UIView.setAnimationTransition(.flipFromRight, for: view, cache: true)
        UIView.commitAnimations()
        
        
        let inputs = session.inputs
        for input in inputs  {
            let input = input as! AVCaptureDeviceInput
            let device = input.device
            if device.hasMediaType(.video){
                let position = device.position
                var newCamera : AVCaptureDevice?
                var newInput : AVCaptureDeviceInput?
                if position == .front{
                    newCamera = cameraWithPosition(.back)
                }else{
                    newCamera = cameraWithPosition(.front)
                }
                if let newCamera = newCamera{
                    newInput = try? AVCaptureDeviceInput(device: newCamera)
                }
                
                
                session.beginConfiguration()
                session.removeInput(input)
                if let newInput = newInput{
                    session.addInput(newInput)
                }
                session.commitConfiguration()
                break
            }
            
        }
    }
    
    //开始拍照
    @objc private func actionForCamera()  {
        connection = imageOutput.connection(with: .video)
        let curDeviceOrientation = UIDevice.current.orientation
        
        /**
         *   UIDeviceOrientation 获取机器硬件的当前旋转方向
         需要注意的是如果手机手动锁定了屏幕，则不能判断旋转方向
         */
        let deviceOrientation = UIDevice.current.orientation
        let avcaptureOrientation = self.avOrientationForDeviceOrientation(deviceOrientation)
        
        connection?.videoOrientation = .landscapeLeft
        
        print("---\(curDeviceOrientation)")
        /**
         *  UIInterfaceOrientation 获取视图的当前旋转方向
         需要注意的是只有项目支持横竖屏切换才能监听到旋转方向
         */
        let status = UIApplication.shared.statusBarOrientation
        print("---\(status)")
        
        connection?.videoScaleAndCropFactor = effectiveScale
        if let connection = connection{
            
            imageOutput.captureStillImageAsynchronously(from: connection) { (imageDataSampleBuffer, error) in
                if let imageDataSampleBuffer = imageDataSampleBuffer{
                    
                    guard   let jpegData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer) else{
                        return
                    }
                    
                    //原图
                    let temp = UIImage.init(data: jpegData)
                    
                    // let cropVC = ZGCropViewController(coder: temp!)
                    
                    //  self.present(cropVC, animated: false, completion: nil)
                }
                
                
            }
        }
        
        
    }
    
    //返回
    @objc private func back(){
        dismiss(animated: true, completion: nil)
    }
    
    /*相机旋转*/
    private func cameraWithPosition(_ position:AVCaptureDevice.Position) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.devices(for: .video)
        for device in devices{
            if ( device.position == position ){
                return device
            }
        }
        return nil
    }
    
    private func avOrientationForDeviceOrientation(_ deviceOrientation:UIDeviceOrientation) -> AVCaptureVideoOrientation {
        
        var result =  AVCaptureVideoOrientation(rawValue: 0)
        if deviceOrientation == .landscapeLeft {
            result = AVCaptureVideoOrientation.landscapeRight
        }else{
            result = AVCaptureVideoOrientation.landscapeLeft
        }
        return result!
    }
    
}

extension ZGViewController{
    
    func avOrientationForDeviceOrientation(deviceOrientation:UIDeviceOrientation) -> AVCaptureVideoOrientation {
        
        var result : AVCaptureVideoOrientation?
        if ( deviceOrientation == .landscapeLeft ){
            result = .landscapeRight
        }
        else if ( deviceOrientation == .landscapeRight ){
            result = .landscapeLeft
        }
        
        return result!
    }
    
}
