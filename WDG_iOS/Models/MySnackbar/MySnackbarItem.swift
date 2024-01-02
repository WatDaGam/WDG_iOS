//
//  MySnackbarItem.swift
//  WDG_iOS
//
//  Created by Yong Min Back on 1/2/24.
//

import Foundation

struct SnackBarItem {
    let message: String
    let actionLabel: String?
    let duration: SnackbarDuration
    let action: SnackbarAction?
    
    func toDelay() -> Int {
        switch duration {
        case .Short : return 4
        case .Long : return 10
        case .Indefinite : return Int.max
        }
    }
}
