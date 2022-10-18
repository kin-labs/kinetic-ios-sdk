import Foundation
import Kinetic

public class BasicAccountStorage  {
    public enum Errors: Error {
        case unknown
        case malformattedInput
        case missingAccount
        case unregisteredAccount
    }

    private let fileManager = FileManager.default
    private let userDefaults = UserDefaults.standard
    private let rootDirectory: URL
    private let keyStore: SecureKeyStorage = KeyChainStorage()

    /// - Parameters:
    ///   - directory: the directory where the files will be stored, use document directory if icloud backup is desired
    public init(directory: URL = URL(fileURLWithPath: NSTemporaryDirectory())) {
        self.rootDirectory = directory
    }
}

public extension BasicAccountStorage {

    // MARK: Convenience functions
    func getLocalKeypair(_ publicKey: String? = nil) -> Keypair? {
        let keys = getAllKeys()
        if keys.isEmpty {
            return nil
        }
        return getKeypair(keys[0])
    }

    func createLocalKeypair() -> Keypair? {
        do {
            let keypair = Keypair.random()
            try addKeypairToSecureStore(keypair)
            return keypair
        } catch {
            return nil
        }
    }
}

public extension BasicAccountStorage {

    // MARK: Account Operations
    func addKeypair(_ keypair: Keypair) throws -> Keypair {
        try addKeypairToSecureStore(keypair)
        try writeKeypairFile(keypair)
        return keypair
    }

    internal func hasPrivateKey(_ publicKey: String) -> Bool {
        do {
            try getKeypairFromSecureStore(publicKey)
            return true
        } catch {
            return false
        }
    }

    internal func getKeypair(_ publicKey: String) -> Keypair? {
        do {
            return try getKeypairFromSecureStore(publicKey)
        } catch {
            return nil
        }
    }

    internal func removeAccount(publicKey: String) async throws {
        try await removeKeypairFromSecureStore(publicKey: publicKey)
        let keypairDirectory = self.directoryForKey(publicKey)
        return try self.removeFileOrDirectory(keypairDirectory)
    }

    func getAllKeys() -> [String] {
        guard let contents = try? fileManager.contentsOfDirectory(at: directoryForAllKeypairs, includingPropertiesForKeys: nil) else {
            return []
        }

        let publicKeys = contents
            .compactMap { $0.lastPathComponent }

        return publicKeys
    }

    func clearStorage() throws {
        return try removeFileOrDirectory(rootDirectory)
    }
}

// MARK: Private - File Location
private extension BasicAccountStorage {
    var directoryForAllKeypairs: URL {
        return rootDirectory.appendingPathComponent("kinetic_keys", isDirectory: true)
    }

    func directoryForKey(_ publicKey: String) -> URL {
        return directoryForAllKeypairs.appendingPathComponent(publicKey, isDirectory: true)
    }
}

// MARK: Private - File Operations
private extension BasicAccountStorage {
    func writeKeypairFile(_ keypair: Keypair) throws {
        let keypairDirectory = directoryForKey(keypair.publicKey)
        try fileManager.createDirectory(at: keypairDirectory,
                                        withIntermediateDirectories: true)
    }

    func removeFileOrDirectory(_ url: URL) throws {
        if self.fileManager.fileExists(atPath: url.path) {
            try self.fileManager.removeItem(at: url)
        }
    }
}

// MARK: Private - Key Store Access
private extension BasicAccountStorage {
    func addKeypairToSecureStore(_ keypair: Keypair) throws {
        let encodedKeypair = try JSONEncoder().encode(keypair)
        let keypairString = String(data: encodedKeypair, encoding: .utf8)!
        try keyStore.add(publicKey: keypair.publicKey, secret: keypairString)
    }

    func getKeypairFromSecureStore(_ publicKey: String) throws -> Keypair {
        guard let keypairJSON = keyStore.retrieve(publicKey: publicKey) else {
            throw(Errors.unknown)
        }
        let keypairData = keypairJSON.data(using: String.Encoding.utf8)!
        let decodedKeypair = try JSONDecoder().decode(Keypair.self, from: keypairData)
        return decodedKeypair
    }

    func removeKeypairFromSecureStore(publicKey: String) async throws {
        try keyStore.delete(publicKey: publicKey)
    }
}
