import SwiftUI

// MARK: - Accessory model

enum Accessory: String, CaseIterable, Codable {
    case cowboyHat, topHat, crown, partyHat, wizardHat, vikingHelmet, sombrero, graduationCap
    case glasses, sunglasses, monocle, eyepatch, heartGlasses
    case bowtie, bandana, tie
    case cape

    var displayName: String {
        switch self {
        case .cowboyHat:      return "Vaquero"
        case .topHat:         return "De Copa"
        case .crown:          return "Corona"
        case .partyHat:       return "Fiesta"
        case .wizardHat:      return "Mago"
        case .vikingHelmet:   return "Vikingo"
        case .sombrero:       return "Sombrero"
        case .graduationCap:  return "Birrete"
        case .glasses:        return "Gafas"
        case .sunglasses:     return "Sol"
        case .monocle:        return "Monóculo"
        case .eyepatch:       return "Parche"
        case .heartGlasses:   return "Corazones"
        case .bowtie:         return "Pajarita"
        case .bandana:        return "Pañuelo"
        case .tie:            return "Corbata"
        case .cape:           return "Capa"
        }
    }

    var emoji: String {
        switch self {
        case .cowboyHat:      return "🤠"
        case .topHat:         return "🎩"
        case .crown:          return "👑"
        case .partyHat:       return "🎉"
        case .wizardHat:      return "🧙"
        case .vikingHelmet:   return "⚔️"
        case .sombrero:       return "🪅"
        case .graduationCap:  return "🎓"
        case .glasses:        return "👓"
        case .sunglasses:     return "🕶️"
        case .monocle:        return "🧐"
        case .eyepatch:       return "🏴‍☠️"
        case .heartGlasses:   return "💝"
        case .bowtie:         return "🎀"
        case .bandana:        return "🧣"
        case .tie:            return "👔"
        case .cape:           return "🦸"
        }
    }

    // Accessories sharing a slot conflict with each other
    var slot: Int {
        switch self {
        case .cowboyHat, .topHat, .crown, .partyHat,
             .wizardHat, .vikingHelmet, .sombrero, .graduationCap: return 0
        case .glasses, .sunglasses, .monocle, .eyepatch, .heartGlasses: return 1
        case .bowtie, .bandana, .tie:                                    return 2
        case .cape:                                                       return 3
        }
    }
}

// MARK: - Raptor Room

struct RaptorRoomView: View {
    @Environment(ProgressStore.self) private var store
    @State private var isBlinking = false
    @State private var blinkTask: Task<Void, Never>?
    @State private var bounce: CGFloat = 0
    @State private var bounceTask: Task<Void, Never>?

    private var equipped: Set<Accessory> {
        Set(store.equippedAccessoryIDs.compactMap(Accessory.init(rawValue:)))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Scene
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.06, green: 0.10, blue: 0.06),
                        Color(red: 0.10, green: 0.20, blue: 0.09)
                    ],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea(edges: .top)

                HStack(spacing: 0) {
                    Spacer()
                    FernCluster().offset(x: 20, y: 40)
                }
                HStack(spacing: 0) {
                    FernCluster().scaleEffect(x: -1).offset(x: -30, y: 60)
                    Spacer()
                }

                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(red: 0.14, green: 0.28, blue: 0.10))
                    .frame(height: 55)
                    .padding(.horizontal, 24)
                    .offset(y: 92)

                VelociraptorView(equipped: equipped, isBlinking: isBlinking)
                    .frame(width: 200, height: 200)
                    .offset(y: bounce)
            }
            .frame(height: 300)
            .clipped()

            // Token bar
            VStack(spacing: 4) {
                HStack {
                    Text("🪙 \(store.accessoryTokens) token\(store.accessoryTokens == 1 ? "" : "s")")
                        .font(.headline)
                    Spacer()
                    Text("\(store.correctsToNextToken) correct answers to next token")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                ProgressView(value: Double(25 - store.correctsToNextToken), total: 25)
                    .tint(.yellow)
            }
            .padding(.horizontal)
            .padding(.top, 14)
            .padding(.bottom, 10)
            .background(.regularMaterial)

            // Accessory panel
            VStack(alignment: .leading, spacing: 10) {
                Text("Accessories")
                    .font(.headline)
                    .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Accessory.allCases, id: \.self) { acc in
                            AccessoryChip(
                                accessory: acc,
                                isEquipped: store.equippedAccessoryIDs.contains(acc.rawValue),
                                isUnlocked: store.isAccessoryUnlocked(id: acc.rawValue),
                                hasTokens: store.accessoryTokens > 0,
                                action: { toggleAccessory(acc) }
                            )
                        }
                    }
                    .padding(.horizontal)
                }

                Text(store.accessoryTokens > 0
                     ? "Tap a locked accessory to unlock it for 🪙 1 token."
                     : "Earn 25 correct answers to unlock a token.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 16)
            }
            .background(.regularMaterial)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Mongo's Room")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            startBlinking()
            startBounce()
        }
        .onDisappear {
            blinkTask?.cancel()
            bounceTask?.cancel()
        }
    }

    private func toggleAccessory(_ acc: Accessory) {
        withAnimation(.spring(response: 0.25)) {
            if store.equippedAccessoryIDs.contains(acc.rawValue) {
                store.unequipAccessory(id: acc.rawValue)
            } else if store.isAccessoryUnlocked(id: acc.rawValue) {
                for other in Accessory.allCases where other.slot == acc.slot {
                    store.unequipAccessory(id: other.rawValue)
                }
                store.equipAccessory(id: acc.rawValue)
            } else if store.accessoryTokens > 0 {
                store.unlockAccessory(id: acc.rawValue)
                for other in Accessory.allCases where other.slot == acc.slot {
                    store.unequipAccessory(id: other.rawValue)
                }
                store.equipAccessory(id: acc.rawValue)
            }
        }
    }

    private func startBlinking() {
        blinkTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(Double.random(in: 3...8)))
                guard !Task.isCancelled else { break }
                withAnimation(.easeInOut(duration: 0.07)) { isBlinking = true }
                try? await Task.sleep(for: .milliseconds(110))
                guard !Task.isCancelled else { break }
                withAnimation(.easeInOut(duration: 0.07)) { isBlinking = false }
            }
        }
    }

    private func startBounce() {
        bounceTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(Double.random(in: 4...9)))
                guard !Task.isCancelled else { break }
                withAnimation(.spring(response: 0.25, dampingFraction: 0.4)) { bounce = -10 }
                try? await Task.sleep(for: .milliseconds(450))
                guard !Task.isCancelled else { break }
                withAnimation(.spring(response: 0.4, dampingFraction: 0.55)) { bounce = 0 }
            }
        }
    }
}

