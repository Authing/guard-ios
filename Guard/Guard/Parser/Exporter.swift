//
//  Exporter.swift
//  Guard
//
//  Created by Lance Mao on 2022/3/23.
//


open class Exporter {
    
    public static func exportManifest(_ appBundle: AppBundle) {
        let dic = ["appId": appBundle.appId,
                   "name": appBundle.name,
                   "versionName": appBundle.versionName,
                   "mainColor": appBundle.mainColor]
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(dic) {
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
                
                if let path = appBundle.rootDir?.appendingPathComponent("manifest.json") {
                    do {
                        try jsonString.write(to: path, atomically: true, encoding: .utf8)
                    } catch {
                        ALog.e(Exporter.self, error.localizedDescription)
                    }
                }
            }
        }
    }
    
    public static func exportXML(_ appBundle: AppBundle, _ view: UIView, _ pageName: String) {
        guard view.subviews.count > 0 else {
            ALog.w(Exporter.self, "skip exporting xml. root view has no child")
            return
        }
        
        if let root = view.subviews[0] as? Layout {
            let xml = XMLAsString(root, 0)
            if let path = appBundle.rootDir?.appendingPathComponent("page").appendingPathComponent(pageName) {
                do {
                    try xml.write(to: path, atomically: true, encoding: .utf8)
                } catch {
                    ALog.e(Self.self, error.localizedDescription)
                }
            }
        }
    }
    
    private static func XMLAsString(_ view: UIView, _ level: Int) -> String {
        if let exportable = view as? AttributedViewProtocol {
            let indent = getIndent(level)
            let className = String(describing: type(of: view))
            var res = "\(indent)<\(className)\(exportable.getXMLAttributes())>\n"
            for sub in view.subviews {
                if sub is AttributedViewProtocol {
                    res += XMLAsString(sub, level + 1)
                }
            }
            res += "\(indent)</\(className)>\n"
            return res
        }
        return ""
    }
    
    private static func getIndent(_ level: Int) -> String {
        var res = ""
        var i = 0
        while i < level {
            res += "    "
            i += 1
        }
        return res
    }
}
