//
//  AuthingMFAFaceVC.swift
//  Guard
//
//  Created by JnMars on 2022/6/28.
//

import Foundation
import UIKit
import AVFoundation

class AuthingMFAFaceVC: AuthViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    public var needBindingFace: Bool = !(Authing.getCurrentUser()?.faceMfaEnabled ?? false)
    private var faceImages: [UIImage] = []
    private var isDetecting: Bool = false
    
    lazy var queue: DispatchQueue = {
        let q = DispatchQueue(label: "cameraQueue")
        return q
    }()
    
    let loading = UIActivityIndicatorView()
    
    private var countDown: Int = 0{
        didSet {
            self.progress.setProgress(countDown)
            if countDown == 0 {
                self.faceImages = []
                self.gcdTimer?.cancel()
                self.tipLabel.text = "请保持摄像头已打开并无遮挡"
            } else if countDown == 100{
                self.gcdTimer?.cancel()
            } else {
                self.tipLabel.text = "请保持姿势不变"
            }
        }
    }
    var gcdTimer: DispatchSourceTimer?
        
    lazy var tipLabel: UILabel = {
        let b = UILabel()
        b.textColor = .black
        b.textAlignment = .center
        b.text = "请保持摄像头已打开并无遮挡"
        b.font = .systemFont(ofSize: 24, weight: .bold)
        return b
    }()
    
    lazy var progress: CircleProgressView = {
        let p = CircleProgressView.init()
        p.setProgress(0)
        return p
    }()
    
    // AVFoundation
    lazy var preview: AVCaptureVideoPreviewLayer = {
        let p = AVCaptureVideoPreviewLayer(session: session)
        p.cornerRadius = 120
        p.videoGravity = .resizeAspectFill
        return p
    }()
    lazy var session: AVCaptureSession = {
        let session = AVCaptureSession()
        session.canSetSessionPreset(.vga640x480)
        if let input = captureInput {
            session.addInput(input)
            session.addOutput(captureOutput)
            session.addOutput(captureImageOutput)
        }
        return session
    }()
    lazy var device: AVCaptureDevice? = {
        let dss = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .front)
        return dss.devices.first
    }()
    lazy var captureInput: AVCaptureDeviceInput? = {
        if let d = device {
            let ci = try? AVCaptureDeviceInput(device: d)
            return ci
        }
        return nil
    }()
    lazy var captureOutput: AVCaptureVideoDataOutput = {
        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(self, queue: queue)
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        return output
    }()
    lazy var captureImageOutput: AVCapturePhotoOutput = {
        let o = AVCapturePhotoOutput()
        o.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey:AVVideoCodecType.jpeg])], completionHandler: nil)
        
        return o
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.needBindingFace == true ? "绑定人脸识别" : "人脸识别"
        
        view.backgroundColor = UIColor.white
        preview.frame = CGRect(x: UIScreen.main.bounds.width/2 - 120, y: UIScreen.main.bounds.height/2 - 120, width: 240, height: 240)
        view.layer.addSublayer(preview)
        
        progress.frame = CGRect(x: UIScreen.main.bounds.width/2 - 122.5, y: UIScreen.main.bounds.height/2 - 122.5, width: 245, height: 245)
        view.addSubview(progress)
                
        tipLabel.frame = CGRect(x: 0, y: 120, width: UIScreen.main.bounds.width, height: 50)
        view.addSubview(tipLabel)
        
        loading.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        loading.color = UIColor.white
        if #available(iOS 13.0, *) {
            loading.style = .large
        } else {
            loading.style = .whiteLarge
        }
        loading.center = self.view.center
        view.addSubview(loading)
                        
        session.startRunning()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    deinit {
        print("==============deinit")
    }

}

