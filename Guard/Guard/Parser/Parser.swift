//
//  Parser.swift
//  Guard
//
//  Created by Lance Mao on 2022/3/15.
//

import UIKit

open class Parser: NSObject, XMLParserDelegate {
    
    var viewStack: Array<UIView> = Array()
    var currentView: UIView? = nil
    
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
                    parseManifest(appBundle, rootDirInMain.appendingPathComponent("manifest.json"))
                    
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
                parseManifest(appBundle, rootDir.appendingPathComponent("manifest.json"))
                let root = RootView()
                root.backgroundColor = UIColor.white
                viewStack.append(root)
                currentView = root
                appBundle.indexView = root
                appBundle.rootDir = rootDir
                let indexViewPath = rootDir.appendingPathComponent("page").appendingPathComponent("index.xml")
                if let parser = XMLParser(contentsOf: indexViewPath) {
                    parser.delegate = self
                    parser.parse()
                }
                root.addSubview(CloseButton())
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
    
    private func parseManifest(_ appBundle: AppBundle, _ fileURL: URL) {
        if let data = try? Data(contentsOf: fileURL) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary {
                    if let version = json["version"] as? String {
                        appBundle.versionName = version
                    }
                    if let name = json["name"] as? String {
                        appBundle.name = name
                    }
                }
            } catch {
                ALog.e(Parser.self, "parseManifest error")
            }
        } else {
            ALog.e(Parser.self, "parseManifest error file not exist \(fileURL.path)")
        }
    }
    
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {

        if let viewType = Bundle(for: Parser.self).classNamed("Guard.\(elementName)") as? UIView.Type {
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
        }
    }

    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        viewStack.removeLast()
        if let view = viewStack.last {
            currentView = view
        }
    }
    
    private func parseAttribute(view: UIView, key: String, value: String) {
        if ("background" == key) {
            if let color = Util.parseColor(value) {
                view.backgroundColor = color
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
            } else if ("fill" == value) {
                view.layoutParams.fill = 1
            } else if ("wrap" == value) {
                view.layoutParams.height = LayoutParams.wrapContent
            } else {
                let v = CGFloat((value as NSString).floatValue)
                view.frame = CGRect(origin: view.frame.origin, size: CGSize(width: view.frame.width, height: v))
                view.layoutParams.height = v
            }
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
            if let color = Util.parseColor(value) {
                view.layer.borderColor = color.cgColor
            }
        } else if ("border-corner" == key) {
            let v = CGFloat((value as NSString).floatValue)
            view.layer.cornerRadius = v
            view.layer.masksToBounds = true
        } else if "color" == key, let color = Util.parseColor(value) {
            if let v = view as? UIButton {
                v.titleLabel?.textColor = color
                v.setTitleColor(color, for: .normal)
                v.setTitleColor(color, for: .disabled)
            } else if let v = view as? UILabel {
                v.textColor = color
            } else if let v = view as? UITextField {
                v.textColor = color
            }
        } else if "hint-color" == key, let color = Util.parseColor(value) {
            if let v = view as? BaseInput {
                v.hintColor = color
            }
        } else {
            if let v = view as? AttributedViewProtocol {
                v.setAttribute(key: key, value: value)
            }
        }
    }
}
