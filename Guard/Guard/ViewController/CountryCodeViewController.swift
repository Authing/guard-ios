//
//  CountryCodeViewController.swift
//  Guard
//
//  Created by JnMars on 2022/3/26.
//

struct CountryItemModel {
    var country: String?
    var code: String?
    
    init(data: NSDictionary) {

        code = data["code"] as? String
        country = data["country"] as? String
    }
}

typealias SelectCountryCallBack = (_ country: CountryItemModel) -> Void

class CountryCodeViewController: AuthViewController {
    
    private var sortedNameDict = Dictionary<String, NSArray>()
    var selectCountryCallBack: SelectCountryCallBack?
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var countryCodeView: UITableView!
    var searchController = UISearchController()
    var searchResultValuesArray = NSMutableArray()
    var searchResultValuesCode = NSMutableArray()
    var cellHeight: CGFloat = 50
    var indexArray = Array<String>()
    var indexSectionArray = Array<String>()

    override func viewDidLoad() {
        super.viewDidLoad()
    
        sortedNameDict = loadPlist()
        let arr = sortedNameDict.keys.sorted(){ $0 < $1 }
        indexArray = Array(arr)
        for index in indexArray {
            indexSectionArray.append(index)
            indexSectionArray.append("")
        }
        
        self.view.backgroundColor = UIColor.white
        titleLabel.text = "authing_countrycode_title".L
        
        countryCodeView.delegate = self
        countryCodeView.dataSource = self
        countryCodeView.rowHeight = 44
        countryCodeView.register(CountryTableViewCell.self, forCellReuseIdentifier: "Cell")
        countryCodeView.sectionIndexColor = UIColor.init(hex: "#4E5969")
        if #available(iOS 15.0, *) {
            countryCodeView.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
        
        searchResultValuesArray = NSMutableArray()
        //searchController
        searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.backgroundColor = UIColor.white
        //searchController.searchBar.autocapitalizationType = .none
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.placeholder = "authing_country_title".L
        searchController.searchBar.setImage(UIImage.init(named: "authing_search"), for: UISearchBar.Icon.search, state: .normal)
        searchController.view.frame = CGRect(x: 24, y: 0, width: 300, height: 30)
        if let textfield = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            let atrString = NSAttributedString(string: "authing_country_title".L,
                                               attributes: [.foregroundColor: UIColor.init(hex: "#86909C"),
                                                .font : UIFont.systemFont(ofSize: 14)])
            textfield.attributedPlaceholder = atrString
        }
        if #available(iOS 13.0, *) {
            self.searchController.searchBar.searchTextField.backgroundColor = UIColor.init(hex: "#F7F8FA")
        } else {
            // Fallback on earlier versions
        }
        countryCodeView.tableHeaderView = self.searchController.searchBar
    }
    
    @IBAction func dismissButtonAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    private func loadPlist() -> Dictionary<String, NSArray> {
        let plistPathCh = Bundle(for: type(of: self)).path(forResource: Util.getLangHeader().contains("zh") ? "country" : "country_en", ofType: "plist")
        let dic = NSDictionary(contentsOfFile: plistPathCh!) as! [String : NSArray]
        
        return dic
    }
    
    deinit {
        print("deinit")
    }
}

extension CountryCodeViewController: UISearchBarDelegate,UISearchControllerDelegate,UISearchResultsUpdating {
   
    func updateSearchResults(for searchController: UISearchController) {
        searchResultValuesCode.removeAllObjects()
        searchResultValuesArray.removeAllObjects()
        for array in sortedNameDict.values{
            
            let arr = array.value(forKey: "country") as! Array<String>
            let arrCode = array.value(forKey: "code") as! Array<String>
            
            let Interval = 1
            for i in stride(from: 0, to: arr.count, by: Interval) {
                let val = arr[i]
                if (val.range(of: searchController.searchBar.text!) != nil){
                    searchResultValuesArray.add(val)
                    searchResultValuesCode.add(arrCode[i])
                }
            }
        }
        self.countryCodeView.reloadData()
    }

    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
}

extension CountryCodeViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        if self.searchController.isActive {
            return 1
        }
        return sortedNameDict.keys.count
    }
    //the row in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchController.isActive {
            return searchResultValuesArray.count
        }
        return sortedNameDict[indexArray[section]]!.count
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return indexSectionArray
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index / 2
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.searchController.isActive {
            return 0
        }
        return 30
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.white
        let label = UILabel.init(frame: CGRect(x: 24, y: 0, width: 100, height: 30))
        label.text = indexArray[section]
        label.textColor = UIColor.init(hex: "#A9AEB8")
        label.font = UIFont.systemFont(ofSize: 12)
        view.addSubview(label)
        return view
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if  self.searchController.isActive  {
            let cell: CountryTableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CountryTableViewCell
           
            let index = indexPath.row
            if searchResultValuesArray.count > 0 {
                let country = searchResultValuesArray[index]
                let code = searchResultValuesCode[index]
                let model = CountryItemModel.init(data: ["country":country,"code":code])
                cell.setContent(model: model)
            }
            return cell
        }
        
        let cell: CountryTableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CountryTableViewCell
        if let model = sortedNameDict[indexArray[indexPath.section]]?[indexPath.row] as? NSDictionary {
            cell.setContent(model: CountryItemModel.init(data: model))
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if self.searchController.isActive  {
            let country = searchResultValuesArray[indexPath.row]
            let code = searchResultValuesCode[indexPath.row]
            let model = CountryItemModel.init(data: ["country":country,"code":code])
            self.selectCountryCallBack?(model)
            self.searchController.isActive = false
            self.dismiss(animated: true)
            return
        }
        
        if let model = sortedNameDict[indexArray[indexPath.section]]?[indexPath.row] as? NSDictionary {
            self.selectCountryCallBack?(CountryItemModel.init(data: model))
            self.dismiss(animated: true)
        }
    }

}

class CountryTableViewCell: UITableViewCell {
    
    let itemHeight: CGFloat = 44
        
    private lazy var countryName: UILabel = {
        var label = UILabel.init(frame: CGRect(x: 24, y: 0, width: itemHeight * 5, height: itemHeight))
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.init(hex: "#282D3C")
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()

    private lazy var phoneCode: UILabel = {
        var label = UILabel.init(frame: CGRect(x: Const.SCREEN_WIDTH - itemHeight - 24, y: 5, width: itemHeight, height: itemHeight))
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.init(hex: "#282D3C")
        label.textAlignment = .right
        return label
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        self.setupUI()
    }
    
    func setupUI() {
        self.contentView.addSubview(countryName)
        self.contentView.addSubview(phoneCode)
    }
    
    func setContent(model: CountryItemModel) {
        countryName.text = model.country
        if let code = model.code {
            phoneCode.text = "+\(code)"
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
