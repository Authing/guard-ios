//
//  CountryCodeTableView.swift
//  Guard
//
//  Created by JnMars on 2022/3/29.
//

import Foundation

open class CountryCodeTableView: UIView {
    
    public var cellHeight: CGFloat = 50
    
    private var modelList: [CountryItemModel] = []

    private var tableview: UITableView!
    
    var selectCallBack: SelectCountryCallBack?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        tableview = UITableView.init(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height), style: UITableView.Style.plain)
        tableview.delegate = self
        tableview.dataSource = self
        tableview.register(CountryTableViewCell.self, forCellReuseIdentifier: "Cell")
        self.addSubview(tableview)
    }
    
    func setContent(models: [CountryItemModel]) {
        modelList = models
        tableview.reloadData()
    }
    
}

extension CountryCodeTableView: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelList.count
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CountryTableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CountryTableViewCell
        cell.setContent(model: modelList[indexPath.row])
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.selectCallBack?(modelList[indexPath.row])
    }
    
}
