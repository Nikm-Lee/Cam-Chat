//
//  ChannelVC.swift
//  isThird
//
//  Created by esmnc1 on 2021/11/19.
//

import UIKit
import RxSwift
import RxCocoa
import Then
import SnapKit

class ChannelVC: UIViewController {

    let containView = UIView()
    let tbl = UITableView()
    let tblCell = UITableViewCell()
    
    lazy var superView = self.view.safeAreaLayoutGuide
    
    
}

extension ChannelVC{
    
    func pageInit(){
        
        self.view.addSubview(containView)
        
        containView.snp.makeConstraints { make -> Void in
            make.edges.equalTo(superView).inset(UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
        }
        containView.backgroundColor = .white
        
        self.tblInit()
    }
    private func tblInit(){
        containView.addSubview(tbl)
        tbl.snp.makeConstraints { make in
            make.edges.equalTo(containView)
        }
        tbl.backgroundColor = .gray
        tbl.dataSource = self
        tbl.delegate = self
    }
    private func cellInit(){
        tbl.addSubview(tblCell)
        tblCell.snp.makeConstraints { make in
            make.edges.equalTo(tbl).inset(UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        }
    }
    
}

extension ChannelVC : UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "") as! channelCell
        
        return cell
    }
    
    
}

extension ChannelVC{
    override func viewDidLoad() {
        super.viewDidLoad()
        pageInit()
    }
}

class channelCell : UITableViewCell{
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
