//
//  CameraVC.swift
//  isThird
//
//  Created by esmnc1 on 2021/11/05.
//

import UIKit
import RxSwift
import RxCocoa
import TOCropViewController
import AVFoundation
import CoreImage

class CameraVC: UIViewController {

    var photoOutput = AVCapturePhotoOutput()
    var videoOutput = AVCaptureVideoDataOutput()
    var videoInput : AVCaptureDeviceInput? // 데이터 입력장치
    let captureSession = AVCaptureSession() // 연결세션
    let videoDataOutput = AVCaptureDepthDataOutput()
    var authorizationStatus : AVAuthorizationStatus?
    var settingsForMonitoring : AVCapturePhotoSettings?

    let context = CIContext()
    let bag = DisposeBag()
    
    @IBOutlet weak var preImageView: UIImageView!
}

extension CameraVC{
    func pageInit(){
        let rightBtn = UIBarButtonItem(title: "확인", style: .plain, target: self, action: nil)
        
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.topItem?.title = ""

        navigationItem.rightBarButtonItem = rightBtn
    }
    
    func bind(){
        navigationItem.rightBarButtonItem?.rx.tap
            .subscribe(onNext : { _ in
                self.capture()
            })
            .disposed(by: bag)
    }
}

//MARK: - Camera
extension CameraVC{
    func cameraInit(){
        captureSession.sessionPreset = .high
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {return}
        
        var errorMsg = "";
        do{
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            videoInput?.accessibilityFrame = self.preImageView.layer.bounds
            if captureSession.canAddInput(videoInput!){
                captureSession.addInput(videoInput!)
            }else{
                errorMsg += "Video CanNot addInput";
            }
        }catch{
            let alert = UIAlertController(title: "오류", message: errorMsg, preferredStyle: .alert)
            let okBtn = UIAlertAction(title: "확인", style: .default, handler: nil)
            alert.addAction(okBtn)
            self.present(alert, animated: true, completion: nil)
//            let alert()
        }
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String : Int(kCVPixelFormatType_32BGRA)]
        videoOutput.setSampleBufferDelegate(self, queue: .main)
        
        if captureSession.canAddOutput(videoOutput){
            captureSession.addOutput(videoOutput)
        }
        
        photoOutput.isHighResolutionCaptureEnabled = true
        captureSession.addOutput(photoOutput)
    }
    
    func capture(){
        authorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if let authorizationStatusOfCamera = authorizationStatus{
            
            switch authorizationStatus{
            case .authorized :
                settingsForMonitoring = AVCapturePhotoSettings()
                DispatchQueue.main.async {
                    if let photoCaptureSetting = self.settingsForMonitoring{
                        let previewPixelType = photoCaptureSetting.availablePreviewPhotoPixelFormatTypes.first
                        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String : previewPixelType,
                                             kCVPixelBufferWidthKey as String : self.view.frame.width,
                                             kCVPixelBufferHeightKey as  String : self.view.frame.height] as [String : Any]
                        photoCaptureSetting.previewPhotoFormat = previewFormat
                        
                        self.photoOutput.capturePhoto(with: photoCaptureSetting, delegate: self)
                    }
                }
            case .denied :
                print("E9mini Captrue Permission denied")
            default :
                print("E9mini Capture default")
                return
            }
        }
    }
}



//MARK: - CameraDelegate
extension CameraVC :AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate{
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        let camImage = CIImage(cvPixelBuffer: pixelBuffer!).transformed(by: CGAffineTransform(rotationAngle: -(.pi / 2)))
        let outputImage = UIImage(cgImage: self.context.createCGImage(camImage, from: camImage.extent)!)
        
        self.preImageView.image = outputImage
        
//        self.preImageView.image = addWaterMark(outputImage,waterMark);
        self.preImageView.contentMode = .scaleAspectFill
    }
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let image = preImageView.image{
            let editVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "cameraeditVC") as! CameraEditVC
            
            let waterMark = UIImage(named: "petapp_ap_img01")!
