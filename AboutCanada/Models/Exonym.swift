//  Copyright © 2019 Cognizant. All rights reserved.

import Foundation

struct Country: Decodable {
    let title: String
    let exonyms: [Exonym]
}

private extension Country {
    enum CodingKeys: String, CodingKey {
        case title
        case exonyms = "rows"
    }
}

extension Country {
    struct Exonym: Decodable {
        var title: String?
        var description: String?
        var imageURL: URL?
    }
}

private extension Country.Exonym {
    enum CodingKeys: String, CodingKey {
        case title
        case description
        case imageURL = "imageHref"
    }
}
