//
//  PanicView.swift
//  Return
//
//  Panic Button Screen - Quittr-inspired with typewriter effect
//

import SwiftUI
import SwiftData
import AVFoundation

struct PanicView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \WhyEntry.createdDate, order: .reverse) private var whyEntries: [WhyEntry]

    // Navigation states
    @State private var showTemptedFlow: Bool = false
    @State private var showRelapsedFlow: Bool = false

    // Typewriter state
    @State private var displayedText: String = ""
    @State private var currentMessageIndex: Int = 0
    @State private var isTyping: Bool = false
    @State private var isActive: Bool = true

    // Colors
    private let coralRed = Color(hex: "E85A4F")
    private let darkRed = Color(hex: "8B3A3A")

    // Motivational messages that will typewrite
    private let messages: [String] = [
        "IT'S OKAY TO FEEL TEMPTED—BUT DON'T GIVE IN.",
        "REMEMBER WHY YOU STARTED THIS JOURNEY.",
        "ALLAH IS WITH THOSE WHO ARE PATIENT.",
        "THIS URGE WILL PASS IN 10-15 MINUTES.",
        "YOU ARE STRONGER THAN THIS MOMENT.",
        "LOOK AT YOURSELF. YOU CAN DO THIS.",
        "YOUR FUTURE SELF WILL THANK YOU.",
        "EVERY VICTORY OVER DESIRE IS A STEP CLOSER TO ALLAH."
    ]

    var body: some View {
        ZStack {
            // Starry background
            SpaceBackground()

            // Content
            VStack(spacing: 0) {
                // Top bar with close button
                HStack {
                    Spacer()

                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white.opacity(0.7))
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.15))
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                // Title
                VStack(spacing: 8) {
                    Text("Return")
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .foregroundColor(.white)

                    Text("Panic Button")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(coralRed)
                }
                .padding(.top, 8)

                Spacer().frame(height: 24)

                // Camera view with typewriter overlay
                ZStack(alignment: .bottom) {
                    // Camera preview
                    CameraPreviewView()
                        .frame(maxWidth: .infinity)
                        .aspectRatio(3/4, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.horizontal, 24)

                    // Typewriter text overlay
                    Text(displayedText)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .shadow(color: .black.opacity(0.8), radius: 4, x: 0, y: 2)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.black.opacity(0.5))
                                .blur(radius: 0.5)
                        )
                        .padding(.horizontal, 32)
                        .padding(.bottom, 16)
                }

                Spacer().frame(height: 20)

                // Remember Your Why section
                RememberYourWhySection(whyEntries: whyEntries)
                    .padding(.horizontal, 24)

                Spacer().frame(height: 20)

                // Action buttons
                VStack(spacing: 12) {
                    // I Relapsed - lighter style
                    Button(action: {
                        triggerHaptic(.heavy)
                        showRelapsedFlow = true
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "hand.thumbsdown.fill")
                                .font(.system(size: 16))
                            Text("I Relapsed")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundColor(coralRed)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(darkRed.opacity(0.3))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 28)
                                        .stroke(darkRed.opacity(0.5), lineWidth: 1)
                                )
                        )
                    }

                    // I'm thinking of relapsing - primary red
                    Button(action: {
                        triggerHaptic(.medium)
                        showTemptedFlow = true
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 16))
                            Text("I'm thinking of relapsing")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(coralRed)
                                .shadow(color: coralRed.opacity(0.4), radius: 12, y: 4)
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            startTypewriter()
        }
        .onDisappear {
            isActive = false
        }
        .fullScreenCover(isPresented: $showTemptedFlow) {
            TemptedFlowView(onComplete: {
                dismiss()
            })
        }
        .fullScreenCover(isPresented: $showRelapsedFlow) {
            RelapsedFlowView(onComplete: {
                dismiss()
            })
        }
    }

    // MARK: - Typewriter Effect
    private func startTypewriter() {
        displayedText = ""
        isTyping = true
        typeNextCharacter(for: messages[currentMessageIndex], index: 0)
    }

    private func typeNextCharacter(for message: String, index: Int) {
        guard isActive else { return }  // Stop if view dismissed

        guard index < message.count else {
            // Message complete, wait then show next
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [self] in
                guard isActive else { return }
                currentMessageIndex = (currentMessageIndex + 1) % messages.count
                displayedText = ""
                typeNextCharacter(for: messages[currentMessageIndex], index: 0)
            }
            return
        }

        let stringIndex = message.index(message.startIndex, offsetBy: index)
        let character = message[stringIndex]

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [self] in
            guard isActive else { return }
            displayedText += String(character)

            // Haptic feedback for each character (light tap)
            if character != " " {
                triggerHaptic(.light)
            }

            typeNextCharacter(for: message, index: index + 1)
        }
    }

    private func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