//            editVC.originImg = image
            editVC.originImg = addWaterMark(image, waterMark)
            editVC.originImgViewFrame = nil
            
            self.navigationController?.pushViewController(editVC, animated: true)
            
        }
    }
    
    func addWaterMark(_ originImg : UIImage, _ waterMarkImg : UIImage) -> UIImage?{
        /*
          워터마크 구성
            - Image 크기만큼의 View를 생성후 전체를 ImageView로 생성
            - 우측상단에 1/3 크기의 childView를 생성하여 WaterMarkImage와 현재 시각을 찍음
         */
        let imageSize = originImg.size ?? .zero
        let currentView = UIView(frame: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)) //전체를 그릴 View
        // --------------------------------------------------------- //
        let originImgView = UIImageView(image: originImg)
        originImgView.frame = currentView.frame
        currentView.addSubview(originImgView) // 전체사이즈로 imageView적용
        // --------------------------------------------------------- //
        let childView = UIView(frame: CGRect(x: imageSize.width / 11 * 7, y: imageSize.height / 11 , width: imageSize.width / 11 * 3, height: imageSize.height / 11)) // 우측상단의 위치에 1/3크기의 childView 를 생성
        // --------------------------------------------------------- //
        let waterMarkImgView = UIImageView(image: waterMarkImg)
        waterMarkImgView.frame = CGRect(x: 0, y: 0, width: childView.frame.width, height: childView.frame.height / 11 * 7)
        childView.addSubview(waterMarkImgView) //3:1 비율의 이미지를 childView  Frame으로 세팅하여 추가
        // --------------------------------------------------------- //
        let todayFormatter = DateFormatter()
        todayFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let todayDate = todayFormatter.string(from: Date())
        let todayLabel = UILabel(frame: CGRect(x: 0, y: childView.frame.height / 11 * 8, width: childView.frame.width, height: childView.frame.height / 11 * 2))
        
        let fontSize: CGFloat = 20
        let font = UIFont(name:"Noteworthy-Light" , size: fontSize)
        let attributedStr = NSMutableAttributedString(string: todayDate)
        attributedStr.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String), value: font ?? .init(), range: (todayDate as NSString).range(of: todayDate))
        attributedStr.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: (todayDate as NSString).range(of: todayDate))
        todayLabel.attributedText = attributedStr
        todayLabel.numberOfLines = 0
        todayLabel.textAlignment = .center
        todayLabel.text = todayDate
        childView.addSubview(todayLabel) // 현재 시각을 childView 에 추가
        // --------------------------------------------------------- //
        
        childView.transform = CGAffineTransform(rotationAngle: .pi / 6) //30도 회전
        currentView.addSubview(childView)
        // --------------------------------------------------------- //
        UIGraphicsBeginImageContextWithOptions(imageSize
                                               , false
                                               , 1.0)
        guard let currentContext = UIGraphicsGetCurrentContext() else {return nil}
        currentView.layer.render(in: currentContext)
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return result
    }
    
    func addWaterMark2(_ originImg : UIImage, _ addImg : UIImage) -> UIImage{
        let rect = CGRect(x: 0, y: 0, width: originImg.size.width, height: originImg.size.height)
        let drawRect = CGRect(x: (originImg.size.width / 11) * 7, y: originImg.size.height / 11, width: (originImg.size.width / 11) * 3, height: originImg.size.height / 11)
        UIGraphicsBeginImageContextWithOptions(originImg.size, true, 0)
        
        let contexts = UIGraphicsGetCurrentContext()

        contexts!.setFillColor(UIColor.white.cgColor)
        contexts!.fill(rect)

        originImg.draw(in: rect, blendMode: .normal,alpha: 1)
        addImg.draw(in : drawRect, blendMode: .normal, alpha: 1)

       let result = UIGraphicsGetImageFromCurrentImageContext()
       UIGraphicsEndImageContext()

        return result!
    }
    
    func addTodayMark(_ originImg : UIImage) -> UIImage?{
        var result : UIImage?
        
        let imageSize = originImg.size ?? .zero
        UIGraphicsBeginImageContextWithOptions(CGSize(width: imageSize.width, height: imageSize.height)
                                               , false
                                               , 1.0)
        let currentView = UIView(frame: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let currentImage = UIImageView(image: originImg)
        currentImage.frame = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
        currentView.addSubview(currentImage)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let text = formatter.string(from: Date())
        let label = UILabel()
        label.frame = currentView.frame
        let fontSize: CGFloat = 34
        let font = UIFont(name:"Noteworthy-Light" , size: fontSize)
        let attributedStr = NSMutableAttributedString(string: text)
        attributedStr.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String), value: font ?? .init(), range: (text as NSString).range(of: text))
        attributedStr.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: (text as NSString).range(of: text))

        label.attributedText = attributedStr
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = text
        label.center = currentView.center
        currentView.addSubview(label)
        
        guard let currentContext = UIGraphicsGetCurrentContext() else {return nil}
         currentView.layer.render(in: currentContext)
         let img = UIGraphicsGetImageFromCurrentImageContext()
         UIGraphicsEndImageContext()
        return img
    }
}

//MARK: - LifeCycle
extension CameraVC{
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pageInit()
        self.bind()
        self.cameraInit()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if !captureSession.isRunning{
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        if captureSession.isRunning{
            captureSession.stopRunning()
        }
    }
}
