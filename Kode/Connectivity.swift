//
//  Connectivity.swift
//  Kode
//
//  Created by Boran Seckin on 2023-01-30.
//

import Foundation
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
    var secret: String
    var issuer: String
    var email: String
    var label: String?
    var code: String

    init(id: String, secret: String, issuer: String, email: String, label: String?, code: String) {
        self.id = UUID(uuidString: id)!
        self.secret = secret
        self.issuer = issuer
        self.email = email
        self.label = label
        self.code = code
    }

    init(account: Account) {
        self.id = account.id
        self.secret = account.secret
        self.issuer = account.issuer
        self.email = account.email
        self.label = account.label
        self.code = account.code
    }

    func toDict() -> [String: String] {
        var dict = [String: String]()
        dict["id"] = id.uuidString
        dict["secret"] = secret
        dict["issuer"] = issuer
        dict["email"] = email
        dict["label"] = label ?? nil
        dict["code"] = code
        return dict
    }

    func toAccount() -> Account {
        return Account(id: id, secret: secret, issuer: issuer, email: email, label: label, code: code)
    }
}

// MARK: - Connectivity
final class Connectivity: NSObject, ObservableObject {
    @Published var accounts = [Account]()

    static let standard = Connectivity()

    override private init() {
        super.init()

        #if !os(watchOS)
        guard WCSession.isSupported() else { return }
        #else
        if let data = UserDefaults.standard.data(forKey: "watch-accounts") {
            print("Fetched local data")
            accounts = Bundle.main.decode([Account].self, from: data)
        }
        #endif

        WCSession.default.delegate = self
        WCSession.default.activate()
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
                try WCSession.default.updateApplicationContext(["accounts": accounts])
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
        if let transfer = applicationContext["accounts"] {
            print("Recieved")
            DispatchQueue.main.async {
                Connectivity.standard.accounts = []

                for account in transfer as! [[String: String]] {
                    Connectivity.standard.accounts.append(
                        TransferrableAccount(
                            id: account["id"]!,
                            secret: account["secret"]!,
                            issuer: account["issuer"]!,
                            email: account["email"]!,
                            label: account["label"] ?? nil,
                            code: account["code"]!
                        ).toAccount()
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
