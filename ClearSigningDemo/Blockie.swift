import SwiftUI

// The Ethereum blockie (ethereum-blockies): an 8x8 picture made from an address, same as wallets show.
struct Blockie: View {
    let address: String
    var size: CGFloat = 40

    var body: some View {
        let b = BlockieData(seed: address.lowercased())
        Canvas { ctx, sz in
            let px = sz.width / 8
            ctx.fill(Path(CGRect(origin: .zero, size: sz)), with: .color(b.bg))
            for (i, v) in b.cells.enumerated() where v > 0 {
                let r = CGRect(x: CGFloat(i % 8) * px, y: CGFloat(i / 8) * px, width: px + 0.5, height: px + 0.5)
                ctx.fill(Path(r), with: .color(v == 1 ? b.color : b.spot))
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}

private struct BlockieData {
    var seed: [Int32] = [0, 0, 0, 0]
    var color = Color.clear, bg = Color.clear, spot = Color.clear
    var cells: [Int] = []

    init(seed s: String) {
        for (i, ch) in s.unicodeScalars.enumerated() {
            let k = i % 4
            seed[k] = (seed[k] &<< 5) &- seed[k] &+ Int32(ch.value)
        }
        color = makeColor()
        bg = makeColor()
        spot = makeColor()
        for _ in 0..<8 {
            var row = (0..<4).map { _ in Int(floor(rand() * 2.3)) }
            row += row.reversed()
            cells += row
        }
    }

    mutating func rand() -> Double {
        let t = seed[0] ^ (seed[0] &<< 11)
        seed[0] = seed[1]; seed[1] = seed[2]; seed[2] = seed[3]
        seed[3] = seed[3] ^ (seed[3] >> 19) ^ t ^ (t >> 8)
        return Double(UInt32(bitPattern: seed[3])) / 2147483648.0
    }

    mutating func makeColor() -> Color {
        let h = floor(rand() * 360)
        let s = (rand() * 60 + 40) / 100
        let l = (rand() + rand() + rand() + rand()) * 25 / 100
        return hsl(h, s, l)
    }

    func hsl(_ h: Double, _ s: Double, _ l: Double) -> Color {
        let c = (1 - abs(2 * l - 1)) * s
        let hp = h / 60
        let x = c * (1 - abs(hp.truncatingRemainder(dividingBy: 2) - 1))
        var (r, g, b) = (0.0, 0.0, 0.0)
        switch hp {
        case ..<1: (r, g, b) = (c, x, 0)
        case ..<2: (r, g, b) = (x, c, 0)
        case ..<3: (r, g, b) = (0, c, x)
        case ..<4: (r, g, b) = (0, x, c)
        case ..<5: (r, g, b) = (x, 0, c)
        default: (r, g, b) = (c, 0, x)
        }
        let m = l - c / 2
        return Color(red: r + m, green: g + m, blue: b + m)
    }
}
