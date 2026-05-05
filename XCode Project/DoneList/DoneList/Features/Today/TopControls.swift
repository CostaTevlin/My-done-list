// TopControls.swift
// Superseded by native nav-bar toolbar items in TodayView (ADR-0010 follow-up,
// 2026-05-04). Kept as a thin shim so any stale references still compile while
// the file is queued for removal from the Xcode project. Safe to delete.

import SwiftUI

@available(*, deprecated, message: "Replaced by TodayView's native .toolbar items.")
struct TopControls: View {
    let onSearch:  () -> Void
    let onReflect: () -> Void
    let onMore:    () -> Void

    var body: some View { EmptyView() }
}