extension AuthingMFAFaceVC {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
         
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)
                
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        guard let newContext = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue) else {
            return
        }
        newContext.concatenate(CGAffineTransform(rotationAngle: CGFloat.pi/2))
        guard let newImage = newContext.makeImage() else { return }
        
        let image = UIImage(cgImage: newImage, scale: 1, orientation: .leftMirrored)
        
        performSelector(onMainThread: #selector(detectFace(_:)), with: self.crop(image: image, ratio: 1), waitUntilDone: true)
        Thread.sleep(forTimeInterval: 0.5)
    }

    @objc func detectFace(_ image: UIImage) {
        
        guard let cgImage = image.cgImage else { return }
        let ciImage = CIImage(cgImage: cgImage)
        let context = CIContext()
        let detector = CIDetector(ofType: CIDetectorTypeFace, context: context, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh, CIDetectorEyeBlink: true])
        
        var exifOrientation: Int = 1
        switch image.imageOrientation {
        case .up:
            exifOrientation = 1
        case .upMirrored:
            exifOrientation = 2
        case .down:
            exifOrientation = 3
        case .downMirrored:
            exifOrientation = 4
        case .leftMirrored:
            exifOrientation = 5
        case .right:
            exifOrientation = 6
        case .rightMirrored:
            exifOrientation = 7
        case .left:
            exifOrientation = 8
        default:
            break
        }
        
        guard let features = detector?.features(in: ciImage, options: [CIDetectorImageOrientation: exifOrientation, CIDetectorAccuracy: CIDetectorAccuracyHigh, CIDetectorEyeBlink: true]) as? [CIFaceFeature] else { return }

        guard let faceObject = features.first else {
            if self.countDown != 0 && self.countDown != 100 {
                self.resetData()
            }
            return
        }
        
        if faceObject.hasMouthPosition && faceObject.hasLeftEyePosition && faceObject.hasRightEyePosition && !faceObject.leftEyeClosed && !faceObject.rightEyeClosed {
            
            self.faceImages.append(image)
            
            // CIDetector start detect
            if self.isDetecting == false && self.countDown == 0 {

                self.isDetecting = true
                gcdTimer = DispatchSource.makeTimerSource()
                gcdTimer?.schedule(wallDeadline: DispatchWallTime.now(), repeating: DispatchTimeInterval.milliseconds(25), leeway: DispatchTimeInterval.milliseconds(0))
                gcdTimer?.setEventHandler {
                    DispatchQueue.main.async {
                        self.countDown += 1
                    }
                }
                gcdTimer?.resume()
                
            }
            // CIDetector detect complete
            else if self.isDetecting == true && self.countDown == 100 {
                self.isDetecting = false
                var photoAUrl: String?
                var photoBUrl: String?
                // bind
                
                loading.startAnimating()
                self.tipLabel.text = "正在识别中,请稍候"
                var uploadSuccess: Bool = false
                let dispatchGroup = DispatchGroup()

                if self.needBindingFace == true {

                    dispatchGroup.enter()
                    dispatchGroup.enter()
                    AuthClient().uploadFaceImage(self.faceImages.first ?? UIImage()) { code, key in
                        dispatchGroup.leave()
                        uploadSuccess = code == 200 ? true : false
                        photoAUrl = key
                    }
                     AuthClient().uploadFaceImage(self.faceImages.last ?? UIImage()) { code, key in
                         dispatchGroup.leave()
                        uploadSuccess = code == 200 ? true : false
                        photoBUrl = key
                    }
                    dispatchGroup.notify(queue: DispatchQueue.main) { [weak self] in
                        if uploadSuccess == true {
                            AuthClient().mfaAssociateByFace(photoA: photoAUrl ?? "", photoB: photoBUrl ?? "") { code, msg, userInfo in
                                DispatchQueue.main.async() {
                                    self?.loading.stopAnimating()
                                    if code == 200{
                                        self?.tipLabel.text = "绑定成功"
                                    
                                        if let vc = self?.navigationController as? AuthNavigationController {
                                            self?.session.stopRunning()
                                            vc.complete(code, msg, userInfo)
                                        }
                                    } else {
                                        self?.tipLabel.text = "绑定人脸失败, 请重试"
                                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                                            self?.resetData()
                                        }
                                    }
                                }
                            }
                        } else {
                            self?.loading.stopAnimating()
                            self?.tipLabel.text = "绑定人脸失败, 请重试"
                            self?.resetData()
                        }
                    }
                }
                // verify
                else {
                    dispatchGroup.enter()
                    AuthClient().uploadFaceImage(self.faceImages.last ?? UIImage()) { code, key in
                        dispatchGroup.leave()
                        uploadSuccess = code == 200 ? true : false
                        photoAUrl = key
                    }
                    
                    dispatchGroup.notify(queue: DispatchQueue.main) { [weak self] in
                        if uploadSuccess == true {
                            AuthClient().mfaVerifyByFace(photo: photoAUrl ?? "") { code, msg, userInfo in
                                DispatchQueue.main.async() {
                                    self?.loading.stopAnimating()
                                    if code == 200{
                                        self?.tipLabel.text = "识别成功"
                                    
                                        if let vc = self?.navigationController as? AuthNavigationController {
                                            self?.session.stopRunning()
                                            vc.complete(code, msg, userInfo)
                                        }
                                    } else {
                                        self?.tipLabel.text = "识别人脸失败, 请重试"
                                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                                            self?.resetData()
                                        }
                                    }
                                }
                            }
                        } else {
                            self?.loading.stopAnimating()
                            self?.tipLabel.text = "识别人脸失败, 请重试"
                            self?.resetData()
                        }
                    }

                }
            }
            // CIDetector loading
            else {
            }
            
        } else {
        }
    }
    
    private func resetData(){
        self.isDetecting = false
        self.countDown = 0
        self.faceImages = []
    }
    
    func crop(image: UIImage, ratio: CGFloat) -> UIImage {
        var newSize:CGSize!
        if image.size.width/image.size.height > ratio {
            newSize = CGSize(width: image.size.height * ratio, height: image.size.height)
        }else{
            newSize = CGSize(width: image.size.width, height: image.size.width / ratio)
        }
     
        var rect = CGRect.zero
        rect.size.width  = image.size.width
        rect.size.height = image.size.height
        rect.origin.x    = (newSize.width - image.size.width ) / 2.0
        rect.origin.y    = (newSize.height - image.size.height ) / 2.0
         
        UIGraphicsBeginImageContext(newSize)
        image.draw(in: rect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
         
        return scaledImage!
    }
}

