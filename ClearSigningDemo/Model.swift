import Foundation

// transactions.json: the demo transactions. Each has its raw form (to, value, data, or the two hashes of a
// signed message) and its clear form (what a clear-signing wallet shows).

struct Demo: Decodable {
    let you: String
    let transactions: [Tx]

    static let shared: Demo = {
        let url = Bundle.main.url(forResource: "transactions", withExtension: "json")!
        return try! JSONDecoder().decode(Demo.self, from: Data(contentsOf: url))
    }()
}

struct Tx: Decodable {
    var kind: String?          // "message" = a signed message (EIP-712); else a transaction
    let chain: String
    let to: String
    let value: String?
    var data: String?
    var domainHash: String?
    var messageHash: String?
    let clear: Clear

    var isMessage: Bool { kind == "message" }
}

struct Clear: Decodable {
    let action: String
    let app: String
    var danger: Bool?
    var warning: String?
    let rows: [Row]
}

struct Row: Decodable, Hashable {
    let label: String
    var value: String?
    var address: String?
    var name: String?
    var icon: String?
    var big: Bool?
    var danger: Bool?
}
