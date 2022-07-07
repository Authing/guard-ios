//
//  CountryCodeViewController.swift
//  Guard
//
//  Created by JnMars on 2022/3/26.
//

struct CountryItemModel {
    var cn: String?
    var en: String?
    var code: Int?
    var emoji: String?
    
    init(data: NSDictionary) {
        cn = data["cn"] as? String
        en = data["en"] as? String
        code = data["code"] as? Int
        emoji = data["emoji"] as? String
    }
}

typealias SelectCountryCallBack = (_ country: CountryItemModel) -> Void

class CountryCodeViewController: AuthViewController {
    
    private var countryModels: [CountryItemModel] = []
    var selectCountryCallBack: SelectCountryCallBack?
    @IBOutlet var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        countryModels = readLocalJson()
        
        self.view.backgroundColor = UIColor.white
        titleLabel.text = "authing_countrycode_title".L
        
        if let tableView: CountryCodeTableView = Util.findView(view, viewClass: CountryCodeTableView.self),
           let searchBar: CountryCodeSearchBar = Util.findView(view, viewClass: CountryCodeSearchBar.self) {
            
            tableView.setContent(models: countryModels)
            tableView.selectCallBack = { model in
                self.dismiss(animated: true, completion: nil)
                self.selectCountryCallBack?(model)
            }
            
            searchBar.setContent(models: countryModels)
            searchBar.searchCallBack = { models in
                self.countryModels = models
                tableView.setContent(models: self.countryModels)
            }
        }
    }
    
    @IBAction func dismissButtonAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    private func readLocalJson() -> [CountryItemModel] {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "country", ofType: "json")

        let url = URL(fileURLWithPath: path!)
        do {
            let data = try Data(contentsOf: url)
            let jsonData:Any = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
            let jsonArr = jsonData as! NSArray
            let value = jsonArr.map{ CountryItemModel.init(data: $0 as! NSDictionary) }
            return value
        } catch let error as Error? {
            print("error:\(error ?? "" as! Error)")
            return []
        }
    }
    
    deinit {
        print("deinit")
    }
}

