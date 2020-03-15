//
//  DispatchToMainHelper.swift
//  VirtualTourist
//
//  Created by Kappa on 2020-03-13.
//  Copyright © 2020 qi. All rights reserved.
//

import Foundation

func dispatchToMain(_ task: @escaping () -> Void) {
  DispatchQueue.main.async {
    task()
  }
}
