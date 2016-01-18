//
//  YBAlertController.swift
//  YBAlertController
//
//  Created by Yuta on 2016/01/12.
//  Copyright © 2016年 Yabuzaki Yuta. All rights reserved.
//

import UIKit

public enum YBAlertControllerStyle {
    case ActionSheet
    case Alert
}

public enum YBButtonActionType {
    case Selector, Closure
}

public class YBAlertController: UIViewController, UIGestureRecognizerDelegate {
    
    let ybTag = 2345
    
    // background
    public var overlayColor = UIColor(white: 0, alpha: 0.2)
    
    // titleLabel
    public var titleFont = UIFont(name: "Avenir Next", size: 15)
    public var titleTextColor = UIColor.blackColor()
    
    // message
    public var message:String?
    public var messageLabel = UILabel()
    public var messageFont = UIFont(name: "Avenir Next", size: 13)
    public var messageTextColor = UIColor.lightGrayColor()
    
    // button
    public var buttonHeight:CGFloat = 50
    public var buttonTextColor = UIColor.blackColor()
    public var buttonIconColor:UIColor?
    public var buttons = [YBButton]()
    public var buttonFont = UIFont(name: "Avenir Next", size: 15)
    
    // cancelButton
    public var cancelButtonTitle:String?
    public var cancelButtonFont = UIFont(name: "Avenir Next", size: 14)
    public var cancelButtonTextColor = UIColor.darkGrayColor()
    
    public var animated = true
    public var containerView = UIView()
    public var style = YBAlertControllerStyle.ActionSheet
    public var touchingOutsideDismiss:Bool? //
    
    private var instance:YBAlertController!
    private var currentStatusBarStyle:UIStatusBarStyle?
    private var showing = false
    private var currentOrientation:UIDeviceOrientation?
    private var cancelButton = UIButton()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        view.frame = UIScreen.mainScreen().bounds
        
