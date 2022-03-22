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
    
    open func parse(appId: String) -> AppBundle {
        let root = RootView()
        root.backgroundColor = UIColor.white
        viewStack.append(root)
        
        currentView = root
        
        let appBundle = AppBundle()
        appBundle.appId = appId
        appBundle.indexView = root
        if let url = Bundle.main.resourceURL {
            let rootDir = url.appendingPathComponent(appId)
            appBundle.rootDir = rootDir
            let indexViewPath = rootDir.appendingPathComponent("page").appendingPathComponent("index.xml")
            if let parser = XMLParser(contentsOf: indexViewPath) {
                parser.delegate = self
                parser.parse()
            }
        }
        return appBundle
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
        }  else if ("margin-right" == key) {
            let v = CGFloat((value as NSString).floatValue)
            view.layoutParams.margin.right = v
        }  else if ("margin-bottom" == key) {
            let v = CGFloat((value as NSString).floatValue)
            view.layoutParams.margin.bottom = v
        } else {
            if let v = view as? AttributedViewProtocol {
                v.setAttribute(key: key, value: value)
            }
        }
    }
}
