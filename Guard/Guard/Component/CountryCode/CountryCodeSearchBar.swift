//
//  CountryCodeSearchBar.swift
//  Guard
//
//  Created by JnMars on 2022/3/29.
//

import Foundation
import UIKit

typealias SearchBarCallBack = (_ searchModels: [CountryItemModel]) -> Void

open class CountryCodeSearchBar: UIView {
    private var searchBar: UISearchBar!
    private var countryModels: [CountryItemModel] = []
    private var searchModels: [CountryItemModel] = []
    private var language = Util.getLangHeader()

    var searchCallBack: SearchBarCallBack?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        searchBar = UISearchBar.init(frame:  CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        searchBar.delegate = self
        self.addSubview(searchBar)
    }
    
    func setContent(models: [CountryItemModel]) {
        self.countryModels = models
    }
}

extension CountryCodeSearchBar: UISearchBarDelegate {
    
    public func  searchBar(_ searchBar:  UISearchBar, textDidChange searchText:  String) {

        if searchText == "" {
            self.searchModels = self.countryModels
        } else {
            self.searchModels = []
            for model in self.countryModels {
                if let country = language == "zh-CN" ? model.cn : model.en {
                    if country.lowercased().hasPrefix(searchText) {
                        self.searchModels.append(model)
                    }
                }
            }
        }
        
        self.searchCallBack?(self.searchModels)
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
