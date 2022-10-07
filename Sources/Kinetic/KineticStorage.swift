import Foundation
import struct Solana.Account
import struct Solana.PublicKey

public class KineticStorage  {
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

public extension KineticStorage {

    // MARK: Account Operations
    func addAccount(_ account: Account) throws -> Account {
        try addAccountToSecureStore(account: account)
        try writeAccountFile(account)
        return account
    }

    internal func hasPrivateKey(_ publicKey: SolanaPublicKey) -> Bool {
        do {
            return try getAccountFromSecureStore(publicKey: publicKey) != nil
        } catch {
            return false
        }
    }

    internal func getAccount(_ publicKey: SolanaPublicKey) -> Account? {
        do {
            return try getAccountFromSecureStore(publicKey: publicKey)
        } catch {
            return nil
        }
    }

    internal func removeAccount(publicKey: SolanaPublicKey) async throws {
        try await removeAccountFromSecureStore(publicKey: publicKey)
        let accountDirectory = self.directoryForAccount(publicKey)
        return try self.removeFileOrDirectory(accountDirectory)
    }

    func getAllAccountIds() -> [PublicKey] {
        guard let contents = try? fileManager.contentsOfDirectory(at: directoryForAllAccounts, includingPropertiesForKeys: nil) else {
            return []
        }

        let publicKeys = contents
            .compactMap { PublicKey(string: $0.lastPathComponent) }

        return publicKeys
    }

    func clearStorage() throws {
        return try removeFileOrDirectory(rootDirectory)
    }
}

// MARK: Private - File Location
private extension KineticStorage {
    var directoryForAllAccounts: URL {
        return rootDirectory.appendingPathComponent("kin_accounts", isDirectory: true)
    }

    func directoryForAccount(_ account: SolanaPublicKey) -> URL {
        return directoryForAllAccounts.appendingPathComponent(account.base58EncodedString, isDirectory: true)
    }
}

// MARK: Private - File Operations
private extension KineticStorage {
    func writeAccountFile(_ account: Account) throws {
        let accountDirectory = directoryForAccount(account.publicKey)
        try fileManager.createDirectory(at: accountDirectory,
                                        withIntermediateDirectories: true)
    }

    func removeFileOrDirectory(_ url: URL) throws {
        if self.fileManager.fileExists(atPath: url.path) {
            try self.fileManager.removeItem(at: url)
        }
    }
}

// MARK: Private - Key Store Access
private extension KineticStorage {
    func addAccountToSecureStore(account: Account) throws {
        let encodedAccount = try JSONEncoder().encode(account)
        let accountString = String(data: encodedAccount, encoding: .utf8)!
        try keyStore.add(account: account.publicKey.base58EncodedString, key: accountString)
    }

    func getAccountFromSecureStore(publicKey: SolanaPublicKey) throws -> Account? {
        guard let accountJSON = keyStore.retrieve(account: publicKey.base58EncodedString) else {
            return nil
        }
        let accountData = accountJSON.data(using: String.Encoding.utf8)!
        let decodedAccount = try JSONDecoder().decode(Account.self, from: accountData)
        if decodedAccount.phrase.count != 48 { // TODO: Stop Solana SDK from making fake mnemonics and change this check
            guard let account = Account(phrase: decodedAccount.phrase, network: .mainnetBeta) else {
                throw(Errors.unknown)
            }
            return account
        } else {
            guard let account = Account(secretKey: decodedAccount.secretKey) else {
                throw(Errors.unknown)
            }
            return account
        }
    }

    func removeAccountFromSecureStore(publicKey: SolanaPublicKey) async throws {
        try keyStore.delete(account: publicKey.base58EncodedString)
    }
}
