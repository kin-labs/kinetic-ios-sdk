import XCTest
@testable import Kinetic

final class KineticTests: XCTestCase {
    let TEST_APP_INDEX = 1
    let TEST_APP_ENVIRONMENT = "devnet"
//    let TEST_APP_ENDPOINT = "https://staging.kinetic.host"
    let TEST_APP_ENDPOINT = "http://localhost:3000"
    let TEST_SOLANA_RPC_NAME = "mainnet-beta"
    let TEST_SOLANA_RPC_ENDPOINT = "https://api.mainnet-beta.solana.com/"

    func testSdkSetup() async throws {
        let sdk = try await KineticSdk.setup(
            endpoint: TEST_APP_ENDPOINT,
            environment: TEST_APP_ENVIRONMENT,
            index: TEST_APP_INDEX
        )

        XCTAssertEqual(sdk.environment, TEST_APP_ENVIRONMENT)
        XCTAssertEqual(sdk.endpoint, TEST_APP_ENDPOINT)
        XCTAssertEqual(sdk.index, TEST_APP_INDEX)
    }
}
