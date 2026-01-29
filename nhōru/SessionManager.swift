import Foundation
import SwiftUI
import UIKit

@MainActor
final class SessionManager: ObservableObject {

    // MARK: - Singleton
    static let shared = SessionManager()
    private init() {
        startNewSession()
        observeAppLifecycle()
    }

    // MARK: - Limits
    private let maxSubmissionsPerSession = 10
    var maxCharactersPerSubmission = 10
    private let sessionCooldownSeconds: TimeInterval = 10 * 1 // 10 minutes
    private let backgroundResetSeconds: TimeInterval = 5 * 2  // ~5 minutes

    // MARK: - Published State (SwiftUI)
    @Published private(set) var submissionCount: Int = 1
    @Published private(set) var isInputDisabled: Bool = false
    @Published private(set) var helperText: String = ""
    @Published private(set) var systemMessage: String = ""
    @Published private(set) var canSubmit: Bool = true

    // MARK: - Internal State
    private var sessionStartTime: Date = Date()
    private var backgroundEnteredAt: Date?
    private var cooldownTimer: Timer?

    // MARK: - Session Lifecycle
    func startNewSession() {
        submissionCount = 0
        isInputDisabled = false
        canSubmit = true
        helperText = ""
        systemMessage = ""
        sessionStartTime = Date()
        invalidateCooldown()
    }

    // MARK: - Submission Handling
    func validateCharacters(_ count: Int) {
        if count >= maxCharactersPerSubmission {
            helperText = "Character limit reached (\(maxCharactersPerSubmission) max)"
        } else {
           helperText = ""
        }
    }

    func registerSubmission() {
        guard canSubmit else { return }
        submissionCount += 1
        if submissionCount >= maxSubmissionsPerSession {
            reachSessionLimit()
        }
    }

    // MARK: - Session Limit Reached
    private func reachSessionLimit() {
        isInputDisabled = true
        canSubmit = false
        helperText = ""
        systemMessage = """
        We’ll pause here for now.
        Small sessions work best here.
        You can restart in 10 minutes.
        """
        startCooldown()
    }

    // MARK: - Cooldown
    private func startCooldown() {
        invalidateCooldown()
        cooldownTimer = Timer.scheduledTimer(withTimeInterval: sessionCooldownSeconds, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.startNewSession()
            }
        }
    }

    private func invalidateCooldown() {
        cooldownTimer?.invalidate()
        cooldownTimer = nil
    }

    // MARK: - App Lifecycle Handling
    private func observeAppLifecycle() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenDidLock),
            name: UIApplication.protectedDataWillBecomeUnavailableNotification,
            object: nil
        )
    }

    @objc private func appDidEnterBackground() {
        backgroundEnteredAt = Date()
    }

    @objc private func appWillEnterForeground() {
        guard let backgroundTime = backgroundEnteredAt else { return }
        let elapsed = Date().timeIntervalSince(backgroundTime)

        if elapsed >= backgroundResetSeconds {
            startNewSession()
        }
        backgroundEnteredAt = nil
    }

    @objc private func screenDidLock() {
        startNewSession()
    }
}
