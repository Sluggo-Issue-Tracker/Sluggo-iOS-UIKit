//
//  IdentityView.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 4/27/21.
//

import UIKit

protocol IdentityInitialized {
    init? (coder: NSCoder, identity: AppIdentity)
}
