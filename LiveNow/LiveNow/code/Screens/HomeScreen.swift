//
//  HomeScreen.swift
//  LiveNow
//
//  Created by Gregor Cigoj on 24. 4. 2026.
//

import SwiftUI

// MARK: - HOME

/*struct HomeScreen: View {
    @ObservedObject var vm: AppViewModel

    let orange: Color
    let lightOrange: Color

    var onStart: () -> Void

    @State private var isBreathing = false

    // MARK: Avatar physics

    @State private var avatarPosition: CGPoint = .zero
    @State private var avatarVelocity: CGVector = .zero
    @State private var avatarDragStart: CGPoint?
    @State private var isDraggingAvatar = false
    @State private var physicsTask: Task<Void, Never>?
    @State private var didSetInitialAvatarPosition = false
    
    @State private var didAvatarHitEdge = false

    @ScaledMetric private var heroSize: CGFloat = 43
    @ScaledMetric private var subtitleSize: CGFloat = 16

    var body: some View {
        GeometryReader { geo in
            let screenWidth = geo.size.width
            let screenHeight = geo.size.height

            let widthScale = min(
                max(screenWidth / 393, 0.88),
                1.16
            )

            let heightScale = min(
                max(screenHeight / 852, 0.88),
                1.12
            )

            let scale = min(
                widthScale,
                heightScale
            )

            let horizontalPadding = min(
                max(screenWidth * 0.06, 20),
                28
            )

            let adjustedHeroSize = min(
                max(heroSize * scale, 36),
                50
            )

            let subtitleSize = min(
                max(18 * scale, 15),
                22
            )

            let isCompactHeight = screenHeight < 760

            let resetSize = isCompactHeight
                ? min(
                    screenWidth * 0.46,
                    185
                )
                : min(
                    screenWidth * 0.52,
                    screenHeight * 0.24,
                    230 * scale
                )

            let spacingAfterHeader = min(
                max(screenHeight * 0.026, 16),
                26
            )

            let spacingAfterHero = min(
                max(screenHeight * 0.11, 65),
                105
            )

            let spacingAfterReset = min(
                max(screenHeight * 0.11, 65),
                105
            )

            let bottomSpacing = min(
                max(screenHeight * 0.04, 22),
                42
            )

            let avatarSize = isCompactHeight
                ? min(screenWidth * 0.37, 124)
                : min(screenWidth * 0.39, 138)

            let isGuestAfterFirstReset =
                vm.isGuestUser &&
                vm.hasCompletedGuestReset

            ZStack {

                // MARK: Main content

                VStack(spacing: 0) {

                    // MARK: Header

                    LiveNowTopHeader(
                        horizontalPadding: horizontalPadding
                    )

                    Spacer()
                        .frame(height: spacingAfterHeader)

                    // MARK: Hero

                    VStack(spacing: 0) {
                        Text(
                            isGuestAfterFirstReset
                                ? "your first reset"
                                : "get out of"
                        )
                        .font(
                            .system(
                                size: adjustedHeroSize,
                                weight: .bold
                            )
                        )
                        .foregroundColor(.black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)

                        Text(
                            isGuestAfterFirstReset
                                ? "is complete"
                                : "your head"
                        )
                        .font(
                            .system(
                                size: adjustedHeroSize,
                                weight: .bold
                            )
                        )
                        .foregroundColor(orange)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                    }
                    .multilineTextAlignment(.center)
                    .padding(
                        .horizontal,
                        horizontalPadding
                    )

                    Spacer()
                        .frame(height: spacingAfterHero)

                    // MARK: Reset button

                    Button(action: onStart) {
                        ZStack {
                            Circle()
                                .fill(
                                    orange.opacity(0.16)
                                )
                                .frame(
                                    width: resetSize * 1.14,
                                    height: resetSize * 1.14
                                )
                                .scaleEffect(
                                    isBreathing
                                        ? 1.08
                                        : 0.92
                                )
                                .opacity(
                                    isBreathing
                                        ? 0.15
                                        : 0.35
                                )

                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            lightOrange,
                                            orange
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(
                                    width: resetSize,
                                    height: resetSize
                                )
                                .shadow(
                                    color: orange.opacity(
                                        isBreathing
                                            ? 0.38
                                            : 0.22
                                    ),
                                    radius: isBreathing
                                        ? 26
                                        : 16,
                                    x: 0,
                                    y: 9
                                )
                                .scaleEffect(
                                    isBreathing
                                        ? 1.055
                                        : 0.975
                                )

                            VStack(
                                spacing: resetSize * 0.035
                            ) {
                                Text("RESET")
                                    .font(
                                        .system(
                                            size:
                                                resetSize
                                                * 0.165,
                                            weight: .bold
                                        )
                                    )
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)

                                Text("clear your mind")
                                    .font(
                                        .system(
                                            size:
                                                resetSize
                                                * 0.075
                                        )
                                    )
                                    .foregroundColor(
                                        .white.opacity(0.95)
                                    )
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                            }
                            .offset(
                                y:
                                    -resetSize
                                    * 0.01
                            )
                            .scaleEffect(
                                isBreathing
                                    ? 1.01
                                    : 0.99
                            )
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Reset")
                    .accessibilityHint(
                        "Start a new reset"
                    )
                    .onAppear {
                        guard !isBreathing else {
                            return
                        }

                        withAnimation(
                            .easeInOut(
                                duration: 1.35
                            )
                            .repeatForever(
                                autoreverses: true
                            )
                        ) {
                            isBreathing = true
                        }
                    }

                    Spacer()
                        .frame(height: spacingAfterReset)

                    // MARK: Message

                    Text(
                        isGuestAfterFirstReset
                            ? "save your reset and\nkeep your progress going"
                            : vm.homeMessage
                    )
                    .font(
                        .system(
                            size: subtitleSize
                        )
                    )
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.75)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
                    .frame(maxWidth: 340)
                    .padding(
                        .horizontal,
                        horizontalPadding
                    )

                    Spacer(
                        minLength: bottomSpacing
                    )
                }
                .frame(
                    width: screenWidth,
                    height: screenHeight,
                    alignment: .top
                )

                // MARK: Draggable home avatar

                Image(
                    isGuestAfterFirstReset
                        ? "avatar_happy"
                        : (didAvatarHitEdge ? "avatar_bum" : "avatar_smile")
                )
                .resizable()
                .scaledToFit()
                .frame(
                    width: avatarSize,
                    height: avatarSize
                )
                .contentShape(Rectangle())
                .position(avatarPosition)
                .transaction { transaction in
                    transaction.animation = nil
                }
                .scaleEffect(
                    isDraggingAvatar ? 1.06 : 1.0
                )
                .shadow(
                    color: .black.opacity(
                        isDraggingAvatar ? 0.10 : 0
                    ),
                    radius: 10,
                    x: 0,
                    y: 5
                )
                .gesture(
                    DragGesture(
                        minimumDistance: 0,
                        coordinateSpace: .local
                    )
                    .onChanged { value in
                        physicsTask?.cancel()
                        physicsTask = nil

                        avatarVelocity = .zero
                        isDraggingAvatar = true
                        didAvatarHitEdge = false

                        if avatarDragStart == nil {
                            avatarDragStart = avatarPosition
                        }

                        guard let start = avatarDragStart else {
                            return
                        }

                        let proposedPosition = CGPoint(
                            x: start.x + value.translation.width,
                            y: start.y + value.translation.height
                        )

                        avatarPosition = clampAvatarPosition(
                            proposedPosition,
                            screenSize: geo.size,
                            safeAreaInsets: geo.safeAreaInsets,
                            avatarSize: avatarSize
                        )
                    }
                    .onEnded { value in
                        isDraggingAvatar = false
                        avatarDragStart = nil

                        let extraX =
                            value
                                .predictedEndTranslation
                                .width
                            - value.translation.width

                        let extraY =
                            value
                                .predictedEndTranslation
                                .height
                            - value.translation.height

                        let velocityMultiplier: CGFloat = 5.5

                        let dx = max(
                            -1800,
                            min(
                                extraX
                                    * velocityMultiplier,
                                1800
                            )
                        )

                        let dy = max(
                            -1800,
                            min(
                                extraY
                                    * velocityMultiplier,
                                1800
                            )
                        )

                        avatarVelocity = CGVector(
                            dx: dx,
                            dy: dy
                        )

                        startAvatarPhysics(
                            screenSize: geo.size,
                            safeAreaInsets:
                                geo.safeAreaInsets,
                            avatarSize: avatarSize
                        )
                    }
                )
                .accessibilityHidden(true)
            }
            .frame(
                width: screenWidth,
                height: screenHeight
            )
            .onAppear {
                if !didSetInitialAvatarPosition {
                    avatarPosition =
                        initialAvatarPosition(
                            screenSize: geo.size,
                            safeAreaInsets:
                                geo.safeAreaInsets,
                            avatarSize: avatarSize,
                            horizontalPadding:
                                horizontalPadding
                        )

                    didSetInitialAvatarPosition = true
                }
            }
            .onDisappear {
                physicsTask?.cancel()
                physicsTask = nil
            }
            .sheet(
                isPresented:
                    $vm.showSelectedDateEntries
            ) {
                SelectedDateEntriesSheet(
                    vm: vm,
                    orange: orange
                )
            }
        }
    }

    // MARK: - Initial avatar position

    private func initialAvatarPosition(
        screenSize: CGSize,
        safeAreaInsets: EdgeInsets,
        avatarSize: CGFloat,
        horizontalPadding: CGFloat
    ) -> CGPoint {
        CGPoint(
            x:
                horizontalPadding
                + avatarSize / 2
                + 4,
            y:
                screenSize.height
                - safeAreaInsets.bottom
                - avatarSize / 2
                - 4
        )
    }

    // MARK: - Clamp avatar to full screen

    private func clampAvatarPosition(
        _ position: CGPoint,
        screenSize: CGSize,
        safeAreaInsets: EdgeInsets,
        avatarSize: CGFloat
    ) -> CGPoint {

        let collisionRadius = avatarSize * 0.40

        let minX = collisionRadius
        let maxX = screenSize.width - collisionRadius

        let minY = collisionRadius
        let maxY = screenSize.height - collisionRadius

        return CGPoint(
            x: min(max(position.x, minX), maxX),
            y: min(max(position.y, minY), maxY)
        )
    }

    // MARK: - Avatar physics

    private func startAvatarPhysics(
        screenSize: CGSize,
        safeAreaInsets: EdgeInsets,
        avatarSize: CGFloat
    ) {
        physicsTask?.cancel()

        physicsTask = Task { @MainActor in
            let frameDuration: UInt64 = 16_666_667
            let deltaTime: CGFloat = 1.0 / 60.0

            let friction: CGFloat = 0.985
            let bounce: CGFloat = 0.78
            let stopSpeed: CGFloat = 12

            let collisionRadius = avatarSize * 0.40

            let minX = collisionRadius
            let maxX = screenSize.width - collisionRadius

            let minY = collisionRadius
            let maxY = screenSize.height - collisionRadius

            while !Task.isCancelled {
                let speed = sqrt(
                    avatarVelocity.dx
                    * avatarVelocity.dx
                    +
                    avatarVelocity.dy
                    * avatarVelocity.dy
                )

                if speed < stopSpeed {
                    avatarVelocity = .zero
                    didAvatarHitEdge = false
                    break
                }

                var nextX =
                    avatarPosition.x
                    + avatarVelocity.dx
                    * deltaTime

                var nextY =
                    avatarPosition.y
                    + avatarVelocity.dy
                    * deltaTime

                // Left edge
                if nextX < minX {
                    nextX = minX
                    avatarVelocity.dx =
                        abs(avatarVelocity.dx) * bounce
                    didAvatarHitEdge = true
                }

                // Right edge
                if nextX > maxX {
                    nextX = maxX
                    avatarVelocity.dx =
                        -abs(avatarVelocity.dx) * bounce
                    didAvatarHitEdge = true
                }

                // Top edge
                if nextY < minY {
                    nextY = minY
                    avatarVelocity.dy =
                        abs(avatarVelocity.dy) * bounce
                    didAvatarHitEdge = true
                }

                // Bottom edge
                if nextY > maxY {
                    nextY = maxY
                    avatarVelocity.dy =
                        -abs(avatarVelocity.dy) * bounce
                    didAvatarHitEdge = true
                }

                var transaction = Transaction()
                transaction.animation = nil

                withTransaction(transaction) {
                    avatarPosition = CGPoint(
                        x: nextX,
                        y: nextY
                    )
                }

                avatarVelocity.dx *= friction
                avatarVelocity.dy *= friction

                try? await Task.sleep(
                    nanoseconds: frameDuration
                )

                if Task.isCancelled {
                    return
                }
            }

            didAvatarHitEdge = false
            physicsTask = nil
        }
    }
}*/

