//
//  MySnackbarAction.swift
//  WDG_iOS
//
//  Created by Yong Min Back on 1/2/24.
//

import Foundation

// Snackbar Action when dismiss / click label
public protocol SnackbarAction {
    func onDismiss()
    func onPerformAction()
}