private struct FernCluster: View {
    var body: some View {
        ZStack {
            Ellipse()
                .fill(Color(red: 0.12, green: 0.38, blue: 0.08).opacity(0.8))
                .frame(width: 18, height: 60)
                .rotationEffect(.degrees(-30))
                .offset(x: -8, y: -10)
            Ellipse()
                .fill(Color(red: 0.15, green: 0.45, blue: 0.10).opacity(0.8))
                .frame(width: 16, height: 75)
                .rotationEffect(.degrees(-10))
            Ellipse()
                .fill(Color(red: 0.10, green: 0.32, blue: 0.07).opacity(0.7))
                .frame(width: 14, height: 55)
                .rotationEffect(.degrees(15))
                .offset(x: 6, y: 5)
        }
    }
}

private struct AccessoryChip: View {
    let accessory: Accessory
    let isEquipped: Bool
    let isUnlocked: Bool
    let hasTokens: Bool
    let action: () -> Void

    var body: some View {
        let tappable = isUnlocked || hasTokens
        Button(action: tappable ? action : {}) {
            VStack(spacing: 4) {
                ZStack(alignment: .bottomTrailing) {
                    Text(accessory.emoji)
                        .font(.title2)
                        .opacity(isUnlocked ? 1 : 0.45)
                    if !isUnlocked {
                        Text("🪙")
                            .font(.caption2)
                            .padding(2)
                            .background(.black.opacity(0.55))
                            .clipShape(Capsule())
                            .offset(x: 4, y: 4)
                    }
                }
                .frame(width: 40, height: 38)

                Text(isUnlocked ? accessory.displayName : "Locked")
                    .font(.caption2)
                    .foregroundStyle(isEquipped ? .white : (isUnlocked ? .primary : .secondary))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(width: 72)
            .padding(.vertical, 10)
            .background(isEquipped ? Color.accentColor : Color(.secondarySystemFill))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .opacity(tappable ? 1 : 0.45)
        }
        .buttonStyle(.plain)
        .scaleEffect(isEquipped ? 1.06 : 1.0)
        .animation(.spring(response: 0.22), value: isEquipped)
    }
}

// MARK: - Velociraptor Canvas

struct VelociraptorView: View {
    let equipped: Set<Accessory>
    let isBlinking: Bool

    var body: some View {
        Canvas { ctx, size in
            let s = min(size.width / 200, size.height / 200)
            RaptorDrawer(ctx: ctx, s: s, equipped: equipped, isBlinking: isBlinking).draw()
        }
    }
}

// MARK: - Raptor Drawer (all drawing in 200×200 design space)

private struct RaptorDrawer {
    let ctx: GraphicsContext
    let s: CGFloat
    let equipped: Set<Accessory>
    let isBlinking: Bool

