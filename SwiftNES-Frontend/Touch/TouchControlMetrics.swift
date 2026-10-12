/// Sizes shared by the on-screen controls.
enum TouchControlMetrics {
    static let dPadSize = 150.0
    static let faceButtonSize = 64.0
    static let menuButtonWidth = 64.0
    static let menuButtonHeight = 28.0

    /// Apple's minimum comfortable tap target.
    static let minimumTapSize = 44.0

    /// Touches this close to the D-pad's center, as a fraction of its size,
    /// press nothing, so resting a thumb there doesn't pick a direction.
    static let dPadDeadZone = 0.12
}
