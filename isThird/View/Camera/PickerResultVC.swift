
import UIKit
import Photos
import RxSwift
import RxCocoa

class PickerResultVC: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var explainText: UILabel!
    var originImg : UIImage?
    var originImgViewFrame : CGRect?
    let rightBtn = UIBarButtonItem(title: "저장", style:  .plain, target: self, action: nil)
    let bag = DisposeBag()
}

extension PickerResultVC{

    func pageInit(){
        explainText.layer.zPosition = -1 //설명영역은 ImageView가 생성이후 뒤로 가게한다.
    }
    
    func bind(){
        rightBtn.rx.tap
            .subscribe(onNext : { _ in
                print("Right Btn is Click")
                self.savePhoto()
            })
            .disposed(by: bag)
    }
}

extension PickerResultVC{
    func savePhoto(){
        if let image = self.imageView.image{
            PHPhotoLibrary.requestAuthorization { _ in
                print("권한요청")
            }
            
            switch PHPhotoLibrary.authorizationStatus(){
            case.authorized:
                print("Save Photo authorized")
                
                UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)//앨범에 파일저장
            case.denied:
                print("Permmision Denied")
            default:
                print("Default is Called")
                return
            }
        }
    }
}

//MARK: - LifeCycle
extension PickerResultVC{
    override func viewDidLoad() {
        super.viewDidLoad()
        pageInit()
        bind()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        print("resultView is Appear")
        
        let app = UIApplication.shared.delegate as! AppDelegate
        if let _ = app.originImg{
            imageView.image = app.originImg
        }
        if let _ = app.originImgFrame{
            imageView.frame = app.originImgFrame!
        }
        
        var basicRightBtnItems = navigationController?.navigationBar.topItem?.rightBarButtonItems
        basicRightBtnItems?.append(rightBtn)
        navigationController?.navigationBar.topItem?.rightBarButtonItems = basicRightBtnItems
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem?.tintColor = .black //얘는 왜 안먹지...?
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        print("resultView is DisAppear")
        
        let app = UIApplication.shared.delegate as! AppDelegate
        app.originImg = nil
        imageView.image = nil
        
        var basicRightBtnItems = navigationController?.navigationBar.topItem?.rightBarButtonItems
        if basicRightBtnItems!.contains(rightBtn){
            basicRightBtnItems?.removeAll(where: {$0 == rightBtn})
        }
        navigationController?.navigationBar.topItem?.rightBarButtonItems = basicRightBtnItems
    }
}

