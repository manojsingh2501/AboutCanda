//  Copyright © 2019 Cognizant. All rights reserved.

import Foundation
import Result
import ReactiveCocoa
import ReactiveSwift


struct WebServices {
    let session: Session

    init(session: Session = URLSession(configuration: .default)) {
        self.session = session
    }

    func fetchAboutCanada(completionHandler: @escaping (Result<Country, WebServices.Error>) -> Void) {
        guard let url = URL(string: "https://dl.dropboxusercontent.com/s/2iodh4vg0eortkl/facts.json") else {
            completionHandler(.failure(.malformedRequest))
            return
        }
        
        session.dataTask(with: URLRequest(url: url)) { data, response, error in
            let jsonDecoder = JSONDecoder()
            guard let data = data,
                let utfData = String(data: data, encoding: .ascii)?.data(using: .utf8),
                let canada = try? jsonDecoder.decode(Country.self, from: utfData) else {
                    completionHandler(.failure(.deserializing))
                    return
            }
            completionHandler(.success(canada))
        }.resume()
    }
}

extension WebServices {
    enum Error: Swift.Error {
        case network(Swift.Error)
        case malformedRequest
        case deserializing
        case unknown
    }
}
