//
//  MySnackbarOption.swift
//  WDG_iOS
//
//  Created by Yong Min Back on 1/2/24.
//

import Foundation
import SwiftUI

public class SnackbarOption {
    public static let shared = SnackbarOption()
    private init() {}
    
    // snackbar Color
    public var bgColor = Color(red: 37 / 255, green: 36 / 255, blue: 39 / 255)
    
    // snackbar TextColor
    public var textColor = Color.white
    
    // snackbar label Color
    public var labelColor = Color.blue
    
    // snackbar TextSize
    public var textSize :CGFloat = 12
    
    // snackbar LabelSize
    public var labelSize :CGFloat = 12

    
}