        containerView.backgroundColor = UIColor.whiteColor()
        containerView.clipsToBounds = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("dismiss"))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("changedOrientation:"), name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    public convenience init(style: YBAlertControllerStyle) {
        self.init()
        self.style = style
    }
    
    public convenience init(title:String?, message:String?, style: YBAlertControllerStyle) {
        self.init()
        self.style = style
        self.title = title
        self.message = message
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func changedOrientation(notification: NSNotification) {
        if showing && style == YBAlertControllerStyle.ActionSheet {
            let value = currentOrientation?.rawValue
            UIDevice.currentDevice().setValue(value, forKey: "orientation")
            return
        }
    }
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touchingOutsideDismiss == false { return false }
        if touch.view != gestureRecognizer.view { return false }
        return true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func show() {
        view.backgroundColor = overlayColor
        if touchingOutsideDismiss == nil {
            touchingOutsideDismiss = style == .ActionSheet ? true : false
        }
        
        initContainerView()
        
        if style == YBAlertControllerStyle.ActionSheet {
            UIView.animateWithDuration(0.3,
                delay: 0,
                usingSpringWithDamping: 0.9,
                initialSpringVelocity: 0,
                options: .CurveEaseIn,
                animations: {
                    self.containerView.frame.origin.y = self.view.frame.height - self.containerView.frame.height
                    self.getTopViewController()?.view.transform = CGAffineTransformMakeScale(0.9, 0.9)
                },
                completion: { (finished) in
                    if self.animated {
                        self.startButtonAppearAnimation()
                        if let cancelTitle = self.cancelButtonTitle where cancelTitle != "" {
                            self.startCancelButtonAppearAnimation()
                        }
                        
                    }
                }
            )
        } else {
            self.containerView.frame.origin.y = self.view.frame.height/2 - self.containerView.frame.height/2
            containerView.transform = CGAffineTransformMakeScale(0.5, 0.5)
            containerView.alpha = 0.0
            UIView.animateWithDuration(0.3,
                delay: 0,
                usingSpringWithDamping: 0.9,
                initialSpringVelocity: 0,
                options: .CurveEaseIn,
                animations: {
                    self.containerView.alpha = 1.0
                    self.containerView.transform = CGAffineTransformMakeScale(1, 1)
                },
                completion: { (finished) in
                    if self.animated {
                        self.startButtonAppearAnimation()
                        if let cancelTitle = self.cancelButtonTitle where cancelTitle != "" {
                            self.startCancelButtonAppearAnimation()
                        }
                        
                    }
                }
            )
        }
    }
    
    public func dismiss() {
        showing = false
        if let statusBarStyle = currentStatusBarStyle {
            UIApplication.sharedApplication().statusBarStyle = statusBarStyle
        }
        
        if style == .ActionSheet {
            UIView.animateWithDuration(0.2,
                animations: {
                    self.containerView.frame.origin.y = self.view.frame.height
                    self.view.backgroundColor = UIColor(white: 0, alpha: 0)
                    self.getTopViewController()?.view.transform = CGAffineTransformMakeScale(1.0, 1.0)
                },
                completion:  { (finished) in
                    self.view.removeFromSuperview()
            })
        } else {
            UIView.animateWithDuration(0.2,
                animations: {
                    self.view.backgroundColor = UIColor(white: 0, alpha: 0)
                    self.containerView.transform = CGAffineTransformMakeScale(0.5, 0.5)
                    self.containerView.alpha = 0
                },
                completion:  { (finished) in
                    self.view.removeFromSuperview()
            })
        }
    }
    
    private func getTopViewController() -> UIViewController? {
        var topVC = UIApplication.sharedApplication().keyWindow?.rootViewController
        while topVC?.presentedViewController != nil {
            topVC = topVC?.presentedViewController
        }
        return topVC
    }
    
    private func initContainerView() {
        
        for subView in containerView.subviews {
            subView.removeFromSuperview()
        }
        for subView in self.view.subviews {
            subView.removeFromSuperview()
        }
        
        showing = true
        instance = self
        let viewWidth = (style == .ActionSheet) ? view.frame.width : view.frame.width * 0.9
        
        currentOrientation = UIDevice.currentDevice().orientation
        let orientation = UIApplication.sharedApplication().statusBarOrientation
        if orientation == UIInterfaceOrientation.Portrait {
            currentOrientation = UIDeviceOrientation.Portrait
        }
        
        var posY:CGFloat = 0
        if let title = title where title != ""  {
            let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: viewWidth, height: buttonHeight*0.92))
            titleLabel.text = title
            titleLabel.font = titleFont
            titleLabel.textAlignment = .Center
            titleLabel.autoresizingMask = [.FlexibleRightMargin, .FlexibleLeftMargin]
            titleLabel.textColor = titleTextColor
            containerView.addSubview(titleLabel)
            
            let line = UIView(frame: CGRect(x: 0, y: titleLabel.frame.height, width: viewWidth, height: 1))
            line.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
            line.autoresizingMask = [.FlexibleWidth]
            containerView.addSubview(line)
            posY = titleLabel.frame.height + line.frame.height
        } else {
            posY = 0
        }
        
        if let message = message where message != "" {
            let paddingY:CGFloat = 8
            let paddingX:CGFloat = 10
            messageLabel.font = messageFont
            messageLabel.textColor = UIColor.grayColor()
            messageLabel.translatesAutoresizingMaskIntoConstraints = false
            messageLabel.text = message
            messageLabel.numberOfLines = 0
            messageLabel.textColor = messageTextColor
            let f = CGSizeMake(viewWidth - paddingX*2, CGFloat.max)
            let rect = messageLabel.sizeThatFits(f)
            messageLabel.frame = CGRect(x: paddingX, y: posY + paddingY, width: rect.width, height: rect.height)
            containerView.addSubview(messageLabel)
            containerView.addConstraints([
                NSLayoutConstraint(item: messageLabel, attribute: .RightMargin, relatedBy: NSLayoutRelation.Equal, toItem: containerView, attribute: .RightMargin, multiplier: 1, constant: -paddingX),
                NSLayoutConstraint(item: messageLabel, attribute: .LeftMargin, relatedBy: .Equal, toItem: containerView, attribute: .LeftMargin, multiplier: 1.0, constant: paddingX),
                NSLayoutConstraint(item: messageLabel, attribute: .Top, relatedBy: .Equal, toItem: containerView, attribute: .Top, multiplier: 1.0, constant: posY + paddingY),
                NSLayoutConstraint(item: messageLabel, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: rect.height)
            ])
            
            posY = messageLabel.frame.maxY + paddingY
            
            let line = UIView(frame: CGRect(x: 0, y: posY, width: viewWidth, height: 1))
            line.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
            line.autoresizingMask = [.FlexibleWidth]
            containerView.addSubview(line)
            
            posY += line.frame.height
        }
        
        for i in 0..<buttons.count {
            buttons[i].frame.origin.y = posY
            buttons[i].backgroundColor = UIColor.whiteColor()
            buttons[i].buttonColor = buttonIconColor
            buttons[i].frame = CGRect(x: 0, y: posY, width: viewWidth, height: buttonHeight)
            buttons[i].textLabel.textColor = buttonTextColor
            buttons[i].buttonFont = buttonFont
            buttons[i].translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(buttons[i])
            
            containerView.addConstraints([
                NSLayoutConstraint(item: buttons[i], attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: buttonHeight),
                NSLayoutConstraint(item: buttons[i], attribute: NSLayoutAttribute.RightMargin, relatedBy: NSLayoutRelation.Equal, toItem: containerView, attribute: NSLayoutAttribute.RightMargin, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: buttons[i], attribute: NSLayoutAttribute.LeftMargin, relatedBy: NSLayoutRelation.Equal, toItem: containerView, attribute: NSLayoutAttribute.LeftMargin, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: buttons[i], attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: containerView, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: posY)
            ])
            posY += buttons[i].frame.height
        }
        
        if let cancelTitle = cancelButtonTitle where cancelTitle != "" {
            cancelButton = UIButton(frame: CGRect(x: 0, y: posY, width: viewWidth, height: buttonHeight * 0.9))
            cancelButton.autoresizingMask = [.FlexibleRightMargin, .FlexibleLeftMargin]
            cancelButton.titleLabel?.font = cancelButtonFont
            cancelButton.setTitle(cancelButtonTitle, forState: .Normal)
            cancelButton.setTitleColor(cancelButtonTextColor, forState: .Normal)
            cancelButton.addTarget(self, action: Selector("dismiss"), forControlEvents: .TouchUpInside)
            containerView.addSubview(cancelButton)
            posY += cancelButton.frame.height
        }
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.frame = CGRect(x: (view.frame.width - viewWidth) / 2, y:view.frame.height , width: viewWidth, height: posY)
        containerView.backgroundColor = UIColor.whiteColor()
        view.addSubview(containerView)
        
        
        
        if style == YBAlertControllerStyle.ActionSheet {
            self.view.addConstraints([
                NSLayoutConstraint(item: containerView, attribute: NSLayoutAttribute.Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: containerView, attribute: NSLayoutAttribute.CenterX, relatedBy: .Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: containerView, attribute: NSLayoutAttribute.Bottom, relatedBy: .Equal, toItem: self.view, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: containerView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: posY)
            ])
        } else {
            self.view.addConstraints([
                NSLayoutConstraint(item: containerView, attribute: NSLayoutAttribute.Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 0.9, constant: 0),
                NSLayoutConstraint(item: containerView, attribute: NSLayoutAttribute.CenterX, relatedBy: .Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: containerView, attribute: NSLayoutAttribute.CenterY, relatedBy: .Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: containerView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: posY)
            ])
        }
        
        if let window = UIApplication.sharedApplication().keyWindow {
            if window.viewWithTag(ybTag) == nil {
                view.tag = ybTag
                window.addSubview(view)
            }
        }
        
        currentStatusBarStyle = UIApplication.sharedApplication().statusBarStyle
        if style == .ActionSheet { UIApplication.sharedApplication().statusBarStyle = .LightContent }
        
        if animated {
            cancelButton.hidden = true
            buttons.forEach {
                $0.iconImageView.transform = CGAffineTransformMakeScale(0, 0)
                $0.textLabel.transform = CGAffineTransformMakeScale(0, 0)
                $0.dotView.hidden = true
            }
        } else {
            buttons.forEach {
                if $0.iconImageView.image == nil {
                    $0.dotView.hidden = false
                }
            }
        }
    }
    
    private func startButtonAppearAnimation() {
        for i in 0..<buttons.count {
            let delay = 0.2 * Double(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(i)))
            dispatch_after(time, dispatch_get_main_queue(), {
                self.buttons[i].appear()
            })
        }
    }
    
    private func startCancelButtonAppearAnimation() {
        cancelButton.titleLabel?.transform = CGAffineTransformMakeScale(0, 0)
        cancelButton.hidden = false
        UIView.animateWithDuration(0.2, delay: 0.2 * Double(buttons.count + 1) - 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .CurveEaseIn, animations: {
            self.cancelButton.titleLabel?.transform = CGAffineTransformMakeScale(1.0, 1.0)
            }, completion: nil)
    }
    
    public func addButton(icon:UIImage?, title:String, action:()->Void) {
        let button = YBButton(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: buttonHeight), icon: icon, text: title)
        button.actionType = YBButtonActionType.Closure
        button.action = action
        button.buttonColor = buttonIconColor
        button.buttonFont = buttonFont
        button.addTarget(self, action: Selector("buttonTapped:"), forControlEvents: .TouchUpInside)
        buttons.append(button)
    }
    
    public func addButton(icon:UIImage?, title:String, target:AnyObject, selector:Selector) {
        let button = YBButton(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: buttonHeight), icon: icon, text: title)
        button.actionType = YBButtonActionType.Selector
        button.buttonColor = buttonIconColor
        button.target = target
        button.selector = selector
        button.buttonFont = buttonFont
        button.addTarget(self, action: Selector("buttonTapped:"), forControlEvents: .TouchUpInside)
        buttons.append(button)
    }
    
    public func addButton(title:String, action:()->Void) {
        addButton(nil, title: title, action: action)
    }
    
    public func addButton(title:String, target:AnyObject, selector:Selector) {
        addButton(nil, title: title, target: target, selector: selector)
    }
    
    func buttonTapped(button:YBButton) {
        if button.actionType == YBButtonActionType.Closure {
            button.action()
        } else if button.actionType == YBButtonActionType.Selector {
            let control = UIControl()
            control.sendAction(button.selector, to: button.target, forEvent: nil)
        }
        dismiss()
    }
}

