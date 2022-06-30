

public enum Orientation {
    case vertical
    case horizontal
}

public enum Alignment {
    case none
    case left
    case right
    case center
    case top
    case bottom
    case middle
}

public enum AlignItems {
    case flexStart
    case flexEnd
    case center
}

public struct Edge {
    public var left: CGFloat
    public var right: CGFloat
    public var top: CGFloat
    public var bottom: CGFloat

    public init(_ all: CGFloat) {
        left = all
        right = all
        top = all
        bottom = all
    }

    public init(left: CGFloat = 0, top: CGFloat = 0, right: CGFloat = 0, bottom: CGFloat = 0) {
        self.left = left
        self.top = top
        self.right = right
        self.bottom = bottom
    }

    public init(horizontal: CGFloat = 0, vertical: CGFloat = 0) {
        left = horizontal
        top = vertical
        right = horizontal
        bottom = vertical
    }

    func growSize(_ size: CGSize) -> CGSize {
        let width = max(size.width + left + right, 0)
        let height = max(size.height + top + bottom, 0)
        return CGSize(width: width, height: height)
    }

    func shrinkSize(_ size: CGSize) -> CGSize {
        let width = max(size.width - left - right, 0)
        let height = max(size.height - top - bottom, 0)
        return CGSize(width: width, height: height)
    }

    func growRect(_ rect: CGRect) -> CGRect {
        return CGRect(
            x: rect.origin.x - left,
            y: rect.origin.y - top,
            width: rect.width + left + right,
            height: rect.height + top + bottom
        )
    }

    func shrinkRect(_ rect: CGRect) -> CGRect {
        return CGRect(
            x: rect.origin.x + left,
            y: rect.origin.y + top,
            width: rect.width - left - right,
            height: rect.height - top - bottom
        )
    }
}

public var EdgeZero = Edge(0)

public struct LayoutParams {
    public static let matchParent: CGFloat = -1
    public static let wrapContent: CGFloat = -2

    public var width = wrapContent
    public var height = wrapContent
    public var margin = EdgeZero
    public var minWidth: CGFloat = 0
    public var maxWidth = CGFloat.greatestFiniteMagnitude
    public var minHeight: CGFloat = 0
    public var maxHeight = CGFloat.greatestFiniteMagnitude
    
    public var alignment: Alignment = .none
    public var fill: CGFloat = 0
    
    public var absolute: Bool = false
    public var animatePositionOnce: Bool = false
    public var animateSizeOnce: Bool = false
}

extension UIView {
    private enum Keys {
        static var layoutParamsKey = "layoutParams"
    }

