//
//
//  Created by zhaogang on 2017/3/29.
//
//

import UIKit
import ZGCore

public struct ZGUINavigator {
    public static func topViewController() -> UIViewController? {
 
        let delegateOptional:UIApplicationDelegate? = UIApplication.shared.delegate
        var rootViewController:UIViewController?
        
        if let delegate = delegateOptional {
            rootViewController = delegate.window??.rootViewController
        }
        
        guard let rootVCL = rootViewController else {
            return nil
        }
        
        var returnVCL:UIViewController = rootVCL
        
        if rootVCL is UINavigationController {
            let nav:UINavigationController = rootVCL as! UINavigationController
            if let vcl = nav.topViewController {
                returnVCL = vcl
            }
            if let vcl = returnVCL.presentedViewController {
                returnVCL = vcl
            }
            if returnVCL is ZGNaviController {
                return returnVCL
            }
            guard let _ = returnVCL as? ZGBaseViewCTL else {
                return rootVCL
            }
        }
        return returnVCL
    } 
}
