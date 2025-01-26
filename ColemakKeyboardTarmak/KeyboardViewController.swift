import KeyboardKit
import SwiftUI

class CustomKeyboardLayoutService: KeyboardLayout.StandardLayoutService {
    override init(baseService: any KeyboardLayoutService = KeyboardLayout.DeviceBasedLayoutService(), localizedServices: [any KeyboardLayout.StandardLayoutService.LocalizedLayoutService] = []) {
        super.init(baseService: CustomDeviceBasedLayoutService(), localizedServices: localizedServices)
    }
    
    // Never use array indices if it can cause a crash.
    override func keyboardLayout(for context: KeyboardContext) -> KeyboardLayout {
        var layout = super.keyboardLayout(for: context)
        // Perform any modifications here
        return layout
    }
}

class CustomDeviceBasedLayoutService: KeyboardLayout.DeviceBasedLayoutService {
    lazy var customiPadService: KeyboardLayoutService = CustomiPadLayoutService(
        alphabeticInputSet: CustomDeviceBasedLayoutService.colemak,
        numericInputSet: numericInputSet,
        symbolicInputSet: symbolicInputSet
    )
    
    /// The layout service to use for iPhone devices.
    lazy var customiPhoneService: KeyboardLayoutService = CustomiPhoneLayoutService(
        alphabeticInputSet: CustomDeviceBasedLayoutService.colemak,
        numericInputSet: numericInputSet,
        symbolicInputSet: symbolicInputSet
    )
    
    
    override func keyboardLayoutService(for context: KeyboardContext) -> any KeyboardLayoutService {
        switch context.deviceTypeForKeyboard {
        case .phone: customiPhoneService
        case .pad: customiPadService
        default: customiPhoneService
        }
    }
    
    static var colemak: InputSet {
        var rows: [InputSet.ItemRow] = []
        
        var firstRow = "qwjrtyuiop".map({ InputSet.Item(String($0)) })
        
        var secondRow = "asdfghnel".map({ InputSet.Item(String($0)) })
        
        var lastRow = "zxcvbkm".map({ InputSet.Item(String($0)) })
        
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            firstRow.append(InputSet.Item(neutral: ";", uppercased: ":", lowercased: ";"))
            firstRow.append(InputSet.Item(neutral: "[", uppercased: "{", lowercased: "["))
            firstRow.append(InputSet.Item(neutral: "]", uppercased: "}", lowercased: "]"))
            firstRow.append(InputSet.Item(neutral: "\\", uppercased: "|", lowercased: "\\"))
            
             secondRow.append(InputSet.Item(neutral: "'", uppercased: "\"", lowercased: "'"))
            
            lastRow.append(InputSet.Item(neutral: ",", uppercased: "<", lowercased: ","))
            lastRow.append(InputSet.Item(neutral: ".", uppercased: ">", lowercased: "."))
            lastRow.append(InputSet.Item(neutral: "/", uppercased: "?", lowercased: "/"))
        }
        
        rows.append(InputSet.ItemRow(items: firstRow))
        rows.append(InputSet.ItemRow(items: secondRow))
        rows.append(InputSet.ItemRow(items: lastRow))
        
        return InputSet(rows: rows)
    }
}


class CustomiPadLayoutService: KeyboardLayout.iPadLayoutService {
    override func topLeadingActions(for context: KeyboardContext) -> KeyboardAction.Row {
        [.tab]
    }
    
    override func topTrailingActions(for context: KeyboardContext) -> KeyboardAction.Row {
        []
    }
    
    override func middleLeadingActions(for context: KeyboardContext) -> KeyboardAction.Row {
        [.backspace]
    }
    
    override func itemSizeWidth(for action: KeyboardAction, row: Int, index: Int, context: KeyboardContext) -> KeyboardLayout.ItemWidth {
        if isLowerTrailingSwitcher(action, row: row, index: index) { return .available }
        
        if row == 0 {
            if action == .tab {
                return .percentage(0.1)
            }
        }
        
        if row == 1 {
            if action == .backspace {
                return .percentage(0.11)
            }
            if index == 12 {
                return .percentage(0.13)
            }
        }
        
        if row == 2 {
            if index == 0 {
                return .percentage(0.14)
            }
            if index == 11 {
                return .percentage(0.17)
            }
        }
        
        return super.itemSizeWidth(for: action, row: row, index: index, context: context)
    }
    
    func isLowerTrailingSwitcher(
        _ action: KeyboardAction,
        row: Int,
        index: Int
    ) -> Bool {
        switch action {
            case .keyboardType: row == 2 && index > 0
            default: false
        }
    }
}

class CustomiPhoneLayoutService: KeyboardLayout.iPhoneLayoutService {
    override func lowerTrailingActions(for actions: KeyboardAction.Rows, context: KeyboardContext) -> KeyboardAction.Row {
        [.backspace]
    }
    
    override func lowerLeadingActions(for actions: KeyboardAction.Rows, context: KeyboardContext) -> KeyboardAction.Row {
        [.shift(context.keyboardCase)]
    }
    
    override func itemSizeWidth(for action: KeyboardAction, row: Int, index: Int, context: KeyboardContext) -> KeyboardLayout.ItemWidth {
        if row == 0 && context.keyboardType == .alphabetic {
            return .percentage(0.1)
        }
        
        if row == 2 && context.keyboardType == .alphabetic {
            if index == 0 || index == 8 {
                return .percentage(0.15)
            }
            return .percentage(0.1)
        }
        
        if row == 2 && context.keyboardType == .numeric {
            return .available
        }
        
        // Use default widths for other rows
        return super.itemSizeWidth(for: action, row: row, index: index, context: context)
    }
}
