//
//  CameraEditVC.swift
//  isThird
//
//  Created by esmnc1 on 2021/11/08.
//

import UIKit
import TOCropViewController
import ZLImageEditor

class CameraEditVC: UIViewController {

    var originImg : UIImage?
    var originImgViewFrame : CGRect?
}

extension CameraEditVC{
    func pageInit(){
//        presentCropView()
        presentZLView()
    }
    
    func presentCropView(){
        if let _ = originImg{
            let cropVC = TOCropViewController(image: originImg!)
            cropVC.delegate = self
            self.present(cropVC, animated: true, completion: nil)
        }
    }
    
    func presentZLView(){
        if let _ = originImg{
            
            ZLImageEditorConfiguration.default().editImageTools = [.draw, .clip, .imageSticker, .textSticker, .mosaic, .filter]
            ZLEditImageViewController.showEditImageVC(parentVC: self, image: originImg!) { editImg, imgModel in
             
                print("E9mini editImg : \(editImg)")
                print("E9mini imgModel : \(imgModel)")

//                let resultVC  = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "pickerresultVC") as! PickerResultVC
//                resultVC.originImg = editImg
//                resultVC.originImgViewFrame = nil

                
                let app = UIApplication.shared.delegate as! AppDelegate
                app.originImg = editImg
                app.originImgFrame = nil
                
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    func commonMove(currentVC : UIViewController, editImg : UIImage, editFrame : CGRect?){
        let resultVC  = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "pickerresultVC") as! PickerResultVC
        resultVC.originImg = editImg
        resultVC.originImgViewFrame = editFrame
        currentVC.dismiss(animated: true) {
            self.tabBarController?.selectedViewController = resultVC
        }
        
    }
}

//extension CameraEditVC : ZLImageStickerContainerDelegate{
//    var selectImageBlock: ((UIImage) -> Void)? {
//        get {}
//        set(newValue) {}
//    }
//
//    var hideBlock: (() -> Void)? {
//        get {}
//        set(newValue) {}
//    }
//
//    func show(in view: UIView) {
//    }
//}

//MARK: - TOCropViewconTroller
extension CameraEditVC : TOCropViewControllerDelegate{
    func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
        print("did crop")
    }
    func cropViewController(_ cropViewController: TOCropViewController, didCropImageTo cropRect: CGRect, angle: Int) {
        print("did crop2")
    }
    func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
        print("did cancel")
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: - LifeCycle
extension CameraEditVC{
    override func viewDidLoad() {
        super.viewDidLoad()
        pageInit()
    }
}
