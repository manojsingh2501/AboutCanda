//  © News Pty Limited 2019. All rights reserved.

import Foundation
@testable import AboutCanada

class MockDataTask: SessionDataTask {
    var resumeCalled: (() -> Void)?
    
    fileprivate var callback: ((MockDataTask) -> Void)?
    
    func resume() {
        resumeCalled?()
        // Simulates the network request going out and coming back, allows the owner of this data task to call its completion handler asynchronously.
        self.callback?(self)
    }
    
    func cancel() {}
    func suspend() {}
}

class MockSession: Session {
    var dataTaskWithRequestCalled: ((_ request: URLRequest) -> (data: Data?, response: URLResponse?, error: Error?))?
    
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> SessionDataTask {
        // When the user calls `resume` on this data task, the MockDataTask calls the block specified by its `callback` property so that this method can end up calling its completion block. This simulates the network request resolving.
        let task = MockDataTask()
        
        guard let dataTaskWithRequestCalled = self.dataTaskWithRequestCalled else {
            fatalError("The MockSession's dataTaskWithRequest method was called but the mock did not define the `dataTaskWithRequestCalled` block")
        }
        
        let (data, response, error) = dataTaskWithRequestCalled(request)
        
        task.callback = { task in
            completionHandler(data, response, error)
        }
        
        return task
    }
}
