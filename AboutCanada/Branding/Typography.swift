//  Copyright © 2019 Cognizant. All rights reserved.

import UIKit

private let primaryFontName = "Helvetica"
private let primaryBoldFontName = "Helvetica-Bold"

struct Typography {
    func primaryFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: primaryFontName, size: size)!
    }
    
    func primaryBoldFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: primaryBoldFontName, size: size)!
    }
}
