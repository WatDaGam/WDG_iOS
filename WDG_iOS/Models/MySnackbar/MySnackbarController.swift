//
//  MySnackbarController.swift
//  WDG_iOS
//
//  Created by Yong Min Back on 1/2/24.
//

import Foundation

public class SnackbarController: ObservableObject {
    public init() {}
    
    @Published var snackbarItem : SnackBarItem? = nil
    
    /**
     Show SnackBar only msg
     */
    public func showSnackBar(
        message: String
    ) {
        self.showSnackBar(message: message, label: nil ,duration: SnackbarDuration.Short,action: nil)
    }
    /**
     Show SnackBar Msg with Dismiss Action
     */
    public func showSnackBar(
        message: String,
        dismissAction : @escaping () -> Void
    ) {
        let dismissAction = DismissAction() {
            dismissAction()
        }
        self.showSnackBar(message: message, label: nil ,duration: SnackbarDuration.Short,action: dismissAction)
    }
    
    /**
     Show SnackBar Msg with Duration
     */
    public func showSnackBar(
        message: String,
        duration: SnackbarDuration = SnackbarDuration.Short
    ) {
        self.showSnackBar(message: message, label: nil ,duration: duration,action: nil)
    }
    
    public func showSnackBar(
        message: String,
        label: String? = nil,
        action: SnackbarAction
    ) {
        self.showSnackBar(message: message, label: label ,duration: SnackbarDuration.Short,action: action)
    }
    
    public func showSnackBar(
        message: String,
        label: String? = nil,
        duration: SnackbarDuration = SnackbarDuration.Short,
        action: SnackbarAction?
    ) {
        self.snackbarItem = SnackBarItem(
            message: message,
            actionLabel: label,
            duration: duration,
            action: action
        )
        resetTask()
    }
    
    private var workItem: DispatchWorkItem?
    
    private func resetTask() {
        guard let item  = snackbarItem else {
            return
        }
        workItem?.cancel()
        if (item.duration != SnackbarDuration.Indefinite) {
            let dispatchAfter = DispatchTimeInterval.seconds(item.toDelay())
            workItem = DispatchWorkItem {
                self.resetSnackBar()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + dispatchAfter,execute: workItem!)
        }
        
    }
    
    
    public func resetSnackBar() {
        self.snackbarItem?.action?.onDismiss()
        self.snackbarItem = nil
    }
    
    private class DismissAction : SnackbarAction {
        private var action : () -> Void
        
        init(action: @escaping () -> Void) {
            self.action = action
        }
        
        func onDismiss() {
            action()
        }
        
        func onPerformAction() {
            
        }
    }
}
