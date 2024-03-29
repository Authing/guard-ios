//
//  MFAFaceViewController.swift
//  Guard
//
//  Created by JnMars on 2022/6/28.
//

import AVFoundation

@objc open class MFAFaceViewController: AuthViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    private var needBindingFace: Bool = !(Authing.getCurrentUser()?.faceMfaEnabled ?? false)
    private var faceImages: [UIImage] = []
    private var isDetecting: Bool = false
    
    var gcdTimer: DispatchSourceTimer?

    lazy var queue: DispatchQueue = {
        let q = DispatchQueue(label: "cameraQueue")
        return q
    }()
        
    private var countDown: Int = 0{
        didSet {
            self.progress.setProgress(CGFloat(countDown)/100.0)
            if countDown == 0 {
                self.faceImages = []
                self.gcdTimer?.cancel()
                self.tipLabel.text = "authing_mfa_face_camera".L
            } else if countDown == 100{
                self.gcdTimer?.cancel()
            } else {
                self.tipLabel.text = "authing_mfa_face_camera2".L
            }
        }
    }
        
    private let loading = UIActivityIndicatorView()

    lazy var tipLabel: UILabel = {
        let b = UILabel()
        b.textColor = .black
        b.textAlignment = .center
        b.text =  "authing_mfa_face_camera".L
        b.font = .systemFont(ofSize: 24, weight: .bold)
        return b
    }()
    
    lazy var progress: CircleProgressView = {
        let p = CircleProgressView.init(frame: CGRect(x: Const.SCREEN_WIDTH/2 - 122.5, y: Const.SCREEN_HEIGHT/2 - 245, width: 245, height: 245))
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
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.needBindingFace == true ? "authing_mfa_face_title".L : "authing_mfa_face_title2".L

        view.backgroundColor = UIColor.white
        preview.frame = CGRect(x: Const.SCREEN_WIDTH/2 - 120, y: Const.SCREEN_HEIGHT/2 - 240, width: 240, height: 240)
        view.layer.addSublayer(preview)
        
        view.addSubview(progress)
                
        tipLabel.frame = CGRect(x: 0, y: 120, width: Const.SCREEN_WIDTH, height: 50)
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
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    deinit {
    }

}

extension MFAFaceViewController {
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
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
        Thread.sleep(forTimeInterval: 0.25)
    }

    @objc public func detectFace(_ image: UIImage) {
        
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
            
            self.verifyFace()
            
        } else {
        }
    }
    
    public func verifyFace() {
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
            var uploadSuccess: Bool = false
            let dispatchGroup = DispatchGroup()
            let dispathcQueue = DispatchQueue.global()
            if self.needBindingFace == true {
                self.tipLabel.text = "authing_mfa_binding".L

                dispatchGroup.enter()
                dispathcQueue.async{
                    AuthClient().uploadFaceImage(self.faceImages.first ?? UIImage()) { code, key in
                        dispatchGroup.leave()
                        uploadSuccess = code == 200 ? true : false
                        photoAUrl = key
                    }
                }
                dispatchGroup.enter()
                dispathcQueue.async{
                     AuthClient().uploadFaceImage(self.faceImages.last ?? UIImage()) { code, key in
                         dispatchGroup.leave()
                        uploadSuccess = code == 200 ? true : false
                        photoBUrl = key
                    }
                }
                dispatchGroup.notify(queue: DispatchQueue.main) { [weak self] in
                    if uploadSuccess == true {
                        AuthClient().mfaAssociateByFace(photoKeyA: photoAUrl ?? "", photoKeyB: photoBUrl ?? "") { code, msg, userInfo in
                            DispatchQueue.main.async() {
                                self?.loading.stopAnimating()
                                if code == 200{
                                    self?.tipLabel.text = "authing_mfa_bind_success".L
                                
                                    if (self?.authFlow) != nil {
                                        self?.session.stopRunning()
                                        self?.pushToBindSuccessViewController()
                                    }
                                } else {
                                    self?.tipLabel.text = msg
                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                                        self?.resetData()
                                    }
                                }
                            }
                        }
                    } else {
                        self?.loading.stopAnimating()
                        self?.tipLabel.text = "authing_mfa_bind_failed".L
                        self?.resetData()
                    }
                }
            }
            // verify
            else {
                self.tipLabel.text = "authing_mfa_verifying".L

                dispatchGroup.enter()
                dispathcQueue.async{
                    AuthClient().uploadFaceImage(self.faceImages.last ?? UIImage()) { code, key in
                        dispatchGroup.leave()
                        uploadSuccess = code == 200 ? true : false
                        photoAUrl = key
                    }
                }
                
                dispatchGroup.notify(queue: DispatchQueue.main) { [weak self] in
                    if uploadSuccess == true {
                        AuthClient().mfaVerifyByFace(photoKey: photoAUrl ?? "") { code, msg, userInfo in
                            DispatchQueue.main.async() {
                                self?.loading.stopAnimating()
                                if code == 200{
                                    self?.tipLabel.text = "authing_mfa_verify_success".L
                                
                                    if let flow = self?.authFlow {
                                        self?.session.stopRunning()
                                        flow.complete(code, msg, userInfo)
                                    }
                                } else {
                                    self?.tipLabel.text = msg
                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                                        self?.resetData()
                                    }
                                }
                            }
                        }
                    } else {
                        self?.loading.stopAnimating()
                        self?.tipLabel.text = "authing_mfa_verify_failed".L
                        self?.resetData()
                    }
                }

            }
        }
        else {
        }
    }
    
    private func resetData(){
        self.isDetecting = false
        self.countDown = 0
        self.faceImages = []
    }
    
    private func pushToBindSuccessViewController(){
        
        let nextVC = MFABindSuccessViewController(nibName: "AuthingMFABindSuccess", bundle: Bundle(for: Self.self))
        nextVC.type = .face
        nextVC.authFlow = self.authFlow?.copy() as? AuthFlow
        self.navigationController?.pushViewController(nextVC, animated: true)
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
    var shapeLayer: CAShapeLayer!
    
    var progress: CGFloat = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        shapeLayer = CAShapeLayer()
        shapeLayer.strokeEnd = 0
        shapeLayer.lineWidth = 5
        shapeLayer.strokeColor = Const.Color_Authing_Main.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        let radius = self.bounds.width / 2 - shapeLayer.lineWidth
        let circularPath = UIBezierPath.init(arcCenter: CGPoint(x: bounds.width / 2, y: bounds.height / 2), radius: radius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)

        shapeLayer.path = circularPath.cgPath
        self.layer.addSublayer(shapeLayer)
    }
    
    func setProgress(_ progress: CGFloat) {
        self.progress = progress
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        DispatchQueue.main.async {
            self.shapeLayer.strokeEnd = self.progress
        }
    }

}