    open var layoutParams: LayoutParams {
        get {
            if let lp = objc_getAssociatedObject(self, &Keys.layoutParamsKey) as? LayoutParams {
                return lp
            }
            let lp = LayoutParams()
            objc_setAssociatedObject(
                self,
                &Keys.layoutParamsKey,
                lp,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
            return lp
        }
        set {
            objc_setAssociatedObject(
                self,
                &Keys.layoutParamsKey,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
}

open class Layout: UIImageView, AttributedViewProtocol {
    
    open var activated: Bool = false
    
    public var orientation = Orientation.vertical {
        didSet {
            setNeedsLayout()
        }
    }

    var padding = EdgeZero {
        didSet {
            setNeedsLayout()
        }
    }
    
    public var alignItems = AlignItems.flexStart {
        didSet {
            setNeedsLayout()
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    convenience init(orientation: Orientation, padding: Edge = EdgeZero) {
        self.init(frame: CGRect.zero)
        self.orientation = orientation
        self.padding = padding
    }

    convenience init(padding: Edge) {
        self.init(frame: CGRect.zero)
        self.padding = padding
    }
    
    open func setup() {
        contentMode = .scaleAspectFill
        isUserInteractionEnabled = true
        clipsToBounds = false
    }
    
    public func setAttribute(key: String, value: String) {
        super.setAttribute(key: key, value: value)
        if ("align-items" == key) {
            if ("center" == value) {
                alignItems = .center
            }
        } else if ("direction" == key) {
            if ("row" == value) {
                orientation = .horizontal
            } else if ("column" == value) {
                orientation = .vertical
            }
        }
    }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        let sizes: [CGSize]
        var measuredSize = CGSize.zero

        if orientation == .horizontal {
            sizes = calculateHorizontalSizes(size)
            for size in sizes {
                measuredSize.width += size.width
                measuredSize.height = max(measuredSize.height, size.height)
            }
        } else {
            sizes = calculateVerticalSizes(size)
            for size in sizes {
                measuredSize.width = max(measuredSize.width, size.width)
                measuredSize.height += size.height
            }
        }

        return padding.growSize(measuredSize)
    }

    public override func layoutSubviews() {
//        if activated == true {
            if orientation == .horizontal {
                let sizes = calculateHorizontalSizes(frame.size)
                layoutHorizontally(sizes)
            } else {
                let sizes = calculateVerticalSizes(frame.size)
                layoutVertically(sizes)
            }
//        } else {
//            super.layoutSubviews()
//        }
    }

    // MARK: - Private

    private func calculateHorizontalSizes(_ size: CGSize) -> [CGSize] {
        let size = padding.shrinkSize(size)
        let undefined: CGFloat = -1
        var availableWidth = size.width
        var totalFill: CGFloat = 0
        var sizes = [CGSize](repeating: CGSize(width: undefined, height: undefined), count: subviews.count)

        for (index, view) in subviews.enumerated() {
            if view.isHidden || view.layoutParams.absolute {
                sizes[index].width = 0
                sizes[index].height = 0
                continue
            }

            let spec = view.layoutParams
            let margin = spec.margin.left + spec.margin.right
            var measuredSize: CGSize?
            var viewWidth: CGFloat = 0
            totalFill += spec.fill

            switch spec.width {
            case LayoutParams.matchParent:
                viewWidth = availableWidth - margin
            case LayoutParams.wrapContent:
                let availableSize = CGSize(width: availableWidth, height: size.height)
                measuredSize = view.sizeThatFits(availableSize)
                viewWidth = measuredSize!.width
            default:
                viewWidth = spec.width
            }

            viewWidth = max(viewWidth, spec.minWidth)
            viewWidth = min(viewWidth, spec.maxWidth)
            viewWidth = min(viewWidth, availableWidth - margin)

            sizes[index].width = viewWidth
            if let measuredSize = measuredSize, measuredSize.width == viewWidth {
                sizes[index].height = measuredSize.height
            }

            availableWidth -= (viewWidth + margin)
            
        }

        for (index, view) in subviews.enumerated() {
            if !view.isHidden && !view.layoutParams.absolute {
                let spec = view.layoutParams
                let margin = spec.margin.top + spec.margin.bottom

                if spec.fill > 0, availableWidth > 0 {
                    let extra = availableWidth * spec.fill / totalFill
                    if extra > 0 {
                        sizes[index].width += extra
                        sizes[index].height = undefined
                        // availableWidth -= extra
                    }
                }

                var viewHeight: CGFloat = 0
                switch spec.height {
                case LayoutParams.matchParent:
                    viewHeight = size.height - margin
                case LayoutParams.wrapContent:
                    viewHeight = sizes[index].height
                    if viewHeight == undefined {
                        let availableSize = CGSize(width: sizes[index].width, height: size.height)
                        let measuredSize = view.sizeThatFits(availableSize)
                        viewHeight = measuredSize.height
                    }
                default:
                    viewHeight = spec.height
                }

                viewHeight = max(viewHeight, spec.minHeight)
                viewHeight = min(viewHeight, spec.maxHeight)
                viewHeight = min(viewHeight, size.height - margin)

                sizes[index].width += (spec.margin.left + spec.margin.right)
                sizes[index].height = viewHeight + margin
            }
        }

        return sizes
    }

    private func calculateVerticalSizes(_ size: CGSize) -> [CGSize] {
        let size = padding.shrinkSize(size)
        let undefined: CGFloat = -1
        var availableHeight = size.height
        var totalFill: CGFloat = 0
        var sizes = [CGSize](repeating: CGSize(width: undefined, height: undefined), count: subviews.count)

        for (index, view) in subviews.enumerated() {
            if view.isHidden || view.layoutParams.absolute {
                sizes[index].width = 0
                sizes[index].height = 0
                continue
            }

            let spec = view.layoutParams
            let margin = spec.margin.top + spec.margin.bottom
            var measuredSize: CGSize?
            var viewHeight: CGFloat = 0
            totalFill += spec.fill

            switch spec.height {
            case LayoutParams.matchParent:
                viewHeight = availableHeight - margin
            case LayoutParams.wrapContent:
                let horizontalMargins = spec.margin.left + spec.margin.right
                let availableSize = CGSize(width: size.width - horizontalMargins, height: availableHeight)
                measuredSize = view.sizeThatFits(availableSize)
                viewHeight = measuredSize!.height
            default:
                viewHeight = spec.height
            }

            viewHeight = max(viewHeight, spec.minHeight)
            viewHeight = min(viewHeight, spec.maxHeight)
            viewHeight = min(viewHeight, availableHeight - margin)

            sizes[index].height = viewHeight
            if let measuredSize = measuredSize, measuredSize.height == viewHeight {
                sizes[index].width = measuredSize.width
            }

            availableHeight -= (viewHeight + margin)
        }

        for (index, view) in subviews.enumerated() {
            if !view.isHidden && !view.layoutParams.absolute {
                let spec = view.layoutParams
                let margin = spec.margin.left + spec.margin.right

                if spec.fill > 0, availableHeight > 0 {
                    let extra = availableHeight * spec.fill / totalFill
                    if extra > 0 {
                        sizes[index].width = undefined
                        sizes[index].height += extra
                        // availableHeight -= extra
                    }
                }

                var viewWidth: CGFloat = 0
                switch spec.width {
                case LayoutParams.matchParent:
                    viewWidth = size.width - margin
                case LayoutParams.wrapContent:
                    viewWidth = sizes[index].width
                    if viewWidth == undefined {
                        let availableSize = CGSize(width: size.width, height: sizes[index].height)
                        let measuredSize = view.sizeThatFits(availableSize)
                        viewWidth = measuredSize.width
                    }
                default:
                    viewWidth = spec.width
                }

                viewWidth = max(viewWidth, spec.minWidth)
                viewWidth = min(viewWidth, spec.maxWidth)
                viewWidth = min(viewWidth, size.width - margin)

                sizes[index].width = viewWidth + margin
                sizes[index].height += (spec.margin.top + spec.margin.bottom)
            }
        }

        return sizes
    }

    private func layoutHorizontally(_ sizes: [CGSize]) {
        let scale = UIScreen.main.scale
        let height = frame.size.height
        var left = padding.left
        for (index, size) in sizes.enumerated() {
            let view = subviews[index]
            if !view.isHidden && !view.layoutParams.absolute {
                let params = view.layoutParams
                let margin = params.margin
                var top: CGFloat

//                switch params.alignment {
//                case .center:
//                    top = padding.top + margin.top + (height - size.height - padding.top - padding.bottom) / 2
//                case .bottom:
//                    top = height - padding.bottom - size.height + margin.top
//                default:
//                    top = padding.top + margin.top
//                }
                
                switch alignItems {
                case .flexStart:
                    top = padding.top + margin.top
                case .flexEnd:
                    top = height - padding.bottom - size.height + margin.top
                case .center:
                    top = padding.top + margin.top + (height - size.height - padding.top - padding.bottom) / 2
                }

                view.frame = CGRect(
                    x: round((left + margin.left) * scale) / scale,
                    y: round(top * scale) / scale,
                    width: size.width - margin.left - margin.right,
                    height: size.height - margin.top - margin.bottom
                )

                view.layoutSubviews()
                left += size.width
            }
        }
    }

    private func layoutVertically(_ sizes: [CGSize]) {
        let scale = UIScreen.main.scale
        let width = frame.size.width
        var top = padding.top
        for (index, size) in sizes.enumerated() {
            let view = subviews[index]
            if !view.isHidden && !view.layoutParams.absolute {
                let params = view.layoutParams
                let margin = params.margin
                var left: CGFloat

//                switch params.alignment {
//                case .center:
//                    left = padding.left + margin.left + (width - size.width - padding.left - padding.right) / 2
//                case .right:
//                    left = width - padding.right - size.width + margin.left
//                default:
//                    left = padding.left + margin.left
//                }
                
                switch alignItems {
                case .flexStart:
                    left = padding.left + margin.left
                case .flexEnd:
                    left = width - padding.right - size.width + margin.left
                case .center:
                    left = padding.left + margin.left + (width - size.width - padding.left - padding.right) / 2
                }

                let duration = view.layoutParams.animatePositionOnce ? 0.3 : 0
                UIView.animate(withDuration: duration) {
                    view.frame = CGRect(
                        x: round(left * scale) / scale,
                        y: round((top + margin.top) * scale) / scale,
                        width: size.width - margin.left - margin.right,
                        height: size.height - margin.top - margin.bottom
                    )
                    view.layoutParams.animatePositionOnce = false
                }

                view.layoutSubviews()
                top += size.height
            }
        }
    }
}