class CircleProgressView: UIView {
    var staticLayer: CAShapeLayer!
    var arcLayer: CAShapeLayer!
    
    var progress = 100

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setProgress(_ progress: Int) {
        self.progress = progress
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        if staticLayer == nil {
            staticLayer = createLayer(100, .lightGray)
        }
        self.layer.addSublayer(staticLayer)
        if arcLayer != nil {
            arcLayer.removeFromSuperlayer()
        }
        arcLayer = createLayer(self.progress, Const.Color_Authing_Main)
        self.layer.addSublayer(arcLayer)
    }
    
    private func createLayer (_ progress: Int, _ color: UIColor) -> CAShapeLayer {
        let endAngle = -CGFloat.pi / 2 + (CGFloat.pi * 2) * CGFloat(progress) / 100
        let layer = CAShapeLayer()
        layer.lineWidth = 5
        layer.strokeColor = color.cgColor
        layer.fillColor = UIColor.clear.cgColor
        let radius = self.bounds.width / 2 - layer.lineWidth
        let path = UIBezierPath.init(arcCenter: CGPoint(x: bounds.width / 2, y: bounds.height / 2), radius: radius, startAngle: -CGFloat.pi / 2, endAngle: endAngle, clockwise: true)
        layer.path = path.cgPath
        return layer
    }

}