// MARK: - Camera Preview
struct CameraPreviewView: View {
    @StateObject private var cameraManager = CameraManager()

    var body: some View {
        ZStack {
            if cameraManager.isAuthorized {
                // Real camera preview
                CameraPreviewRepresentable(session: cameraManager.session)
            } else {
                // Fallback when no camera permission
                CameraPlaceholderView()
            }
        }
        .onAppear {
            cameraManager.checkPermissionAndStart()
        }
        .onDisappear {
            cameraManager.stop()
        }
    }
}

// MARK: - Camera Manager
class CameraManager: ObservableObject {
    @Published var isAuthorized: Bool = false
    let session = AVCaptureSession()
    private var isConfigured = false

    func checkPermissionAndStart() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isAuthorized = true
            configureAndStart()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.isAuthorized = granted
                    if granted {
                        self?.configureAndStart()
                    }
                }
            }
        default:
            isAuthorized = false
        }
    }

    private func configureAndStart() {
        guard !isConfigured else {
            if !session.isRunning {
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    self?.session.startRunning()
                }
            }
            return
        }

        // Move ALL camera configuration to background thread
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            self.session.beginConfiguration()
            self.session.sessionPreset = .high

            // Front camera
            guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
                  let input = try? AVCaptureDeviceInput(device: camera) else {
                self.session.commitConfiguration()
                return
            }

            if self.session.canAddInput(input) {
                self.session.addInput(input)
            }

            self.session.commitConfiguration()

            DispatchQueue.main.async {
                self.isConfigured = true
            }

            self.session.startRunning()
        }
    }

    func stop() {
        if session.isRunning {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.session.stopRunning()
            }
        }
    }
}

// MARK: - UIKit Camera Preview
struct CameraPreviewRepresentable: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> CameraPreviewUIView {
        let view = CameraPreviewUIView()
        view.session = session
        return view
    }

    func updateUIView(_ uiView: CameraPreviewUIView, context: Context) {}
}

class CameraPreviewUIView: UIView {
    var session: AVCaptureSession? {
        didSet {
            if let session = session {
                previewLayer.session = session
            }
        }
    }

    private var previewLayer: AVCaptureVideoPreviewLayer!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPreviewLayer()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupPreviewLayer()
    }

    private func setupPreviewLayer() {
        previewLayer = AVCaptureVideoPreviewLayer()
        previewLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(previewLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer.frame = bounds
    }
}

// MARK: - Camera Placeholder (Fallback)
struct CameraPlaceholderView: View {
    @State private var pulseAnimation: Bool = false

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    Color(hex: "1A2332"),
                    Color(hex: "0F1620")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Subtle pulse effect
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "5B9A9A").opacity(0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: pulseAnimation ? 180 : 120
                    )
                )
                .scaleEffect(pulseAnimation ? 1.1 : 0.9)

            // Person icon
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 100, height: 100)

                    Image(systemName: "camera.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color.white.opacity(0.3))
                }

                Text("Enable camera in Settings")
                    .font(.system(size: 13))
                    .foregroundColor(Color.white.opacity(0.4))
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                pulseAnimation = true
            }
        }
    }
}

// MARK: - Remember Your Why Section (for Panic View)
struct RememberYourWhySection: View {
    let whyEntries: [WhyEntry]

    private let warmGold = Color(hex: "E8B86D")

    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 14))
                    .foregroundColor(warmGold)

                Text("Remember Your Why")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)

                Spacer()
            }

            if whyEntries.isEmpty {
                Text("Tap to add your reasons for this journey")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.white.opacity(0.4))
                    .padding(.vertical, 8)
            } else {
                // Scrollable why cards
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(whyEntries) { entry in
                            PanicWhyCard(entry: entry)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Panic Why Card (compact version)
struct PanicWhyCard: View {
    let entry: WhyEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Category icon
            HStack(spacing: 6) {
                Image(systemName: entry.categoryEnum.icon)
                    .font(.system(size: 11))
                Text(entry.category)
                    .font(.system(size: 11, weight: .semibold))
            }
            .foregroundColor(entry.categoryEnum.color)

            // Content
            Text(entry.content)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(3)
                .lineSpacing(2)
        }
        .padding(12)
        .frame(width: 200, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.black.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(entry.categoryEnum.color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

#Preview {
    PanicView()
}
