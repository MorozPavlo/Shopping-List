//
//  AppIconServise.swift
//  Shopping List
//
//  Created by Pavel Moroz on 22.04.2020.
//  Copyright © 2020 Pavel Moroz. All rights reserved.
//

import Foundation
import UIKit

class AppIconServise {

    let application = UIApplication.shared

    enum AppIcon: String {
        case primaryAppIcon
        case shopping1
        case shopping2
        case shopping3
    }

    func changeAppIcon(to appIcon: AppIcon) {

        let appIconValue: String? = appIcon == .primaryAppIcon ? nil : appIcon.rawValue
        application.setAlternateIconName(appIconValue) { (error) in
            if error != nil {
                print(error?.localizedDescription ?? "")
                return
            }
            print(appIconValue)
        }
    }
}