public class YBButton : UIButton {
    
    override public var highlighted : Bool {
        didSet {
            alpha = highlighted ? 0.3 : 1.0
        }
    }
    var buttonColor:UIColor? {
        didSet {
            if let buttonColor = buttonColor {
                iconImageView.image = icon?.imageWithRenderingMode(.AlwaysTemplate)
                iconImageView.tintColor = buttonColor
                dotView.dotColor = buttonColor
            } else {
                iconImageView.image = icon
            }
        }
    }
    
    var icon:UIImage?
    var iconImageView = UIImageView()
    var textLabel = UILabel()
    var dotView = DotView()
    var buttonFont:UIFont? {
        didSet {
            textLabel.font = buttonFont
        }
    }
    var actionType:YBButtonActionType!
    var target:AnyObject!
    var selector:Selector!
    var action:(()->Void)!
    
    init(frame:CGRect,icon:UIImage?, text:String) {
        super.init(frame:frame)
        
        self.icon = icon
        let iconHeight:CGFloat = frame.height * 0.45
        iconImageView.frame = CGRect(x: 9, y: frame.height/2 - iconHeight/2, width: iconHeight, height: iconHeight)
        iconImageView.image = icon
        addSubview(iconImageView)
        
        dotView.frame = iconImageView.frame
        dotView.backgroundColor = UIColor.clearColor()
        dotView.hidden = true
        addSubview(dotView)
        
        let labelHeight = frame.height * 0.8
        textLabel.frame = CGRect(x: iconImageView.frame.maxX + 11, y: frame.midY - labelHeight/2, width: frame.width - iconImageView.frame.maxX, height: labelHeight)
        textLabel.text = text
        textLabel.textColor = UIColor.blackColor()
        textLabel.font = buttonFont
        addSubview(textLabel)
    }
    
