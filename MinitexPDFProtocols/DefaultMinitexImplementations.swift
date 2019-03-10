import Foundation

final class DefaultMinitexPDFPage : MinitexPDFPage {
    var pageNumber: UInt

    init(pageNumber: UInt) {
        self.pageNumber = pageNumber
    }
}
