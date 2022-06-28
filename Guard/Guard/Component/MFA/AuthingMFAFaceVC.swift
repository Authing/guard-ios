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

    var popClosure: (() -> Void)?
    
    private var isPop: Bool = false
    lazy var queue: DispatchQueue = {
        let q = DispatchQueue(label: "cameraQueue")
        return q
    }()
    
    var countDown: Int = 5
    let gcdTimer = DispatchSource.makeTimerSource()
    
    // UI
    private var faceView = UIView()

    private func letgo() {
//        isPop = true
//        self.session.stopRunning()
//        self.gcdTimer.cancel()
//        self.popClosure?()
//        self.popViewController()
    }
    
    lazy var tipTime: UILabel = {
        let b = UILabel()
        b.backgroundColor = UIColor.red
        b.layer.cornerRadius = 25
        b.layer.opacity = 0.2
        b.textColor = .white
        b.text = "\(countDown)"
        b.textAlignment = .center
        b.font = .systemFont(ofSize: 24, weight: .bold)
//        b.setTitle("3", for: .normal)
        
        return b
    }()
    
    // AVFoundation
    lazy var preview: AVCaptureVideoPreviewLayer = {
        let p = AVCaptureVideoPreviewLayer(session: session)
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
        preview.frame = CGRect(x: UIScreen.main.bounds.width/2 - 100, y: UIScreen.main.bounds.height/2 - 100, width: 200, height: 200)
        self.view.layer.addSublayer(preview)
        session.startRunning()
        view.addSubview(tipTime)
        tipTime.frame = CGRect(x: UIScreen.main.bounds.width/2 - 25, y: 120, width: 50, height: 50)
        
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimation.values = [0.5, 0.3, 0.2]
        opacityAnimation.duration = 1
        opacityAnimation.repeatCount = Float(self.countDown)
        opacityAnimation.isRemovedOnCompletion = true
        opacityAnimation.fillMode = .forwards
        tipTime.layer.add(opacityAnimation, forKey: "groupAnimation")
        
        gcdTimer.schedule(wallDeadline: DispatchWallTime.now(), repeating: DispatchTimeInterval.seconds(1), leeway: DispatchTimeInterval.seconds(0))

        gcdTimer.setEventHandler {
            DispatchQueue.main.async {
                self.countDown -= 1
                self.tipTime.text = "\(self.countDown)"
            }
        }
        gcdTimer.resume()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 10) {
            if !self.isPop {
                self.letgo()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    deinit {
        print("==============deinit")
//        gcdTimer.cancel()
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
        Thread.sleep(forTimeInterval: 1)
    }
    @objc func save(image:UIImage, didFinishSavingWithError:NSError?,contextInfo:AnyObject) {
         
         if didFinishSavingWithError != nil {

         } else {
             
         }
     }
    
    @objc func detectFace(_ image: UIImage) {
        
        faceView.removeFromSuperview()

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
        
        // options要在这里设置，在detector初始化的地方设置无效
        guard let features = detector?.features(in: ciImage, options: [CIDetectorImageOrientation: exifOrientation, CIDetectorAccuracy: CIDetectorAccuracyHigh, CIDetectorEyeBlink: true]) as? [CIFaceFeature] else { return }
        // 只取第一张人脸
        guard let faceObject = features.first else { return }
        
        let widthScale =  UIScreen.main.bounds.width / image.size.width

        faceView = UIView.init(frame: CGRect(x: 0, y: 0, width: faceObject.bounds.width * widthScale, height: faceObject.bounds.height * widthScale))
        faceView.center = self.view.center
        faceView.layer.borderColor = UIColor.red.cgColor
        faceView.layer.borderWidth = 1
        self.view.addSubview(faceView)

        
        if faceObject.hasMouthPosition && faceObject.hasLeftEyePosition && faceObject.hasRightEyePosition && !faceObject.leftEyeClosed && !faceObject.rightEyeClosed {
           
            print("识别到人脸坐标",faceObject.bounds)
            print("左眼坐标:",faceObject.leftEyePosition)
            print("右眼坐标:",faceObject.rightEyePosition)
            print("嘴巴坐标:",faceObject.mouthPosition)
            
//            AuthClient().uploadImage(image, false) { code, msg in
//                print(code)
//                print(msg)
//            }
//
//            self.letgo()
            
        }
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