    func appear() {
        iconImageView.transform = CGAffineTransformMakeScale(0, 0)
        textLabel.transform = CGAffineTransformMakeScale(0, 0)
        dotView.transform = CGAffineTransformMakeScale(0, 0)
        dotView.hidden = false
        UIView.animateWithDuration(0.2, animations: {
            self.textLabel.transform = CGAffineTransformMakeScale(1.0, 1.0)
        })
        
        UIView.animateWithDuration(0.2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .CurveLinear, animations: {
            
            if self.iconImageView.image == nil {
                self.dotView.transform = CGAffineTransformMakeScale(1.0, 1.0)
            } else {
                self.iconImageView.transform = CGAffineTransformMakeScale(1.0, 1.0)
            }
            }, completion: nil)
    }
    
    required public init?(coder aDecoder:NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func drawRect(rect: CGRect) {
        UIColor(white: 0.85, alpha: 1.0).setStroke()
        let line = UIBezierPath()
        line.lineWidth = 1
        line.moveToPoint(CGPoint(x: iconImageView.frame.maxX + 5, y: frame.height))
        line.addLineToPoint(CGPoint(x: frame.width , y: frame.height))
        line.stroke()
    }
}

class DotView:UIView {
    var dotColor = UIColor.blackColor()
    
    override func drawRect(rect: CGRect) {
        dotColor.setFill()
        let circle = UIBezierPath(arcCenter: CGPoint(x: frame.width/2, y: frame.height/2), radius: 3, startAngle: 0, endAngle: 360, clockwise: true)
        circle.fill()
    }
}
