import SwiftUI

// Clear Signing Demo: a pretend hardware wallet. ▲▼ switch the screen between clear signing and blind
// signing. Green (yes) or red (no) moves on to the next transaction. Nothing is ever signed or sent.

@main
struct ClearSigningDemoApp: App {
    var body: some Scene {
        WindowGroup { DeviceView().preferredColorScheme(.dark) }
    }
}

struct DeviceView: View {
    private let demo = Demo.shared
    // launch arguments for screenshots: -index 3 -blind YES
    @State private var index = min(UserDefaults.standard.integer(forKey: "index"), Demo.shared.transactions.count - 1)
    @State private var clear = !UserDefaults.standard.bool(forKey: "blind")
    @State private var stamp: Bool? = nil          // true = signed, false = rejected, shown for a moment
    @State private var forward = true               // which way the screen slides on a mode switch

    private let body1 = Color(red: 0.13, green: 0.13, blue: 0.15)

    var body: some View {
        VStack(spacing: 18) {
            HStack {
                Text("Clear Signing Demo").font(mono(17)).foregroundStyle(.white.opacity(0.85))
                Spacer()
                Text("\(index + 1) / \(demo.transactions.count)").font(mono(17, .semibold)).foregroundStyle(.white.opacity(0.5))
            }
            .padding(.horizontal, 6)

            screen
            controls
        }
        .padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 12)
        .frame(maxWidth: 520)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(body1.ignoresSafeArea())
    }

    private var screen: some View {
        ZStack {
            WalletScreen(you: demo.you, tx: demo.transactions[index], clear: clear)
                .id("\(index)-\(clear)")
                .transition(.asymmetric(insertion: .move(edge: forward ? .bottom : .top),
                                        removal: .move(edge: forward ? .top : .bottom)).combined(with: .opacity))
            if let s = stamp {
                VStack(spacing: 8) {
                    Image(systemName: s ? "checkmark.circle.fill" : "xmark.circle.fill").font(.system(size: 88, weight: .bold))
                    Text(s ? "Signed" : "Rejected").font(mono(34))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background((s ? Ink.green : Ink.red).opacity(0.94))
                .transition(.opacity)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(10)
        .background(Color.black, in: RoundedRectangle(cornerRadius: 22))
    }

    private var controls: some View {
        HStack(alignment: .center, spacing: 14) {
            VStack(spacing: 8) {
                Key(system: "chevron.up", tint: Color(white: 0.32)) { setMode(true) }
                    .opacity(clear ? 0.45 : 1)
                Key(system: "chevron.down", tint: Color(white: 0.32)) { setMode(false) }
                    .opacity(clear ? 1 : 0.45)
            }
            VStack(alignment: .leading, spacing: 6) {
                Text("▲ clear").font(mono(15)).foregroundStyle(clear ? Ink.green : .white.opacity(0.35))
                Text("▼ blind").font(mono(15)).foregroundStyle(clear ? .white.opacity(0.35) : Ink.red)
            }
            Spacer(minLength: 0)
            RoundKey(system: "xmark", tint: Ink.red, label: "no") { answer(false) }
            RoundKey(system: "checkmark", tint: Ink.green, label: "yes") { answer(true) }
        }
        .disabled(stamp != nil)
    }

    private func setMode(_ c: Bool) {
        let to = c == clear ? !c : c                // pressing the lit arrow still flips it
        forward = !to
        withAnimation(.easeInOut(duration: 0.28)) { clear = to }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func answer(_ yes: Bool) {
        UINotificationFeedbackGenerator().notificationOccurred(yes ? .success : .error)
        withAnimation(.easeOut(duration: 0.15)) { stamp = yes }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            forward = true
            withAnimation(.easeInOut(duration: 0.3)) {
                stamp = nil
                index = (index + 1) % demo.transactions.count
            }
        }
    }
}

struct Key: View {
    let system: String
    let tint: Color
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: system).font(.system(size: 26, weight: .heavy)).foregroundStyle(.white)
                .frame(width: 72, height: 54)
                .background(tint, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(Press())
    }
}

struct RoundKey: View {
    let system: String
    let tint: Color
    let label: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: system).font(.system(size: 34, weight: .heavy)).foregroundStyle(.white)
                    .frame(width: 84, height: 84)
                    .background(tint, in: Circle())
                    .shadow(color: tint.opacity(0.5), radius: 8)
                Text(label).font(mono(15)).foregroundStyle(.white.opacity(0.75))
            }
        }
        .buttonStyle(Press())
    }
}

struct Press: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.scaleEffect(configuration.isPressed ? 0.92 : 1)
            .brightness(configuration.isPressed ? -0.08 : 0)
    }
}
