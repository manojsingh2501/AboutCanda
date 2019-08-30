//  Copyright © 2019 Cognizant. All rights reserved.

import Foundation

protocol SessionDataTask {
    func resume()
    func cancel()
    func suspend()
}

extension URLSessionDataTask: SessionDataTask {}

/// This Session protocol is used for supporting MockSession and URLSession. 
protocol Session {
    func dataTask(with urlRequest: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> SessionDataTask
}

extension URLSession: Session {
    func dataTask(with urlRequest: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> SessionDataTask {
        let sessionDataTask = dataTask(with: urlRequest, completionHandler: completionHandler) as URLSessionDataTask
        return sessionDataTask as SessionDataTask
    }
}
