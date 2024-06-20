//
//  Connectivity.swift
//  Kode
//
//  Created by Boran Seckin on 2023-01-30.
//

#if os(iOS) || os(watchOS)
import Foundation
import SwiftUI
import WatchConnectivity

enum Delivery {
    /// Deliver immediately. No retries on failure.
    case failable

    /// Deliver as soon as possible. Automatically retries on failure.
    /// All instances of the data will be transferred sequentially.
    case guaranteed

    /// High priority data like app settings. Only the most recent value is
    /// used. Any transfers of this type not yet delivered will be replaced
    /// with the new one.
    case highPriority
}

struct TransferrableAccount {
    var id: UUID
    var type: Types = .TOTP
    var secret: String
    var issuer: String
    var algorithm: Algorithms = .SHA1
    var digits: Digits = .SIX
    var counter: Int?
    var user: String
    var label: String?
    var code: String = "000000"
    var order: Int = 999
    
    init(dict: [String: String]) {
        self.id = UUID(uuidString: dict["id"]!)!
        self.secret = dict["secret"]!
        self.type = Types(rawValue: dict["type"]!)!
        self.issuer = dict["issuer"]!
        self.issuer = dict["issuer"]!
        self.algorithm = Algorithms(rawValue: dict["algorithm"]!)!
        self.digits = Digits(rawValue: Int(dict["digits"]!)!)!
        self.counter = Int(dict["counter"]!)
        self.user = dict["user"]!
        self.label = dict["label"] ?? nil
        self.code = dict["code"]!
        self.order = Int(dict["order"]!)!
    }

    init(account: Account) {
        self.id = account.id
        self.type = account.type
        self.secret = account.secret
        self.issuer = account.issuer
        self.algorithm = account.algorithm
        self.digits = account.digits
        self.user = account.user
        self.label = account.label
        self.code = account.code
        self.order = account.order
    }

    func toDict() -> [String: String] {
        var dict = [String: String]()
        dict["id"] = id.uuidString
        dict["type"] = type.rawValue
        dict["secret"] = secret
        dict["issuer"] = issuer
        dict["algorithm"] = algorithm.rawValue
        dict["digits"] = String(digits.rawValue)
        dict["counter"] = order.description
        dict["user"] = user
        dict["label"] = label ?? nil
        dict["code"] = code
        dict["order"] = order.description
        return dict
    }

    func toAccount() -> Account {
        return Account(
            id: id,
            type: type,
            secret: secret,
            issuer: issuer,
            algorithm: algorithm,
            digits: digits,
            user: user,
            label: label,
            code: code,
            order: order
        )
    }
}

// MARK: - Connectivity
final class Connectivity: NSObject, ObservableObject {
    @Published var accounts = [Account]()
    @Published var enabled = false

    @AppStorage("WatchSync") private var watch = true

    static let standard = Connectivity()

    override private init() {
        super.init()

        #if !os(watchOS)
        guard WCSession.isSupported() else { return }
        #else
        enabled = UserDefaults.standard.bool(forKey: "watch-enabled")
        print("Enabled: \(enabled)")
            
        if let data = UserDefaults.standard.data(forKey: "watch-accounts") {
            print("Fetched local data")
            accounts = Bundle.main.decode([Account].self, from: data)
        }
        #endif

        WCSession.default.delegate = self
        WCSession.default.activate()
    }
    
    public func isAvailable() -> Bool {
        #if os(iOS)
        return WCSession.default.activationState == .activated
        #else
        return false
        #endif
    }

    public func send(accounts: [[String: String]], delivery: Delivery) {
        guard WCSession.default.activationState == .activated else { return }

        #if os(watchOS)
        guard WCSession.default.isCompanionAppInstalled else { return }
        #else
        guard WCSession.default.isWatchAppInstalled else { return }
        #endif

        switch delivery {
        case .failable:
            break

        case .guaranteed:
            WCSession.default.transferUserInfo(["accounts": accounts])

        case .highPriority:
            do {
                try WCSession.default.updateApplicationContext([
                    "accounts": accounts,
                    "enabled": watch
                ])
            } catch {
                print(error)
            }
        }
    }
}

// MARK: - WCSessionDelegate
extension Connectivity: WCSessionDelegate {
    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        print("activationDidCompleteWith activationState:\(activationState) error:\(String(describing: error))")
    }

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("sessionDidBecomeInactive: \(session)")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        print("sessionDidDeactivate: \(session)")
        // If the person has more than one watch, and they switch,
        // reactivate their session on the new device.
        WCSession.default.activate()
    }
    #endif

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        print(userInfo)
    }

    #if os(watchOS)
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        if let enabled = applicationContext["enabled"] {
            print("Sync Enabled: \(enabled)")
            DispatchQueue.main.async {
                Connectivity.standard.enabled = enabled as! Bool

                UserDefaults.standard.set(enabled as! Bool, forKey: "watch-enabled")
            }
        }

        if let transfer = applicationContext["accounts"] {
            print("Recieved")
            DispatchQueue.main.async {
                Connectivity.standard.accounts = []

                for account in transfer as! [[String: String]] {
                    Connectivity.standard.accounts.append(
                        TransferrableAccount(dict: account).toAccount()
                    )
                }
                
                let data = Bundle.main.encode([Account].self, data: Connectivity.standard.accounts)
                UserDefaults.standard.set(data, forKey: "watch-accounts")
                print("Saved locally")
            }
        }
    }
    #endif
}
#endif
