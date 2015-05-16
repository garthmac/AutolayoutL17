//
//  ViewController.swift
//  Autolayout
//
//  Created by iMac21.5 on 4/21/15.
//  Copyright (c) 2015 Garth MacKenzie. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // after the demo, appropriate things were private-ized.
    // including outlets and actions.
    
    @IBOutlet private weak var loginField: UITextField!
    @IBOutlet private weak var passwordField: UITextField!
    @IBOutlet private weak var passwordLabel: UILabel!
    @IBOutlet private weak var companyLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    
    @IBOutlet weak var lastLoginLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    // our Model, the logged in user
    var loggedInUser: User! { didSet { updateUI() } }
    // sets whether the password field is secure or not
    var secure = false { didSet { updateUI() }
    }
    // NOTE: After the demo, this method was protected against
    //         crashing if it is called before our outlets are set.
    //       This is nice to do since setting our Model calls this
    //         and our Model might get set while we are being prepared.
    //       It was easy too.  Just added ? after outlets.
    private func updateUI() {
        passwordField?.secureTextEntry = secure
        let password = NSLocalizedString("Password", comment: "Prompt for the user's password when it is not secure (i.e. plain text)")
        let securedPassword = NSLocalizedString("Secured Password",
            comment: "Prompt for an obscured (not plain text) password")
        passwordLabel?.text = secure ? "Secured Password" : "Password"
        nameLabel?.text = loggedInUser?.name
        companyLabel?.text = loggedInUser?.company
        image = loggedInUser?.image
        passwordField.resignFirstResponder()
        loginField.resignFirstResponder()
        if let lastLogin = loggedInUser?.lastLogin {
            let dateFormatter = NSDateFormatter()
            dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
            dateFormatter.dateStyle = NSDateFormatterStyle.NoStyle
            let time = dateFormatter.stringFromDate(lastLogin)
            let numberFormatter = NSNumberFormatter()
            numberFormatter.maximumFractionDigits = 1
            let daysAgo = numberFormatter.stringFromNumber(-lastLogin.timeIntervalSinceNow/(60*60*24))!
            let lastLoginFormatString = NSLocalizedString("Last Login %@ days ago at %@",
                comment: "Reports the number of days ago and time that the user last logged in")
            lastLoginLabel.text = String.localizedStringWithFormat(lastLoginFormatString, daysAgo, time)
        } else {
            lastLoginLabel.text = ""
        }
    }
    
    private struct AlertStrings {
        struct LoginError {
            static let Title = NSLocalizedString("Login Error",
                comment: "Title of alert when user types in an incorrect user name or password")
            static let Message = NSLocalizedString("Invalid user name or password",
                comment: "Message in an alert when the user types in an incorrect user name or password")
            static let DismissButton = NSLocalizedString("Try Again",
                comment: "The only button available in an alert presented when the user types incorrect user name or password")
        }
    }
    
    // log in (set our Model)
    @IBAction private func login() {
        loggedInUser = User.login(loginField.text ?? "", password: passwordField.text ?? "")
        if loggedInUser == nil {
            let alert = UIAlertController(title: AlertStrings.LoginError.Title, message: AlertStrings.LoginError.Message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: AlertStrings.LoginError.DismissButton, style: UIAlertActionStyle.Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        }

    }
    @IBAction func toggleSecurity() {
        secure = !secure
    }
    
    // a convenience property
    // so that we can easily intervene
    // whenever the image is set in our imageView
    // we add a constraint that the imageView
    // must maintain the aspect ratio of its image
    private var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
            if let constrainedView = imageView {
                if let newImage = newValue { //w=h*aspectRatio
                    aspectRatioConstraint = NSLayoutConstraint(item: constrainedView,
                        attribute: .Width,
                        relatedBy: .Equal,
                        toItem: constrainedView,
                        attribute: .Height,
                        multiplier: newImage.aspectRatio,
                        constant: 0)
                } else {
                    aspectRatioConstraint = nil
                }
            }
        }
        
    }
    
    // the imageView aspect ratio constraint
    // when it is set here,
    // we'll remove any existing aspect ratio constraint
    // and then add the new one to our view
    private var aspectRatioConstraint: NSLayoutConstraint? {
        willSet {
            if let existingConstraint = aspectRatioConstraint {
                view.removeConstraint(existingConstraint)
            }
        }
        didSet { // if not nil
            if let newConstraint = aspectRatioConstraint {
                view.addConstraint(newConstraint)
            }
        }
    }
    
}

// User is our Model,
// so it can't itself have anything UI-related
// but we can add a UI-specific property
// just for us to use
// because we are the Controller
// note this extension is private
private extension User {
    var image: UIImage? {
        if let image = UIImage(named: login) {
            return image
        } else {
            return UIImage(named: "userUnknown")
        }
    }
}

// wouldn't it be convenient
// to have an aspectRatio property in UIImage?
// yes, it would, so let's add one!
// why is this not already in UIImage?
// probably because the semantic of returning zero
//   if the height is zero is not perfect
//   (nil might be better, but annoying)
extension UIImage {
    var aspectRatio: CGFloat {
        return size.height != 0 ? size.width / size.height : 0
    }
}
// when change size class (regular H, Any W) set Image,Name,Company
//remove contraints first before moving


