import SwiftUI
import UIOnboarding
import UIKit
import UIOnboarding

struct UIOnboardingHelper {
    static func setUpIcon() -> UIImage {
        return .init(systemName: "keyboard.fill")!
    }

    static func setUpFirstTitleLine() -> NSMutableAttributedString {
        .init(string: "Welcome to")
    }
    
    static func setUpSecondTitleLine() -> NSMutableAttributedString {
        .init(string: "Colemak")
    }

    static func setUpFeatures() -> Array<UIOnboardingFeature> {
        return .init([
            .init(icon: .init(systemName: "1.circle")!,
                  iconTint: .lightGray,
                  title: "Setup",
                  description: "Open the Settings app and navigate to General > Keyboards."),
            .init(icon: .init(systemName: "2.circle")!,
                  iconTint: .lightGray,
                  title: "Enjoy",
                  description: "Pick any of the 4 available keyboards."),
            .init(icon: .init(systemName: "3.circle")!,
                  iconTint: .lightGray,
                  title: "Clean",
                  description: "Hide the app icon from the home screen."),
            .init(icon: .init(systemName: "4.circle")!,
                  iconTint: .lightGray,
                  title: "Review",
                  description: "Helps a lot!"),
        ])
    }

    static func setUpNotice() -> UIOnboardingTextViewConfiguration {
        return .init( text: "Colemak is Open Source software and does not log anything (installs, analytics, or crashes).")
    }

    static func setUpButton() -> UIOnboardingButtonConfiguration {
        return .init(title: "Open Settings", backgroundColor: .black)
    }
}


extension UIOnboardingViewConfiguration {
    static func setUp() -> UIOnboardingViewConfiguration {
        return .init(appIcon: UIOnboardingHelper.setUpIcon(),
                     firstTitleLine: UIOnboardingHelper.setUpFirstTitleLine(),
                     secondTitleLine: UIOnboardingHelper.setUpSecondTitleLine(),
                     features: UIOnboardingHelper.setUpFeatures(),
                     textViewConfiguration: UIOnboardingHelper.setUpNotice(),
                     buttonConfiguration: UIOnboardingHelper.setUpButton())
    }
}

struct ContentView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIOnboardingViewController

    func makeUIViewController(context: Context) -> UIOnboardingViewController {
        let onboardingController: UIOnboardingViewController = .init(withConfiguration: .setUp())
        onboardingController.delegate = context.coordinator
        return onboardingController
    }
    
    func updateUIViewController(_ uiViewController: UIOnboardingViewController, context: Context) {}
    
    class Coordinator: NSObject, @preconcurrency UIOnboardingViewControllerDelegate {
        @MainActor func didFinishOnboarding(onboardingViewController: UIOnboardingViewController) {
            onboardingViewController.modalTransitionStyle = .crossDissolve
            onboardingViewController.dismiss(animated: true) {
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return .init()
    }
}
