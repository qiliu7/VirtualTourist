//
//  PhotoAlbumViewController+Extensions.swift
//  VirtualTourist
//
//  Created by Kappa on 2020-04-21.
//  Copyright © 2020 qi. All rights reserved.
//

import UIKit

extension UIViewController {
  
  func showAlert(title: String, message: String, OKHandler: ((UIAlertAction) -> Void)?) {
    let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default, handler: OKHandler)
    alertVC.addAction(action)
    present(alertVC, animated: true, completion: nil)
  }
}
