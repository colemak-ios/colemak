import KeyboardKit
import SwiftUI

class KeyboardViewController: KeyboardInputViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        services.layoutService = CustomKeyboardLayoutService()
    }

    override func viewWillSetupKeyboardView() {
        super.viewWillSetupKeyboardView()
        setupKeyboardView { controller in
            CustomKeyboardView(
                services: controller.services,
                state: controller.state
            )
        }
    }
}

struct CustomKeyboardView: View {
    // These are not used here, but perhaps you need them.
    var services: Keyboard.Services
    var state: Keyboard.State


    // Keyboard state can be accessed from the enviroment.
    @EnvironmentObject var keyboardContext: KeyboardContext

    func buttonContent(
        for item: KeyboardLayout.Item
    ) -> Keyboard.ButtonContent {
        Keyboard.ButtonContent(
            action: item.action,
            styleService: services.styleService,
            keyboardContext: keyboardContext
        )
    }

    var body: some View {
        KeyboardView(
            state: state,
            services: services,
            buttonContent: { $0.view },
            buttonView: { $0.view },
            collapsedView: { $0.view },
            emojiKeyboard: { $0.view },
            toolbar: { _ in
                if UIDevice.current.userInterfaceIdiom == .pad {
                    toolbar()
                }
            }
        )
    }

    @ViewBuilder
    func toolbar() -> some View {
        HStack {
            ForEach(NumberButtonItem.items) { item in
                NumberButton(item: item) { character in
                    services.actionHandler.handle(.character(character))
                    services.feedbackService.triggerHapticFeedback(.lightImpact)
                    services.feedbackService.triggerAudioFeedback(.input)
                }
            }
        }
        .padding(EdgeInsets.init(top: 0, leading: 5, bottom: 5, trailing: 5))
        .environmentObject(keyboardContext)
    }
}

struct NumberButton: View {
    @EnvironmentObject var keyboardContext: KeyboardContext
    let item: NumberButtonItem
    var action: (_ character: String) -> Void

    var body: some View {
        Button(keyboardContext.keyboardCase == .uppercased ? item.uppercased : item.lowercased) {
            if keyboardContext.keyboardCase == .uppercased {
                action(item.uppercased)
            } else {
                action(item.lowercased)
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGray6))
            .foregroundColor(.primary)
            .cornerRadius(5)
            .shadow(color: Color.black.opacity(0.2), radius: 0.5, x: 0, y: 1)
            .font(.system(size: 22))
            .buttonStyle(PlainButtonStyle())
        
        
        
    }
}

struct NumberButtonItem: Identifiable {
    var id: String { neutral }
    let neutral: String
    let uppercased: String
    let lowercased: String
}

extension NumberButtonItem {
    static var items: [NumberButtonItem] {
        [
            NumberButtonItem(neutral: "`", uppercased: "~", lowercased: "`"),
            NumberButtonItem(neutral: "1", uppercased: "!", lowercased: "1"),
            NumberButtonItem(neutral: "2", uppercased: "@", lowercased: "2"),
            NumberButtonItem(neutral: "3", uppercased: "#", lowercased: "3"),
            NumberButtonItem(neutral: "4", uppercased: "$", lowercased: "4"),
            NumberButtonItem(neutral: "5", uppercased: "%", lowercased: "5"),
            NumberButtonItem(neutral: "6", uppercased: "^", lowercased: "6"),
            NumberButtonItem(neutral: "7", uppercased: "&", lowercased: "7"),
            NumberButtonItem(neutral: "8", uppercased: "*", lowercased: "8"),
            NumberButtonItem(neutral: "9", uppercased: "(", lowercased: "9"),
            NumberButtonItem(neutral: "0", uppercased: ")", lowercased: "0"),
            NumberButtonItem(neutral: "-", uppercased: "_", lowercased: "-"),
            NumberButtonItem(neutral: "=", uppercased: "+", lowercased: "=")
        ]
    }
}
