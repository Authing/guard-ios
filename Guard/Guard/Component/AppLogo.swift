//
//  AppLogo.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/13.
//

open class AppLogo: ImageView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        Util.getConfig(self) { config in
            
            guard let appid = config?.appId else {
                return
            }
            
            if let image = CacheManager.getImage(appid) {
                self.image = image
            }
            
            if let logoUrl = config?.getLogoUrl(),
               let url = URL(string: logoUrl) {
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url as URL),
                       let image = UIImage(data: data) {
                        CacheManager.putImage(appid, image)
                        DispatchQueue.main.async() { [weak self] in
                            self?.image = image
                        }
                    }
                }
            }
        }
    }
}
