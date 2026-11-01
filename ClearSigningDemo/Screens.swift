import SwiftUI

// The wallet's screen: a transaction shown two ways. Clear = what it does, in words. Blind = the raw bytes.

enum Ink {
    static let paper = Color(red: 0.96, green: 0.97, blue: 0.96)
    static let text = Color(red: 0.08, green: 0.08, blue: 0.09)
    static let dim = Color(red: 0.45, green: 0.46, blue: 0.48)
    static let red = Color(red: 0.86, green: 0.16, blue: 0.14)
    static let green = Color(red: 0.13, green: 0.73, blue: 0.33)
    static let bar = Color(red: 0.11, green: 0.11, blue: 0.12)
}

func mono(_ size: CGFloat, _ weight: Font.Weight = .bold) -> Font {
    .system(size: size, weight: weight, design: .monospaced)
}

struct TopBar: View {
    let you: String
    let clear: Bool
    var body: some View {
        HStack(spacing: 10) {
            Blockie(address: you, size: 28)
            Text("from " + short(you)).font(mono(15, .semibold)).foregroundStyle(.white)
            Spacer()
            Text(clear ? "CLEAR" : "BLIND").font(mono(13)).foregroundStyle(.white)
                .padding(.horizontal, 9).padding(.vertical, 4)
                .background(clear ? Ink.green : Ink.red, in: Capsule())
        }
        .padding(.horizontal, 14).padding(.vertical, 9)
        .background(Ink.bar)
    }
}

func short(_ a: String) -> String { String(a.prefix(6)) + "…" + String(a.suffix(4)) }

struct ClearScreen: View {
    let tx: Tx
    var body: some View {
        let c = tx.clear
        VStack(spacing: 14) {
            VStack(spacing: 2) {
                Text(c.app).font(mono(16, .semibold)).foregroundStyle(Ink.dim)
                Text(c.action).font(mono(34)).foregroundStyle(c.danger == true ? Ink.red : Ink.text)
                    .multilineTextAlignment(.center).minimumScaleFactor(0.6).lineLimit(2)
            }
            if let w = c.warning {
                Text(w).font(mono(16)).foregroundStyle(.white).multilineTextAlignment(.center)
                    .padding(10).frame(maxWidth: .infinity).background(Ink.red, in: RoundedRectangle(cornerRadius: 8))
            }
            ForEach(c.rows, id: \.self) { RowView(row: $0) }
        }
        .padding(.horizontal, 16)
    }
}

struct RowView: View {
    let row: Row
    var body: some View {
        let ink = row.danger == true ? Ink.red : Ink.text
        VStack(spacing: 4) {
            Text(row.label).font(mono(14, .semibold)).foregroundStyle(Ink.dim)
            if let a = row.address {
                HStack(spacing: 10) {
                    Blockie(address: a, size: 40)
                    VStack(alignment: .leading, spacing: 2) {
                        if let n = row.name { Text(n).font(mono(20)).foregroundStyle(ink) }
                        Text(a).font(mono(13, .medium)).foregroundStyle(ink).fixedSize(horizontal: false, vertical: true)
                    }
                }
            } else if let v = row.value {
                HStack(spacing: 8) {
                    if let i = row.icon { TokenIcon(name: i, size: row.big == true ? 30 : 22) }
                    Text(v).font(mono(row.big == true ? 28 : 20)).foregroundStyle(ink)
                        .minimumScaleFactor(0.5).lineLimit(1)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct TokenIcon: View {
    let name: String
    var size: CGFloat = 26
    var body: some View {
        let (fill, mark): (Color, String) = switch name {
        case "usdc": (Color(red: 0.16, green: 0.46, blue: 0.79), "$")
        case "eth": (Color(red: 0.38, green: 0.40, blue: 0.47), "Ξ")
        case "steth": (Color(red: 0.0, green: 0.64, blue: 1.0), "Ξ")
        default: (Color(red: 0.93, green: 0.55, blue: 0.13), "◆")
        }
        Circle().fill(fill).frame(width: size, height: size)
            .overlay(Text(mark).font(.system(size: size * 0.6, weight: .heavy)).foregroundStyle(.white))
    }
}

struct BlindScreen: View {
    let tx: Tx
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(tx.isMessage ? "Sign message" : "Sign transaction").font(mono(28)).foregroundStyle(Ink.text)
                .frame(maxWidth: .infinity).minimumScaleFactor(0.6).lineLimit(1)
            field("To", tx.to)
            if tx.isMessage {
                field("Domain hash", tx.domainHash ?? "")
                field("Message hash", tx.messageHash ?? "")
            } else {
                field("Value", tx.value ?? "0 ETH", big: true)
                field("Data", tx.data ?? "0x")
            }
        }
        .padding(.horizontal, 16)
    }

    func field(_ label: String, _ v: String, big: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label).font(mono(14, .semibold)).foregroundStyle(Ink.dim)
            Text(v).font(mono(big ? 22 : 14, big ? .bold : .medium)).foregroundStyle(Ink.text)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

/// One transaction on the wallet's screen, in the mode picked.
struct WalletScreen: View {
    let you: String
    let tx: Tx
    let clear: Bool

    var body: some View {
        VStack(spacing: 0) {
            TopBar(you: you, clear: clear)
            ScrollView {
                Group {
                    if clear { ClearScreen(tx: tx) } else { BlindScreen(tx: tx) }
                }
                .padding(.vertical, 16)
            }
            .scrollIndicators(.visible)
            Text(tx.chain).font(mono(14, .semibold)).foregroundStyle(Ink.dim)
                .frame(maxWidth: .infinity).padding(.vertical, 6)
        }
        .background(Ink.paper)
    }
}
