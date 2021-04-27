//
//  IdentityView.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 4/27/21.
//

import UIKit

protocol IdentityView {
    init? (coder: NSCoder, identity: AppIdentity)
    func setIdentity(identity: AppIdentity)
}
