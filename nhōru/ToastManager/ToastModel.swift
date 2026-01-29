struct Toast: Equatable {
    var type: ToastViewStyle
    var title: String
    var message: String
    var duration: Double = 5
    var enableDonotShowAgainBtn: Bool = false
}
