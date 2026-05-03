// SafeAreaInsetsKey.swift
// Inlined from unionst/union-confetti.

import SwiftUI
import UIKit

extension EnvironmentValues {
    @MainActor
    var safeAreaInsets: EdgeInsets {
        let insets = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })?.safeAreaInsets ?? .zero
        return EdgeInsets(top: insets.top, leading: insets.left,
                          bottom: insets.bottom, trailing: insets.right)
    }
}
