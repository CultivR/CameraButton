//
//  CameraButton.swift
//  CameraButton
//
//  Created by Jordan Kay on 3/7/17.
//  Copyright © 2017 Squareknot. All rights reserved.
//

import Then

/**
 * System-styled button used to take photos or videos, for use with camera.
 */
@IBDesignable public final class CameraButton: UIButton {
    /**
     * Mode of accompanying camera used with this button.
     */
    public enum Mode {
        case photo // For taking photos with the camera
        case video // For taking videos with the camera
    }
    
    /**
     * Value used for setting the mode in Interface Builder.
     * 0 = Photo
     * 1 = Video
     */
    @IBInspectable public private(set) var modeValue: Int = 0 {
        didSet {
            mode = Mode(modeValue: modeValue)
        }
    }
    
    /**
     * Current mode, defaulting to photo.
     * Changing will change the style of the button.
     */
    public var mode: Mode = .photo {
        didSet {
            guard mode != oldValue else { return }
            updateContent(animated: true)
        }
    }
    
    public weak var delegate: CameraButtonDelegate?
    
    fileprivate var isRecording = false {
        didSet {
            guard isRecording != oldValue else { return }
            updateRecording()
        }
    }
    
    fileprivate lazy var contentLayer: CALayer = CALayer().then {
        $0.frame = .contentRect
        $0.cornerRadius = .contentRadius
        $0.backgroundColor = UIColor.photoContent.cgColor
        self.layer.addSublayer($0)
    }
    
    private lazy var borderLayer: CALayer = CALayer().then {
        $0.frame = .rect
        $0.cornerRadius = .borderRadius
        $0.borderWidth = .borderWidth
        $0.borderColor = UIColor.border.cgColor
        self.layer.addSublayer($0)
    }
    
    // MARK: UIView
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addActions()
    }
    
    override public var backgroundColor: UIColor? {
        get { return nil }
        set {}
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        [borderLayer, contentLayer].forEach {
            $0.position = convert(center, from: superview)
        }
    }
    
    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let inside = borderLayer.frame.contains(point)
        if inside {
            highlight()
        }
        return inside
    }
    
    // MARK: NSCoding
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        addActions()
        
        defer {
            modeValue = coder.decodeInteger(forKey: "modeValue")
        }
    }
    
    public override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        coder.encode(modeValue, forKey: "modeValue")
    }
}

private extension CameraButton {
    var contentColor: UIColor {
        let color: UIColor
        switch mode {
        case .photo:
            color = .photoContent
        case .video:
            color = .videoContent
        }
        return color.highlighted(isHighlighted)
    }
    
    func addActions() {
        addTarget(self, action: #selector(trigger), for: [.touchDragExit, .touchUpInside])
        addTarget(self, action: #selector(highlightAnimated), for: .touchDragEnter)
        addTarget(self, action: #selector(unhighlightAnimated), for: .touchCancel)
    }
    
    func updateContent(animated: Bool) {
        CATransaction.begin()
        if !animated {
            CATransaction.setDisableActions(true)
        }
        if mode != .video {
            isRecording = false
        }
        contentLayer.backgroundColor = contentColor.cgColor
        CATransaction.commit()
    }
    
    func updateRecording() {
        CATransaction.begin()
        if !isRecording {
            // Approximate system animation curve and duration
            CATransaction.setAnimationDuration(.easeOutDuration)
            CATransaction.setAnimationTimingFunction(.easeOutQuartic)
        }
        contentLayer.frame = isRecording ? .recordingRect : .contentRect
        contentLayer.cornerRadius = isRecording ? .recordingCornerRadius : .contentRadius
        CATransaction.commit()
    }
    
    func highlight() {
        isHighlighted = true
        updateContent(animated: false)
    }
    
    func triggerForPhoto() {
        delegate?.cameraButtonDidTakePhoto(self)
    }
    
    func triggerForVideo() {
        isRecording = !isRecording
        if isRecording {
            delegate?.cameraButtonDidStartRecordingVideo(self)
        } else {
            delegate?.cameraButtonDidStopRecordingVideo(self)
        }
    }
    
    dynamic func trigger() {
        unhighlightAnimated()
        switch mode {
        case .photo:
            triggerForPhoto()
        case .video:
            triggerForVideo()
        }
    }
    
    dynamic func highlightAnimated() {
        isHighlighted = true
        updateContent(animated: true)
    }
    
    dynamic func unhighlightAnimated() {
        isHighlighted = false
        updateContent(animated: true)
    }
}

private extension CGFloat {
    static let sideLength: CGFloat = 66
    static let borderWidth: CGFloat = 6
    static let contentSpacing: CGFloat = 2
    static let recordingInset: CGFloat = 19
    static let recordingCornerRadius: CGFloat = 4
    
    static let borderRadius = .sideLength / 2
    static let contentInset = .borderWidth + .contentSpacing
    static let contentRadius = .borderRadius - .borderWidth - .contentSpacing
}

private extension CGRect {
    static let rect = CGRect(x: 0, y: 0, width: .sideLength, height: .sideLength)
    static let contentRect = rect.insetBy(dx: .contentInset, dy: .contentInset)
    static let recordingRect = rect.insetBy(dx: .recordingInset, dy: .recordingInset)
}

private extension UIColor {
    static let border: UIColor = .white
    static let photoContent: UIColor = .white
    static let videoContent = UIColor(red: 226 / 255.0, green: 73 / 255.0, blue: 61 / 255.0, alpha: 1)
    
    func highlighted(_ highlighted: Bool) -> UIColor {
        return highlighted ? withAlphaComponent(0.2) : self
    }
}

private extension TimeInterval {
    static let easeOutDuration = 0.6
}

private extension CAMediaTimingFunction {
    static let easeOutQuartic = CAMediaTimingFunction(controlPoints: 0.165, 0.84, 0.44, 1)
}

private extension CameraButton.Mode {
    init(modeValue: Int) {
        switch modeValue {
        case 0:
            self = .photo
        case 1:
            self = .video
        default:
            self = .photo
        }
    }
}
