//
//  Parser.swift
//  Guard
//
//  Created by Lance Mao on 2022/3/15.
//

import UIKit

open class Parser: NSObject, XMLParserDelegate {
    
    var appBundle: AppBundle?
    var viewStack: Array<UIView> = Array()
    var currentView: UIView?
    
    public init(_ appBundle: AppBundle? = nil) {
        self.appBundle = appBundle
    }
    
    open func parse(appId: String) -> AppBundle? {
        do {
            let documentRootDir = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)

            let appBundle = AppBundle()
            appBundle.appId = appId
            let appDir = documentRootDir.appendingPathComponent("authing").appendingPathComponent("apps").appendingPathComponent(appId)
            if !FileManager.default.fileExists(atPath: appDir.path) {
                let rootDirInMain = Bundle.main.resourceURL!.appendingPathComponent(appId)
                if !FileManager.default.fileExists(atPath: rootDirInMain.path) {
                    ALog.e(Parser.self, "no app bundle found for \(appId)")
                    return nil
                } else {
                    // parse manifest to get version
                    parseManifest(appBundle)
                    
                    // create root folder
                    try FileManager.default.createDirectory(at: appDir, withIntermediateDirectories: true, attributes: nil)
                    
                    // copy to document/authing/apps/{appId}/{version}
                    let destPath = appDir.appendingPathComponent(String(appBundle.versionCode))
                    try FileManager.default.copyItem(at: rootDirInMain, to: destPath)
                }
            } else {
                ALog.i(Parser.self, "loading app bundle from document for \(appId)")
                
                // sub directory names are numbers, the highest is current version code
                // if everything is normal, there should be only one folder
                let files = try FileManager.default.contentsOfDirectory(at: appDir, includingPropertiesForKeys: nil)
                if files.count == 0 {
                    ALog.e(Parser.self, "corrupted directory for \(appId)")
                } else {
                    var versionArray: [Int] = []
                    for file in files {
                        let version = file.lastPathComponent as NSString
                        versionArray.append(Int(version.intValue))
                    }
                    versionArray.sort()
                    if let version = versionArray.last {
                        appBundle.versionCode = version
                    } else {
                        ALog.e(Parser.self, "corrupted directory for \(appId)")
                    }
                }
            }
            
            let rootDir = appDir.appendingPathComponent(String(appBundle.versionCode))
            if FileManager.default.fileExists(atPath: rootDir.path) {
                appBundle.rootDir = rootDir
                parseManifest(appBundle)
                ALog.i(Parser.self, "app bundle \(appId) loaded. path: \(rootDir)")
                return appBundle
            } else {
                ALog.e(Parser.self, "unexpected error happen when parsing \(appId)")
                return nil
            }
        } catch {
            ALog.e(Parser.self, error.localizedDescription)
            return nil
        }
    }
    
    public func parseManifest(_ appBundle: AppBundle) {
        if let fileURL = appBundle.rootDir?.appendingPathComponent("manifest.json"),
           let data = try? Data(contentsOf: fileURL) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary {
                    if let version = json["version"] as? String {
                        appBundle.versionName = version
                    }
                    if let name = json["name"] as? String {
                        appBundle.name = name
                    }
                    if let mainColor = json["mainColor"] as? String {
                        appBundle.mainColor = mainColor
                    }
                }
            } catch {
                ALog.e(Parser.self, "parseManifest error")
            }
        } else {
            ALog.e(Parser.self, "parseManifest error file not exist")
        }
    }
    
    open func inflate(appBundle: AppBundle) {
        appBundle.indexView = inflate(appBundle: appBundle, page: "index.xml")
    }
    
    open func inflate(appBundle: AppBundle, page: String) -> RootView {
        self.appBundle = appBundle
        let root = RootView()
        root.backgroundColor = UIColor.white
        viewStack.append(root)
        currentView = root
        if let indexViewPath = appBundle.rootDir?.appendingPathComponent("page").appendingPathComponent(page) {
            if let parser = XMLParser(contentsOf: indexViewPath) {
                parser.delegate = self
                parser.parse()
            }
        }
        if root.subviews.count == 0 {
            ALog.e(Self.self, "inflate failed. no view in \(page)")
        }
        if "index.xml" == page {
            root.addSubview(CloseButton())
        }
        return root
    }
    
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {

        if let viewType = Bundle(for: Self.self).classNamed("Guard.\(elementName)") as? UIView.Type {
            let view = viewType.init()
            
            if let layout = view as? Layout {
                layout.activated = true
            }

            for (key, value) in attributeDict {
                parseAttribute(view: view, key: key, value: value)
            }

            currentView?.addSubview(view)
            
            viewStack.append(view)
            currentView = view
        } else {
            ALog.e(Self.self, "cannot parse \(elementName)")
        }
    }

    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        viewStack.removeLast()
        if let view = viewStack.last {
            currentView = view
        }
    }
    
    public func parseAttribute(view: UIView, key: String, value: String) {
        if ("background" == key) {
            if let color = Util.parseColor(appBundle, value) {
                view.backgroundColor = color
            }
            if value.hasPrefix("@") {
                view.extendedProperty.setValue(value, forKey: key)
            }
        } else if ("width" == key) {
            if ("match" == value) {
                view.layoutParams.width = LayoutParams.matchParent
            } else if ("wrap" == value) {
                view.layoutParams.width = LayoutParams.wrapContent
            } else if ("fill" == value) {
                view.layoutParams.fill = 1
            } else {
                let v = CGFloat((value as NSString).floatValue)
                view.frame = CGRect(origin: view.frame.origin, size: CGSize(width: v, height: view.frame.height))
                view.layoutParams.width = v
            }
        } else if ("height" == key) {
            if ("match" == value) {
                view.layoutParams.height = LayoutParams.matchParent
            } else if ("wrap" == value) {
                view.layoutParams.height = LayoutParams.wrapContent
            } else if ("fill" == value) {
                view.layoutParams.fill = 1
            } else {
                let v = CGFloat((value as NSString).floatValue)
                view.frame = CGRect(origin: view.frame.origin, size: CGSize(width: view.frame.width, height: v))
                view.layoutParams.height = v
            }
        } else if ("flex" == key) {
            let v = CGFloat((value as NSString).floatValue)
            view.layoutParams.fill = v
        } else if ("margin-top" == key) {
            let v = CGFloat((value as NSString).floatValue)
            view.layoutParams.margin.top = v
        } else if ("margin-left" == key) {
            let v = CGFloat((value as NSString).floatValue)
            view.layoutParams.margin.left = v
        } else if ("margin-right" == key) {
            let v = CGFloat((value as NSString).floatValue)
            view.layoutParams.margin.right = v
        } else if ("margin-bottom" == key) {
            let v = CGFloat((value as NSString).floatValue)
            view.layoutParams.margin.bottom = v
        } else if ("border-width" == key) {
            let v = CGFloat((value as NSString).floatValue)
            view.layer.borderWidth = v
            view.layer.masksToBounds = true
        } else if ("border-color" == key) {
            if let color = Util.parseColor(appBundle, value) {
                view.layer.borderColor = color.cgColor
            }
            if value.hasPrefix("@") {
                view.extendedProperty.setValue(value, forKey: key)
            }
        } else if ("border-corner" == key) {
            let v = CGFloat((value as NSString).floatValue)
            view.layer.cornerRadius = v
            view.layer.masksToBounds = true
        } else {
            if let v = view as? AttributedViewProtocol {
                if value.hasPrefix("@") {
                    var ref = value
                    ref.remove(at: ref.startIndex)
                    if "mainColor" == ref {
                        if let color: String = appBundle?.mainColor {
                            v.setAttribute(key: key, value: color)
                        }
                    }
                    view.extendedProperty.setValue(value, forKey: key)
                } else {
                    v.setAttribute(key: key, value: value)
                }
            }
        }
    }
}
