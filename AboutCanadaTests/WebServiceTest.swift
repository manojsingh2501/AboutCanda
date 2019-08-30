//  Copyright © 2019 Cognizant. All rights reserved.

import XCTest
@testable import AboutCanada

class WebServiceTest: XCTestCase {

    var webServices: WebServices?
    override func setUp() {
        webServices = WebServices(session: MockSession())
        (webServices?.session as! MockSession).dataTaskWithRequestCalled = { request in
            return (self.loadSampleData(forResource: "AboutCanada"), URLResponse(), nil)
        }
    }

    override func tearDown() {
        webServices = nil
    }
    
    func testAboutCanada() {
        webServices?.fetchAboutCanada { result in
            switch result {
            case .success (let canada):
                XCTAssert(!canada.abouts.isEmpty, "Abouts is empty")
            case .failure:
                XCTFail("Unable to fetch about canada")
            }
        }
    }
    
    func testAboutCandaModelDecoding() {
        webServices?.fetchAboutCanada { result in
            switch result {
            case .success (let canada):
                XCTAssert(!canada.abouts.isEmpty, "About canada is empty")
                guard let about = canada.abouts.first else { return }
                XCTAssert(about.title == "Beavers", "Title is not as per expection")
                XCTAssert(about.description == "Beavers are second only to humans in their ability to manipulate and change their environment. They can measure up to 1.3 metres long. A group of beavers is called a colony", "Description is not as per expection")
                XCTAssert(about.imageURL == URL(string: "http://upload.wikimedia.org/wikipedia/commons/thumb/6/6b/American_Beaver.jpg/220px-American_Beaver.jpg"), "Image URL is not as per expection")
            case .failure:
                XCTFail("Unable to fetch about canada")
            }
        }
    }
    
    private func loadSampleData(forResource name: String) -> Data? {
        let testBundle = Bundle(for: WebServiceTest.self)
        guard let filePath = testBundle.url(forResource: name, withExtension: "json") else { return nil }
        return try? Data(contentsOf: filePath)
    }

}