import SwiftUI

// MARK: - HOME

struct HomeScreen: View {
    @ObservedObject var vm: AppViewModel

    let orange: Color
    let lightOrange: Color

    var onStart: () -> Void

    @State private var isBreathing = false

    @ScaledMetric private var heroSize: CGFloat = 43
    @ScaledMetric private var subtitleSize: CGFloat = 16

    var body: some View {
        GeometryReader { geo in

            let screenWidth = geo.size.width
            let screenHeight = geo.size.height

            let widthScale = min(
                max(screenWidth / 393, 0.88),
                1.16
            )

            let heightScale = min(
                max(screenHeight / 852, 0.88),
                1.12
            )

            let scale = min(
                widthScale,
                heightScale
            )

            let horizontalPadding = min(
                max(screenWidth * 0.06, 20),
                28
            )

            let adjustedHeroSize = min(
                max(heroSize * scale, 36),
                50
            )

            let subtitleSize = min(
                max(18 * scale, 15),
                22
            )

            let isCompactHeight = screenHeight < 760

            let resetSize = isCompactHeight
                ? min(
                    screenWidth * 0.46,
                    185
                )
                : min(
                    screenWidth * 0.52,
                    screenHeight * 0.24,
                    230 * scale
                )

            let spacingAfterHeader = min(
                max(screenHeight * 0.026, 16),
                26
            )

            let spacingAfterHero = min(
                max(screenHeight * 0.11, 65),
                105
            )

            let spacingAfterReset = min(
                max(screenHeight * 0.11, 65),
                105
            )

            let bottomSpacing = min(
                max(screenHeight * 0.04, 22),
                42
            )

            let isGuestAfterFirstReset =
                vm.isGuestUser &&
                vm.hasCompletedGuestReset

            ZStack(alignment: .bottomLeading) {

                // MARK: Main content

                VStack(spacing: 0) {

                    // MARK: Header

                    LiveNowTopHeader(
                        horizontalPadding: horizontalPadding
                    )

                    Spacer()
                        .frame(
                            height: spacingAfterHeader
                        )

                    // MARK: Hero

                    VStack(spacing: 0) {
                        Text(
                            isGuestAfterFirstReset
                                ? "your first reset"
                                : "get out of"
                        )
                        .font(
                            .system(
                                size: adjustedHeroSize,
                                weight: .bold
                            )
                        )
                        .foregroundColor(.black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)

                        Text(
                            isGuestAfterFirstReset
                                ? "is complete"
                                : "your head"
                        )
                        .font(
                            .system(
                                size: adjustedHeroSize,
                                weight: .bold
                            )
                        )
                        .foregroundColor(orange)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                    }
                    .multilineTextAlignment(.center)
                    .padding(
                        .horizontal,
                        horizontalPadding
                    )

                    Spacer()
                        .frame(
                            height: spacingAfterHero
                        )

                    // MARK: Reset button

                    Button(action: onStart) {
                        ZStack {
                            Circle()
                                .fill(
                                    orange.opacity(0.16)
                                )
                                .frame(
                                    width: resetSize * 1.14,
                                    height: resetSize * 1.14
                                )
                                .scaleEffect(
                                    isBreathing
                                        ? 1.08
                                        : 0.92
                                )
                                .opacity(
                                    isBreathing
                                        ? 0.15
                                        : 0.35
                                )

                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            lightOrange,
                                            orange
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(
                                    width: resetSize,
                                    height: resetSize
                                )
                                .shadow(
                                    color: orange.opacity(
                                        isBreathing
                                            ? 0.38
                                            : 0.22
                                    ),
                                    radius: isBreathing
                                        ? 26
                                        : 16,
                                    x: 0,
                                    y: 9
                                )
                                .scaleEffect(
                                    isBreathing
                                        ? 1.055
                                        : 0.975
                                )

                            VStack(
                                spacing: resetSize * 0.035
                            ) {
                                Text("RESET")
                                    .font(
                                        .system(
                                            size:
                                                resetSize
                                                * 0.165,
                                            weight: .bold
                                        )
                                    )
                                    .foregroundColor(
                                        .white
                                    )
                                    .lineLimit(1)
                                    .minimumScaleFactor(
                                        0.8
                                    )

                                Text(
                                    "clear your mind"
                                )
                                .font(
                                    .system(
                                        size:
                                            resetSize
                                            * 0.075
                                    )
                                )
                                .foregroundColor(
                                    .white.opacity(
                                        0.95
                                    )
                                )
                                .lineLimit(1)
                                .minimumScaleFactor(
                                    0.8
                                )
                            }
                            .offset(
                                y:
                                    -resetSize
                                    * 0.01
                            )
                            .scaleEffect(
                                isBreathing
                                    ? 1.01
                                    : 0.99
                            )
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Reset")
                    .accessibilityHint(
                        "Start a new reset"
                    )
                    .onAppear {
                        guard !isBreathing else {
                            return
                        }

                        withAnimation(
                            .easeInOut(
                                duration: 1.35
                            )
                            .repeatForever(
                                autoreverses: true
                            )
                        ) {
                            isBreathing = true
                        }
                    }

                    Spacer()
                        .frame(
                            height: spacingAfterReset
                        )

                    // MARK: Message

                    Text(
                        isGuestAfterFirstReset
                            ? "save your reset and\nkeep your progress going"
                            : vm.homeMessage
                    )
                    .font(
                        .system(
                            size: subtitleSize
                        )
                    )
                    .foregroundColor(.gray)
                    .multilineTextAlignment(
                        .center
                    )
                    .lineLimit(3)
                    .minimumScaleFactor(0.75)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
                    .frame(
                        maxWidth: 340
                    )
                    .padding(
                        .horizontal,
                        horizontalPadding
                    )

                    Spacer(
                        minLength: bottomSpacing
                    )
                }
                .frame(
                    width: screenWidth,
                    height: screenHeight,
                    alignment: .top
                )
            }
        }
    }
}

// MARK: - HOME

/*struct HomeScreen: View {
    @ObservedObject var vm: AppViewModel

    let orange: Color
    let lightOrange: Color

    var onStart: () -> Void

    @State private var isBreathing = false

    @ScaledMetric private var heroSize: CGFloat = 43
    @ScaledMetric private var subtitleSize: CGFloat = 16

    var body: some View {
        GeometryReader { geo in

            let screenWidth = geo.size.width
            let screenHeight = geo.size.height

            let widthScale = min(
                max(screenWidth / 393, 0.88),
                1.16
            )

            let heightScale = min(
                max(screenHeight / 852, 0.88),
                1.12
            )

            let scale = min(
                widthScale,
                heightScale
            )

            let horizontalPadding = min(
                max(screenWidth * 0.06, 20),
                28
            )

            let adjustedHeroSize = min(
                max(heroSize * scale, 36),
                50
            )

            let subtitleSize = min(
                max(18 * scale, 15),
                22
            )

            let isCompactHeight = screenHeight < 760

            let resetSize = isCompactHeight
                ? min(
                    screenWidth * 0.46,
                    185
                )
                : min(
                    screenWidth * 0.52,
                    screenHeight * 0.24,
                    230 * scale
                )

            let spacingAfterHeader = min(
                max(screenHeight * 0.026, 16),
                26
            )

            let spacingAfterHero = min(
                max(screenHeight * 0.11, 65),
                105
            )

            let spacingAfterReset = min(
                max(screenHeight * 0.11, 65),
                105
            )

            let bottomSpacing = min(
                max(screenHeight * 0.04, 22),
                42
            )

            // Avatar size adapts to screen size,
            // but does not affect the layout.
            let avatarSize = isCompactHeight
                ? min(screenWidth * 0.29, 105)
                : min(screenWidth * 0.31, 118)

            let isGuestAfterFirstReset =
                vm.isGuestUser &&
                vm.hasCompletedGuestReset

            ZStack(alignment: .bottomLeading) {

                // MARK: Main content

                VStack(spacing: 0) {

                    // MARK: Header

                    LiveNowTopHeader(
                        horizontalPadding: horizontalPadding
                    )

                    Spacer()
                        .frame(
                            height: spacingAfterHeader
                        )

                    // MARK: Hero

                    VStack(spacing: 0) {
                        Text(
                            isGuestAfterFirstReset
                                ? "your first reset"
                                : "get out of"
                        )
                        .font(
                            .system(
                                size: adjustedHeroSize,
                                weight: .bold
                            )
                        )
                        .foregroundColor(.black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)

                        Text(
                            isGuestAfterFirstReset
                                ? "is complete"
                                : "your head"
                        )
                        .font(
                            .system(
                                size: adjustedHeroSize,
                                weight: .bold
                            )
                        )
                        .foregroundColor(orange)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                    }
                    .multilineTextAlignment(.center)
                    .padding(
                        .horizontal,
                        horizontalPadding
                    )

                    Spacer()
                        .frame(
                            height: spacingAfterHero
                        )

                    // MARK: Reset button

                    ZStack {

                        Button(action: onStart) {

                            ZStack {

                                Circle()
                                    .fill(
                                        orange.opacity(0.16)
                                    )
                                    .frame(
                                        width: resetSize * 1.14,
                                        height: resetSize * 1.14
                                    )
                                    .scaleEffect(
                                        isBreathing
                                            ? 1.08
                                            : 0.92
                                    )
                                    .opacity(
                                        isBreathing
                                            ? 0.15
                                            : 0.35
                                    )

                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                lightOrange,
                                                orange
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .frame(
                                        width: resetSize,
                                        height: resetSize
                                    )
                                    .shadow(
                                        color: orange.opacity(
                                            isBreathing
                                                ? 0.38
                                                : 0.22
                                        ),
                                        radius: isBreathing
                                            ? 26
                                            : 16,
                                        x: 0,
                                        y: 9
                                    )
                                    .scaleEffect(
                                        isBreathing
                                            ? 1.055
                                            : 0.975
                                    )

                                VStack(
                                    spacing: resetSize * 0.035
                                ) {

                                    Text("RESET")
                                        .font(
                                            .system(
                                                size: resetSize * 0.165,
                                                weight: .bold
                                            )
                                        )
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)

                                    Text("clear your mind")
                                        .font(
                                            .system(
                                                size: resetSize * 0.075
                                            )
                                        )
                                        .foregroundColor(
                                            .white.opacity(0.95)
                                        )
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                }
                                .offset(
                                    y: -resetSize * 0.01
                                )
                                .scaleEffect(
                                    isBreathing
                                        ? 1.01
                                        : 0.99
                                )
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Reset")
                        .accessibilityHint(
                            "Start a new reset"
                        )
                        .onAppear {

                            guard !isBreathing else {
                                return
                            }

                            withAnimation(
                                .easeInOut(
                                    duration: 1.35
                                )
                                .repeatForever(
                                    autoreverses: true
                                )
                            ) {
                                isBreathing = true
                            }
                        }

                        // MARK: Reset avatar

                        if !isGuestAfterFirstReset {

                            Image("avatar_smile")
                                .resizable()
                                .scaledToFit()
                                .frame(
                                    width: avatarSize,
                                    height: avatarSize
                                )
                                .offset(
                                    x: resetSize * 0.43,
                                    y: -resetSize * 0.42
                                )
                                .allowsHitTesting(false)
                                .accessibilityHidden(true)
                        }
                    }

                    // MARK: Message

                    Text(
                        isGuestAfterFirstReset
                            ? "save your reset and\nkeep your progress going"
                            : vm.homeMessage
                    )
                    .font(
                        .system(
                            size: subtitleSize
                        )
                    )
                    .foregroundColor(.gray)
                    .multilineTextAlignment(
                        .center
                    )
                    .lineLimit(3)
                    .minimumScaleFactor(0.75)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
                    .frame(
                        maxWidth: 340
                    )
                    .padding(
                        .horizontal,
                        horizontalPadding
                    )

                    Spacer(
                        minLength: bottomSpacing
                    )
                }
                .frame(
                    width: screenWidth,
                    height: screenHeight,
                    alignment: .top
                )

                // MARK: Guest completed avatar

                if isGuestAfterFirstReset {

                    Image("avatar_happy")
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: avatarSize,
                            height: avatarSize
                        )
                        .padding(
                            .leading,
                            horizontalPadding
                        )
                        .offset(
                            x: 4,
                            y: 0
                        )
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }
            }
        }
    }
}*/