    // Colors
    let body    = Color(red: 0.15, green: 0.42, blue: 0.78)
    let dark    = Color(red: 0.08, green: 0.24, blue: 0.52)
    let belly   = Color(red: 0.70, green: 0.84, blue: 0.96)
    let feather = Color(red: 0.58, green: 0.14, blue: 0.82)
    let claw    = Color(red: 0.12, green: 0.09, blue: 0.05)
    let wingTip = Color(red: 0.78, green: 0.30, blue: 1.00)

    func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint { .init(x: x*s, y: y*s) }
    func rc(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> CGRect { .init(x: x*s, y: y*s, width: w*s, height: h*s) }

    func draw() {
        drawTail()
        drawBackLeg()
        if equipped.contains(.cape) { drawCape() }
        drawBody()
        drawFrontLeg()
        drawArm()
        drawWings()
        drawNeck()
        drawHead()
        drawAccessories()
    }

    private func drawTail() {
        var tail = Path()
        tail.move(to: pt(55, 118))
        tail.addCurve(to: pt(8, 48), control1: pt(18, 126), control2: pt(2, 82))
        tail.addLine(to: pt(14, 43))
        tail.addCurve(to: pt(65, 112), control1: pt(20, 78), control2: pt(40, 112))
        tail.closeSubpath()
        ctx.fill(tail, with: .color(body))

        // Tail tip feathers
        for i in 0..<5 {
            let angle = (CGFloat(i - 2) * 18 - 118) * .pi / 180
            var f = Path()
            f.move(to: pt(9, 48))
            f.addLine(to: pt(9 + cos(angle)*16, 48 + sin(angle)*16))
            ctx.stroke(f, with: .color(feather), lineWidth: 3.5*s)
        }
    }

    private func drawBackLeg() {
        var leg = Path()
        leg.move(to: pt(96, 148)); leg.addLine(to: pt(107, 150))
        leg.addLine(to: pt(103, 175)); leg.addLine(to: pt(111, 188))
        leg.addLine(to: pt(105, 191)); leg.addLine(to: pt(96, 177))
        leg.addLine(to: pt(89, 151)); leg.closeSubpath()
        ctx.fill(leg, with: .color(dark))

        var foot = Path()
        foot.move(to: pt(96, 186)); foot.addLine(to: pt(115, 182))
        foot.addLine(to: pt(116, 188)); foot.addLine(to: pt(97, 192))
        foot.closeSubpath()
        ctx.fill(foot, with: .color(dark))
    }

    private func drawBody() {
        ctx.fill(Path(ellipseIn: rc(38, 92, 102, 68)), with: .color(body))
        ctx.fill(Path(ellipseIn: rc(64, 108, 62, 46)), with: .color(belly))
    }

    private func drawFrontLeg() {
        var leg = Path()
        leg.move(to: pt(78, 150)); leg.addLine(to: pt(89, 151))
        leg.addLine(to: pt(86, 177)); leg.addLine(to: pt(94, 189))
        leg.addLine(to: pt(87, 192)); leg.addLine(to: pt(78, 179))
        leg.addLine(to: pt(70, 153)); leg.closeSubpath()
        ctx.fill(leg, with: .color(body))

        var foot = Path()
        foot.move(to: pt(78, 188)); foot.addLine(to: pt(98, 183))
        foot.addLine(to: pt(99, 189)); foot.addLine(to: pt(79, 194))
        foot.closeSubpath()
        ctx.fill(foot, with: .color(body))

        // Sickle claw — signature Velociraptor mongoliensis feature
        var sickle = Path()
        sickle.move(to: pt(78, 189))
        sickle.addCurve(to: pt(68, 198), control1: pt(72, 190), control2: pt(66, 195))
        sickle.addLine(to: pt(71, 200))
        sickle.addCurve(to: pt(82, 191), control1: pt(73, 200), control2: pt(80, 195))
        sickle.closeSubpath()
        ctx.fill(sickle, with: .color(claw))
    }

    private func drawWings() {
        // Fan of 7 wing feathers radiating from the arm pivot (~128, 122)
        let pivotX: CGFloat = 128, pivotY: CGFloat = 122
        // Each feather: (angle in degrees, length, width)
        let feathers: [(CGFloat, CGFloat, CGFloat)] = [
            (110, 52, 10),
            (128, 60, 12),
            (145, 65, 13),
            (162, 62, 12),
            (178, 55, 11),
            (194, 46, 10),
            (208, 38,  9),
        ]
        for (angle, length, width) in feathers {
            let rad = angle * .pi / 180
            let tipX = pivotX + cos(rad) * length
            let tipY = pivotY + sin(rad) * length

            // Feather: tapered from pivot toward tip
            let perpRad = rad + .pi / 2
            let hw = width / 2
            let p1 = CGPoint(x: (pivotX + cos(perpRad) * hw) * s, y: (pivotY + sin(perpRad) * hw) * s)
            let p2 = CGPoint(x: (pivotX - cos(perpRad) * hw) * s, y: (pivotY - sin(perpRad) * hw) * s)
            let tip = CGPoint(x: tipX * s, y: tipY * s)

            // Base quill color (deep purple) → bright tip
            let t = (feathers.firstIndex(where: { $0.0 == angle }) ?? 0)
            let blend = CGFloat(t) / CGFloat(feathers.count - 1)
            let featherColor = Color(
                red: 0.45 + blend * 0.33,
                green: 0.08 + blend * 0.10,
                blue: 0.88 + blend * 0.12
            )

            var quill = Path()
            quill.move(to: p1)
            quill.addLine(to: tip)
            quill.addLine(to: p2)
            quill.closeSubpath()
            ctx.fill(quill, with: .color(featherColor))

            // Central shaft
            let midX = (pivotX + tipX) / 2
            let midY = (pivotY + tipY) / 2
            ctx.stroke(
                Path { sh in
                    sh.move(to: CGPoint(x: pivotX * s, y: pivotY * s))
                    sh.addLine(to: CGPoint(x: midX * s, y: midY * s))
                },
                with: .color(wingTip.opacity(0.5)),
                lineWidth: 1.2 * s
            )
        }
    }

    private func drawArm() {
        var arm = Path()
        arm.move(to: pt(126, 117)); arm.addLine(to: pt(149, 124))
        arm.addLine(to: pt(153, 137)); arm.addLine(to: pt(138, 140))
        arm.addLine(to: pt(134, 129)); arm.addLine(to: pt(120, 123))
        arm.closeSubpath()
        ctx.fill(arm, with: .color(body))

        // Arm feathers
        for i in 0..<4 {
            var f = Path()
            let fx = 139.0 + CGFloat(i) * 3.5
            f.move(to: pt(fx, 137))
            f.addLine(to: pt(fx - 2, 152))
            ctx.stroke(f, with: .color(feather), lineWidth: 3.5*s)
        }
    }

    private func drawNeck() {
        var neck = Path()
        neck.move(to: pt(126, 99)); neck.addLine(to: pt(147, 87))
        neck.addLine(to: pt(154, 98)); neck.addLine(to: pt(134, 112))
        neck.closeSubpath()
        ctx.fill(neck, with: .color(body))
    }

    private func drawHead() {
        // Head ellipse
        ctx.fill(Path(ellipseIn: rc(130, 65, 62, 47)), with: .color(body))

        // Snout
        var snout = Path()
        snout.move(to: pt(178, 72)); snout.addLine(to: pt(200, 79))
        snout.addLine(to: pt(200, 95)); snout.addLine(to: pt(178, 101))
        snout.closeSubpath()
        ctx.fill(snout, with: .color(body))

        // Mouth line
        ctx.stroke(
            Path { m in m.move(to: pt(178, 89)); m.addLine(to: pt(200, 89)) },
            with: .color(dark), lineWidth: 2*s
        )

        // Nostril
        ctx.fill(Path(ellipseIn: rc(186, 76, 6, 4)), with: .color(dark))

        // Teeth
        for i in 0..<4 {
            let tx = 180.0 + CGFloat(i) * 4.5
            var t = Path()
            t.move(to: pt(tx, 89)); t.addLine(to: pt(tx + 1.8, 84)); t.addLine(to: pt(tx + 3.5, 89))
            ctx.fill(t, with: .color(.white))
        }

        // Eye white
        let ex: CGFloat = 164, ey: CGFloat = 76
        ctx.fill(Path(ellipseIn: rc(ex-9, ey-9, 18, 18)), with: .color(.white))

        if isBlinking {
            ctx.fill(Path(ellipseIn: rc(ex-9, ey-3, 18, 8)), with: .color(body))
        } else {
            // Pupil
            ctx.fill(Path(ellipseIn: rc(ex-5.5, ey-6, 13, 13)), with: .color(Color(red: 0.08, green: 0.04, blue: 0.18)))
            // Catchlight
            ctx.fill(Path(ellipseIn: rc(ex-2, ey-5, 5, 5)), with: .color(.white))
        }

        // Eyebrow ridge
        ctx.stroke(
            Path { e in e.move(to: pt(ex-8, ey-11)); e.addLine(to: pt(ex+7, ey-13)) },
            with: .color(dark), lineWidth: 2.5*s
        )
    }

    // MARK: - Accessories

    private func drawAccessories() {
        for acc in equipped {
            switch acc {
            case .cowboyHat:     drawCowboyHat()
            case .topHat:        drawTopHat()
            case .crown:         drawCrown()
            case .partyHat:      drawPartyHat()
            case .wizardHat:     drawWizardHat()
            case .vikingHelmet:  drawVikingHelmet()
            case .sombrero:      drawSombrero()
            case .graduationCap: drawGraduationCap()
            case .glasses:       drawGlasses()
            case .sunglasses:    drawSunglasses()
            case .monocle:       drawMonocle()
            case .eyepatch:      drawEyepatch()
            case .heartGlasses:  drawHeartGlasses()
            case .bowtie:        drawBowtie()
            case .bandana:       drawBandana()
            case .tie:           drawTie()
            case .cape:          break // drawn behind body
            }
        }
    }

    // Head top is around y=65, center x≈161
    private func drawCowboyHat() {
        let brown     = Color(red: 0.55, green: 0.32, blue: 0.10)
        let darkBrown = Color(red: 0.32, green: 0.17, blue: 0.04)
        // Brim
        ctx.fill(Path(ellipseIn: rc(140, 60, 46, 12)), with: .color(brown))
        // Crown
        var crown = Path()
        crown.move(to: pt(149, 62)); crown.addLine(to: pt(185, 62))
        crown.addLine(to: pt(182, 43)); crown.addLine(to: pt(152, 43))
        crown.closeSubpath()
        ctx.fill(crown, with: .color(brown))
        // Band
        var band = Path()
        band.move(to: pt(150, 57)); band.addLine(to: pt(184, 57))
        band.addLine(to: pt(184, 62)); band.addLine(to: pt(150, 62))
        band.closeSubpath()
        ctx.fill(band, with: .color(darkBrown))
    }

    private func drawTopHat() {
        // Brim
        ctx.fill(Path(ellipseIn: rc(138, 61, 48, 11)), with: .color(.black))
        // Crown
        var crown = Path()
        crown.move(to: pt(148, 62)); crown.addLine(to: pt(184, 62))
        crown.addLine(to: pt(184, 33)); crown.addLine(to: pt(148, 33))
        crown.closeSubpath()
        ctx.fill(crown, with: .color(.black))
        // Gold band
        var band = Path()
        band.move(to: pt(149, 56)); band.addLine(to: pt(184, 56))
        band.addLine(to: pt(184, 62)); band.addLine(to: pt(149, 62))
        band.closeSubpath()
        ctx.fill(band, with: .color(Color(red: 0.85, green: 0.68, blue: 0.08)))
    }

    private func drawCrown() {
        let gold = Color(red: 0.95, green: 0.80, blue: 0.08)
        // Base band
        var base = Path()
        base.move(to: pt(146, 68)); base.addLine(to: pt(186, 68))
        base.addLine(to: pt(186, 61)); base.addLine(to: pt(146, 61))
        base.closeSubpath()
        ctx.fill(base, with: .color(gold))
        // Spikes
        let spikeXs: [CGFloat] = [149, 157, 165, 173, 181]
        for sx in spikeXs {
            var spike = Path()
            spike.move(to: pt(sx, 61)); spike.addLine(to: pt(sx+3, 48)); spike.addLine(to: pt(sx+6, 61))
            spike.closeSubpath()
            ctx.fill(spike, with: .color(gold))
        }
        // Gems
        let gems: [(CGFloat, Color)] = [
            (151, Color(red: 0.9, green: 0.1, blue: 0.1)),
            (160, Color(red: 0.1, green: 0.4, blue: 0.95)),
            (169, Color(red: 0.9, green: 0.1, blue: 0.1)),
            (178, Color(red: 0.1, green: 0.4, blue: 0.95)),
        ]
        for (gx, gc) in gems {
            ctx.fill(Path(ellipseIn: rc(gx, 62, 5, 5)), with: .color(gc))
        }
    }

    private func drawPartyHat() {
        let pink = Color(red: 0.92, green: 0.18, blue: 0.55)
        // Cone
        var cone = Path()
        cone.move(to: pt(147, 70)); cone.addLine(to: pt(182, 70))
        cone.addLine(to: pt(171, 36)); cone.closeSubpath()
        ctx.fill(cone, with: .color(pink))
        // Stripes
        ctx.stroke(Path { l in l.move(to: pt(150, 65)); l.addLine(to: pt(169, 42)) },
                   with: .color(.white.opacity(0.45)), lineWidth: 2.5*s)
        ctx.stroke(Path { l in l.move(to: pt(159, 69)); l.addLine(to: pt(170, 43)) },
                   with: .color(.white.opacity(0.45)), lineWidth: 2.5*s)
        // Pompom
        ctx.fill(Path(ellipseIn: rc(164, 29, 12, 12)), with: .color(Color(red: 1.0, green: 0.90, blue: 0.0)))
    }

    // Eye center approximately (164, 76)
    private func drawGlasses() {
        let frame = Color(red: 0.28, green: 0.18, blue: 0.04)
        ctx.stroke(Path(ellipseIn: rc(153, 65, 24, 20)), with: .color(frame), lineWidth: 2.5*s)
        ctx.stroke(Path { b in b.move(to: pt(178, 75)); b.addLine(to: pt(184, 74)) },
                   with: .color(frame), lineWidth: 2*s)
        ctx.stroke(Path { t in t.move(to: pt(153, 75)); t.addLine(to: pt(143, 80)) },
                   with: .color(frame), lineWidth: 2*s)
    }

    private func drawSunglasses() {
        let lens = Color(red: 0.04, green: 0.04, blue: 0.16, opacity: 0.88)
        ctx.fill(Path(ellipseIn: rc(153, 65, 24, 20)), with: .color(lens))
        ctx.stroke(Path(ellipseIn: rc(153, 65, 24, 20)), with: .color(.black), lineWidth: 2.5*s)
        ctx.fill(Path(ellipseIn: rc(157, 68, 7, 5)), with: .color(.white.opacity(0.28)))
        ctx.stroke(Path { b in b.move(to: pt(178, 74)); b.addLine(to: pt(184, 73)) },
                   with: .color(.black), lineWidth: 2*s)
        ctx.stroke(Path { t in t.move(to: pt(153, 75)); t.addLine(to: pt(143, 80)) },
                   with: .color(.black), lineWidth: 2*s)
    }

    private func drawMonocle() {
        let gold = Color(red: 0.88, green: 0.72, blue: 0.08)
        ctx.stroke(Path(ellipseIn: rc(153, 65, 24, 20)), with: .color(gold), lineWidth: 3*s)
        // Monocle chain
        ctx.stroke(Path { c in
            c.move(to: pt(177, 78)); c.addLine(to: pt(183, 82)); c.addLine(to: pt(185, 91))
        }, with: .color(gold), lineWidth: 1.5*s)
    }

    // Neck area roughly (140, 100-112)
    private func drawBowtie() {
        let red  = Color(red: 0.88, green: 0.08, blue: 0.08)
        let dark = Color(red: 0.60, green: 0.04, blue: 0.04)
        var left = Path()
        left.move(to: pt(137, 107)); left.addLine(to: pt(124, 100))
        left.addLine(to: pt(124, 114)); left.closeSubpath()
        ctx.fill(left, with: .color(red))
        var right = Path()
        right.move(to: pt(137, 107)); right.addLine(to: pt(150, 100))
        right.addLine(to: pt(150, 114)); right.closeSubpath()
        ctx.fill(right, with: .color(red))
        ctx.fill(Path(ellipseIn: rc(132, 103, 10, 9)), with: .color(dark))
    }

    private func drawBandana() {
        let red = Color(red: 0.82, green: 0.08, blue: 0.12)
        var wrap = Path()
        wrap.move(to: pt(130, 102)); wrap.addLine(to: pt(157, 95))
        wrap.addLine(to: pt(158, 107)); wrap.addLine(to: pt(131, 113))
        wrap.closeSubpath()
        ctx.fill(wrap, with: .color(red))
        // Knot / hanging triangle
        var tie = Path()
        tie.move(to: pt(137, 113)); tie.addLine(to: pt(131, 113))
        tie.addLine(to: pt(133, 124)); tie.closeSubpath()
        ctx.fill(tie, with: .color(red))
        // Polka dots
        let dots: [(CGFloat, CGFloat)] = [(135, 99), (143, 97), (150, 98), (138, 105)]
        for (dx, dy) in dots {
            ctx.fill(Path(ellipseIn: rc(dx, dy, 3.5, 3.5)), with: .color(.white.opacity(0.45)))
        }
    }

    // MARK: - New accessories

    private func drawWizardHat() {
        let purple = Color(red: 0.38, green: 0.10, blue: 0.68)
        let darkPurple = Color(red: 0.22, green: 0.05, blue: 0.42)
        // Brim
        ctx.fill(Path(ellipseIn: rc(138, 62, 48, 11)), with: .color(darkPurple))
        // Cone
        var cone = Path()
        cone.move(to: pt(143, 63)); cone.addLine(to: pt(184, 63))
        cone.addLine(to: pt(169, 26)); cone.closeSubpath()
        ctx.fill(cone, with: .color(purple))
        // Stars
        let stars: [(CGFloat, CGFloat, CGFloat)] = [(160, 48, 4), (172, 38, 3), (155, 55, 2.5), (168, 58, 2)]
        for (sx, sy, sr) in stars {
            ctx.fill(Path(ellipseIn: rc(sx-sr, sy-sr, sr*2, sr*2)), with: .color(.yellow))
        }
        // Band
        var band = Path()
        band.move(to: pt(144, 58)); band.addLine(to: pt(183, 58))
        band.addLine(to: pt(183, 63)); band.addLine(to: pt(144, 63))
        band.closeSubpath()
        ctx.fill(band, with: .color(Color(red: 0.70, green: 0.85, blue: 0.30)))
    }

    private func drawVikingHelmet() {
        let silver = Color(red: 0.72, green: 0.74, blue: 0.78)
        let darkSilver = Color(red: 0.45, green: 0.46, blue: 0.50)
        // Dome
        ctx.fill(Path(ellipseIn: rc(138, 56, 52, 26)), with: .color(silver))
        // Nose guard
        var nose = Path()
        nose.move(to: pt(160, 70)); nose.addLine(to: pt(168, 70))
        nose.addLine(to: pt(165, 82)); nose.addLine(to: pt(163, 82))
        nose.closeSubpath()
        ctx.fill(nose, with: .color(darkSilver))
        // Left horn
        var lHorn = Path()
        lHorn.move(to: pt(142, 62))
        lHorn.addCurve(to: pt(118, 40), control1: pt(132, 58), control2: pt(118, 52))
        lHorn.addLine(to: pt(122, 37))
        lHorn.addCurve(to: pt(148, 62), control1: pt(126, 50), control2: pt(138, 58))
        lHorn.closeSubpath()
        ctx.fill(lHorn, with: .color(silver))
        // Right horn
        var rHorn = Path()
        rHorn.move(to: pt(184, 62))
        rHorn.addCurve(to: pt(205, 38), control1: pt(196, 56), control2: pt(207, 50))
        rHorn.addLine(to: pt(202, 35))
        rHorn.addCurve(to: pt(180, 62), control1: pt(200, 48), control2: pt(190, 58))
        rHorn.closeSubpath()
        ctx.fill(rHorn, with: .color(silver))
        // Rim stripe
        ctx.stroke(Path(ellipseIn: rc(138, 56, 52, 26)), with: .color(darkSilver), lineWidth: 2*s)
    }

    private func drawSombrero() {
        let straw = Color(red: 0.88, green: 0.74, blue: 0.30)
        let darkStraw = Color(red: 0.65, green: 0.50, blue: 0.15)
        // Wide brim (ellipse)
        ctx.fill(Path(ellipseIn: rc(118, 62, 78, 14)), with: .color(straw))
        ctx.stroke(Path(ellipseIn: rc(118, 62, 78, 14)), with: .color(darkStraw), lineWidth: 1.5*s)
        // Crown
        ctx.fill(Path(ellipseIn: rc(143, 50, 46, 20)), with: .color(straw))
        // Decorative band
        var band = Path()
        band.move(to: pt(144, 64)); band.addLine(to: pt(186, 64))
        band.addLine(to: pt(186, 68)); band.addLine(to: pt(144, 68))
        band.closeSubpath()
        ctx.fill(band, with: .color(Color(red: 0.90, green: 0.15, blue: 0.15)))
        // Pompoms along band
        let pomXs: [CGFloat] = [148, 157, 166, 175, 183]
        for px in pomXs {
            ctx.fill(Path(ellipseIn: rc(px-2, 63, 4, 4)), with: .color(.white))
        }
    }

    private func drawGraduationCap() {
        // Board (flat square top)
        var board = Path()
        board.move(to: pt(140, 58)); board.addLine(to: pt(190, 58))
        board.addLine(to: pt(190, 64)); board.addLine(to: pt(140, 64))
        board.closeSubpath()
        ctx.fill(board, with: .color(.black))
        // Cap sides
        var sides = Path()
        sides.move(to: pt(147, 64)); sides.addLine(to: pt(184, 64))
        sides.addLine(to: pt(184, 71)); sides.addLine(to: pt(147, 71))
        sides.closeSubpath()
        ctx.fill(sides, with: .color(.black))
        // Tassel string
        ctx.stroke(Path { t in
            t.move(to: pt(165, 61)); t.addLine(to: pt(165, 78)); t.addLine(to: pt(170, 78))
        }, with: .color(Color(red: 0.95, green: 0.78, blue: 0.05)), lineWidth: 1.5*s)
        ctx.fill(Path(ellipseIn: rc(167, 76, 6, 6)), with: .color(Color(red: 0.95, green: 0.78, blue: 0.05)))
    }

    private func drawEyepatch() {
        // Patch over eye (eye center ~164, 76)
        ctx.fill(Path(ellipseIn: rc(153, 65, 24, 20)), with: .color(.black))
        ctx.stroke(Path(ellipseIn: rc(153, 65, 24, 20)), with: .color(Color(red: 0.5, green: 0.35, blue: 0.10)), lineWidth: 2*s)
        // Strap lines
        ctx.stroke(Path { l in l.move(to: pt(153, 73)); l.addLine(to: pt(138, 78)) },
                   with: .color(Color(red: 0.5, green: 0.35, blue: 0.10)), lineWidth: 2*s)
        ctx.stroke(Path { l in l.move(to: pt(177, 73)); l.addLine(to: pt(188, 78)) },
                   with: .color(Color(red: 0.5, green: 0.35, blue: 0.10)), lineWidth: 2*s)
    }

    private func drawHeartGlasses() {
        let pink = Color(red: 1.0, green: 0.28, blue: 0.50)
        // Heart-shaped lens over the eye
        // Two circles meeting in the middle, bottom point
        let hx: CGFloat = 165, hy: CGFloat = 73
        ctx.fill(Path(ellipseIn: rc(hx-11, hy-8, 11, 10)), with: .color(pink.opacity(0.55)))
        ctx.fill(Path(ellipseIn: rc(hx, hy-8, 11, 10)), with: .color(pink.opacity(0.55)))
        // V bottom of heart
        var tip = Path()
        tip.move(to: pt(hx-11, hy+1))
        tip.addCurve(to: pt(hx+5, hy+8), control1: pt(hx-5, hy+6), control2: pt(hx+2, hy+8))
        tip.addCurve(to: pt(hx+11, hy+1), control1: pt(hx+8, hy+8), control2: pt(hx+11, hy+5))
        ctx.fill(tip, with: .color(pink.opacity(0.55)))
        // Outline
        ctx.stroke(Path(ellipseIn: rc(hx-11, hy-8, 11, 10)), with: .color(pink), lineWidth: 2*s)
        ctx.stroke(Path(ellipseIn: rc(hx, hy-8, 11, 10)), with: .color(pink), lineWidth: 2*s)
        // Temple
        ctx.stroke(Path { t in t.move(to: pt(hx-11, hy)); t.addLine(to: pt(hx-20, hy+5)) },
                   with: .color(pink), lineWidth: 2*s)
        // Bridge to snout
        ctx.stroke(Path { b in b.move(to: pt(hx+11, hy)); b.addLine(to: pt(hx+17, hy-1)) },
                   with: .color(pink), lineWidth: 2*s)
    }

    private func drawTie() {
        let blue = Color(red: 0.10, green: 0.25, blue: 0.80)
        let darkBlue = Color(red: 0.06, green: 0.14, blue: 0.55)
        // Knot
        ctx.fill(Path(ellipseIn: rc(135, 101, 10, 8)), with: .color(darkBlue))
        // Wide blade
        var blade = Path()
        blade.move(to: pt(133, 108)); blade.addLine(to: pt(145, 108))
        blade.addLine(to: pt(148, 132)); blade.addLine(to: pt(141, 148))
        blade.addLine(to: pt(136, 132)); blade.addLine(to: pt(133, 108))
        blade.closeSubpath()
        ctx.fill(blade, with: .color(blue))
        // Stripe
        ctx.stroke(Path { l in l.move(to: pt(139, 110)); l.addLine(to: pt(143, 145)) },
                   with: .color(darkBlue.opacity(0.5)), lineWidth: 2*s)
    }

    private func drawCape() {
        let capeRed   = Color(red: 0.88, green: 0.10, blue: 0.10)
        let capeInner = Color(red: 0.95, green: 0.82, blue: 0.62)
        // Outer cape shape (flows from upper back of body to lower-left)
        var outer = Path()
        outer.move(to: pt(68, 98))
        outer.addCurve(to: pt(22, 165), control1: pt(28, 98), control2: pt(15, 130))
        outer.addLine(to: pt(50, 172))
        outer.addCurve(to: pt(75, 110), control1: pt(40, 148), control2: pt(50, 122))
        outer.closeSubpath()
        ctx.fill(outer, with: .color(capeRed))
        // Inner lining (visible at bottom edge)
        var inner = Path()
        inner.move(to: pt(68, 105))
        inner.addCurve(to: pt(30, 162), control1: pt(32, 108), control2: pt(22, 135))
        inner.addLine(to: pt(50, 172))
        inner.addCurve(to: pt(74, 112), control1: pt(42, 150), control2: pt(52, 125))
        inner.closeSubpath()
        ctx.fill(inner, with: .color(capeInner))
        // Collar
        var collar = Path()
        collar.move(to: pt(60, 97)); collar.addLine(to: pt(78, 100))
        collar.addLine(to: pt(76, 110)); collar.addLine(to: pt(58, 106))
        collar.closeSubpath()
        ctx.fill(collar, with: .color(capeRed))
    }
}
