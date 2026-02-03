//
//  PanicView.swift
//  Return
//
//  Panic Button Screen - Quittr-inspired with typewriter effect
//

import SwiftUI
import SwiftData
import AVFoundation
import QuartzCore

enum PanicPerfTrace {
    static var tapTime: CFTimeInterval?
    static var sessionID: Int = 0

    static func markTap(source: String) {
        let now = CACurrentMediaTime()
        tapTime = now
        sessionID += 1
        log("panic tap source=\(source)", now: now, sessionID: sessionID)
    }

    static func currentSessionID() -> Int {
        sessionID
    }

    static func log(_ message: String, now: CFTimeInterval = CACurrentMediaTime(), sessionID: Int? = nil) {
#if DEBUG
        let sid = sessionID ?? self.sessionID
        if let tap = tapTime {
            let delta = String(format: "%.3f", now - tap)
            print("[PanicPerf s\(sid) +\(delta)s] \(message)")
        } else {
            print("[PanicPerf s\(sid)] \(message)")
        }
#endif
    }
}

struct PanicView: View {
    @Environment(\.dismiss) private var dismiss

    // Navigation states
    @State private var showTemptedFlow: Bool = false
    @State private var showRelapsedFlow: Bool = false

    // Typewriter state
    @State private var displayedText: String = ""
    @State private var currentMessageIndex: Int = 0
    @State private var isTyping: Bool = false
    @State private var isActive: Bool = true
    @State private var perfSessionID: Int = PanicPerfTrace.currentSessionID()
    @State private var didLogFirstCharacter: Bool = false
    @State private var typewriterTimer: Timer?
    @State private var currentCharIndex: Int = 0

    // Deferred camera start - ensures UI renders before camera initialization
    @State private var shouldStartCamera: Bool = false

    // Colors
    private let coralRed = Color(hex: "D64545")
    private let darkRed = Color(hex: "8B3A3A")

    // Haptic generator - reuse single instance instead of creating per character
    private let hapticGenerator = UIImpactFeedbackGenerator(style: .light)

    // Islamic messages that will typewrite
    private let messages: [String] = [
        "LOWER YOUR GAZE. ALLAH IS WATCHING.",
        "THIS SIN ISN'T WORTH YOUR AKHIRAH.",
        "SHAYTAN WANTS YOU TO FAIL. PROVE HIM WRONG.",
        "THIS URGE WILL PASS IN 10 MINUTES. YOUR REGRET WON'T.",
        "YOUR SOUL DESERVES BETTER THAN THIS.",
        "LOOK AT YOURSELF. IS THIS WHO YOU WANT TO BE?",
        "ALLAH IS WITH THOSE WHO ARE PATIENT.",
        "10 MINUTES OF PLEASURE. HOURS OF EMPTINESS."
    ]

    var body: some View {
        ZStack {
            // Starry background
            SpaceBackground()

            // Content
            VStack(spacing: 0) {
                // Top bar with logo and close button
                HStack {
                    // Invisible spacer for balance
                    Color.clear
                        .frame(width: 44, height: 44)

                    Spacer()

                    // Logo centered - white, prominent for brand recognition
                    Image("ReturnLogo")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.white)
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 50)

                    Spacer()

                    // Close button
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

                // Panic Button title
                Text("Panic Button")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(coralRed)
                    .padding(.top, 6)

                Spacer().frame(height: 24)

                // Camera view with typewriter overlay
                ZStack(alignment: .bottom) {
                    // Camera preview with red glow
                    CameraPreviewView(sessionID: perfSessionID, startRequested: $shouldStartCamera)
                        .frame(maxWidth: .infinity)
                        .aspectRatio(4/4.5, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(coralRed.opacity(0.4), lineWidth: 2)
                        )
                        .shadow(color: coralRed.opacity(0.5), radius: 30, x: 0, y: 0)
                        .shadow(color: coralRed.opacity(0.3), radius: 60, x: 0, y: 0)
                        .padding(.horizontal, 16)

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

                Spacer().frame(height: 16)

                // Side Effects of Relapsing section
                SideEffectsSection()
                    .padding(.horizontal, 24)

                Spacer().frame(height: 16)

                // Action buttons
                VStack(spacing: 12) {
                    // I'm thinking of relapsing - PRIMARY (most users need help)
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
                                .fill(Color(hex: "EB2623"))
                                .shadow(color: Color(hex: "EB2623").opacity(0.4), radius: 12, y: 4)
                        )
                    }

                    // I Relapsed - muted secondary (guide users toward help first)
                    Button(action: {
                        triggerHaptic(.heavy)
                        showRelapsedFlow = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 13))
                            Text("I Relapsed")
                                .font(.system(size: 15, weight: .medium))
                        }
                        .foregroundColor(.white.opacity(0.5))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(Color.white.opacity(0.06))
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            if PanicPerfTrace.currentSessionID() == 0 {
                PanicPerfTrace.markTap(source: "panic_view_direct_open")
            }
            perfSessionID = PanicPerfTrace.currentSessionID()
            didLogFirstCharacter = false
            PanicPerfTrace.log("PanicView onAppear", sessionID: perfSessionID)
            hapticGenerator.prepare()  // Warm up haptic engine
            startTypewriter()

            // Defer camera start to ensure UI renders first (300ms after view appears)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [self] in
                guard isActive else { return }
                PanicPerfTrace.log("triggering deferred camera start", sessionID: perfSessionID)
                shouldStartCamera = true
            }
        }
        .onDisappear {
            isActive = false
            stopTypewriter()
            shouldStartCamera = false
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

    // MARK: - Typewriter Effect (Timer-based for resilience to UI blocking)
    private func startTypewriter() {
        let message = messages[currentMessageIndex]
        isTyping = true

        // Show first character IMMEDIATELY (synchronous, no timer delay)
        // This ensures user sees feedback even if main thread hiccups
        if !message.isEmpty {
            let firstChar = message[message.startIndex]
            displayedText = String(firstChar)
            currentCharIndex = 1

            if !didLogFirstCharacter {
                didLogFirstCharacter = true
                PanicPerfTrace.log("first typewriter character rendered", sessionID: perfSessionID)
            }
        } else {
            displayedText = ""
            currentCharIndex = 0
        }

        // Continue with timer for remaining characters
        typewriterTimer?.invalidate()
        typewriterTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [self] timer in
            guard isActive else {
                timer.invalidate()
                return
            }

            guard currentCharIndex < message.count else {
                // Message complete - pause then switch to next
                timer.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [self] in
                    guard isActive else { return }
                    currentMessageIndex = (currentMessageIndex + 1) % messages.count
                    startTypewriter()
                }
                return
            }

            let stringIndex = message.index(message.startIndex, offsetBy: currentCharIndex)
            let character = message[stringIndex]
            displayedText += String(character)
            currentCharIndex += 1

            // Throttled haptics: only on word boundaries (spaces) and punctuation
            if character == " " || character == "." || character == "!" || character == "?" || character == "'" {
                hapticGenerator.impactOccurred()
            }
        }

        // Ensure timer runs during UI transitions
        if let timer = typewriterTimer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    private func stopTypewriter() {
        typewriterTimer?.invalidate()
        typewriterTimer = nil
    }

    private func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

// MARK: - Camera Preview
enum CameraStartupState: Equatable {
    case idle
    case starting
    case ready
    case denied
    case failed
}

struct CameraPreviewView: View {
    let sessionID: Int
    @Binding var startRequested: Bool
    @StateObject private var cameraManager: CameraManager

    init(sessionID: Int, startRequested: Binding<Bool>) {
        self.sessionID = sessionID
        self._startRequested = startRequested
        _cameraManager = StateObject(wrappedValue: CameraManager(sessionID: sessionID))
    }

    private var placeholderTitle: String {
        switch cameraManager.startupState {
        case .idle, .starting:
            return cameraManager.isSlowStartup ? "Still starting camera..." : "Starting camera..."
        case .denied:
            return "Enable camera in Settings"
        case .failed:
            return "Camera unavailable"
        case .ready:
            return ""
        }
    }

    private var placeholderSubtitle: String {
        switch cameraManager.startupState {
        case .idle, .starting:
            return cameraManager.isSlowStartup
                ? "This can take a few seconds on first open."
                : "Hold steady while we prepare your camera."
        case .denied:
            return "You can continue without camera preview."
        case .failed:
            return "You can still use Panic mode without camera."
        case .ready:
            return ""
        }
    }

    private var showPlaceholderProgress: Bool {
        cameraManager.startupState == .idle || cameraManager.startupState == .starting
    }

    var body: some View {
        ZStack {
            if cameraManager.startupState == .ready && cameraManager.isAuthorized {
                // Real camera preview
                CameraPreviewRepresentable(session: cameraManager.session)
                    .transition(.opacity)
            } else {
                // Fallback while camera starts or when unavailable
                CameraPlaceholderView(
                    title: placeholderTitle,
                    subtitle: placeholderSubtitle,
                    showProgress: showPlaceholderProgress
                )
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: cameraManager.startupState)
        .onChange(of: startRequested) { _, shouldStart in
            if shouldStart {
                cameraManager.checkPermissionAndStart()
            }
        }
        .onDisappear {
            cameraManager.stop()
        }
    }
}

// MARK: - Camera Manager
class CameraManager: NSObject, ObservableObject {
    @Published var isAuthorized: Bool = false
    @Published var startupState: CameraStartupState = .idle
    @Published var isSlowStartup: Bool = false

    // Lazy session creation - AVCaptureSession() can be slow on first call
    private var _session: AVCaptureSession?
    var session: AVCaptureSession {
        if let existing = _session {
            return existing
        }
        PanicPerfTrace.log("AVCaptureSession() creating", sessionID: sessionID)
        let newSession = AVCaptureSession()
        PanicPerfTrace.log("AVCaptureSession() created", sessionID: sessionID)
        _session = newSession
        return newSession
    }

    private var isConfigured = false
    private let sessionID: Int
    private let sessionQueue = DispatchQueue(label: "com.imanpath.panic.camera-session", qos: .userInitiated)
    private var slowStartupWorkItem: DispatchWorkItem?
    private var startupTimeoutWorkItem: DispatchWorkItem?

    init(sessionID: Int) {
        self.sessionID = sessionID
        // Don't create AVCaptureSession here - do it lazily on background queue
        super.init()
    }

    func checkPermissionAndStart() {
        guard startupState != .starting else { return }

        startupState = .starting
        isSlowStartup = false
        scheduleStartupMonitors()

        PanicPerfTrace.log("camera checkPermissionAndStart", sessionID: sessionID)

        // Resolve authorization off the main thread so UI can render fallback immediately.
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            PanicPerfTrace.log("background: before authorizationStatus", sessionID: self.sessionID)
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            PanicPerfTrace.log("background: after authorizationStatus, status=\(status.rawValue)", sessionID: self.sessionID)
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                PanicPerfTrace.log("main: handleAuthorizationStatus", sessionID: self.sessionID)
                self.handleAuthorizationStatus(status)
            }
        }
    }

    private func handleAuthorizationStatus(_ status: AVAuthorizationStatus) {
        switch status {
        case .authorized:
            isAuthorized = true
            configureAndStart()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.isAuthorized = granted
                    if granted {
                        self?.configureAndStart()
                    } else {
                        self?.startupState = .denied
                        self?.cancelStartupMonitors()
                    }
                }
            }
        default:
            isAuthorized = false
            startupState = .denied
            cancelStartupMonitors()
        }
    }

    private func configureAndStart() {
        PanicPerfTrace.log("configureAndStart called", sessionID: sessionID)
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            PanicPerfTrace.log("sessionQueue: configureAndStart begin", sessionID: self.sessionID)

            // Access session property to trigger lazy creation ON this background queue
            let captureSession = self.session

            if self.isConfigured {
                if !captureSession.isRunning {
                    PanicPerfTrace.log("camera startRunning begin (already configured)", sessionID: self.sessionID)
                    captureSession.startRunning()
                    PanicPerfTrace.log("camera startRunning end (already configured)", sessionID: self.sessionID)
                }

                DispatchQueue.main.async {
                    self.startupState = .ready
                    self.isSlowStartup = false
                    self.cancelStartupMonitors()
                }
                return
            }

            PanicPerfTrace.log("camera configure begin", sessionID: self.sessionID)

            captureSession.beginConfiguration()
            captureSession.sessionPreset = .high

            // Front camera
            guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
                  let input = try? AVCaptureDeviceInput(device: camera) else {
                captureSession.commitConfiguration()
                DispatchQueue.main.async {
                    self.startupState = .failed
                    self.cancelStartupMonitors()
                }
                return
            }

            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }

            captureSession.commitConfiguration()
            PanicPerfTrace.log("camera configure end", sessionID: self.sessionID)

            DispatchQueue.main.async {
                self.isConfigured = true
            }

            PanicPerfTrace.log("camera startRunning begin", sessionID: self.sessionID)
            captureSession.startRunning()
            PanicPerfTrace.log("camera startRunning end", sessionID: self.sessionID)

            DispatchQueue.main.async {
                self.startupState = .ready
                self.isSlowStartup = false
                self.cancelStartupMonitors()
            }
        }
    }

    func stop() {
        cancelStartupMonitors()
        isSlowStartup = false
        startupState = .idle

        // Only stop if session was actually created
        guard let captureSession = _session, captureSession.isRunning else { return }

        sessionQueue.async { [weak self] in
            guard let self else { return }
            PanicPerfTrace.log("camera stopRunning begin", sessionID: self.sessionID)
            captureSession.stopRunning()
            PanicPerfTrace.log("camera stopRunning end", sessionID: self.sessionID)
        }
    }

    private func scheduleStartupMonitors() {
        slowStartupWorkItem?.cancel()
        startupTimeoutWorkItem?.cancel()

        let slowHint = DispatchWorkItem { [weak self] in
            guard let self, self.startupState == .starting else { return }
            self.isSlowStartup = true
        }
        slowStartupWorkItem = slowHint
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: slowHint)

        let timeout = DispatchWorkItem { [weak self] in
            guard let self, self.startupState == .starting else { return }
            self.startupState = .failed
            self.isSlowStartup = false
        }
        startupTimeoutWorkItem = timeout
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.0, execute: timeout)
    }

    private func cancelStartupMonitors() {
        slowStartupWorkItem?.cancel()
        startupTimeoutWorkItem?.cancel()
        slowStartupWorkItem = nil
        startupTimeoutWorkItem = nil
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
    let title: String
    let subtitle: String
    let showProgress: Bool

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

                if showProgress {
                    ProgressView()
                        .tint(Color.white.opacity(0.6))
                }

                Text(title)
                    .font(.system(size: 13))
                    .foregroundColor(Color.white.opacity(0.6))

                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(Color.white.opacity(0.45))
                    .multilineTextAlignment(.center)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                pulseAnimation = true
            }
        }
    }
}

// MARK: - Side Effects Section
struct SideEffectsSection: View {
    private let coralRed = Color(hex: "D64545")
    private let mutedGray = Color(hex: "6B7280")

    var body: some View {
        VStack(spacing: 12) {
            // Header with divider lines like Quittr
            HStack(spacing: 12) {
                Rectangle()
                    .fill(mutedGray.opacity(0.3))
                    .frame(height: 1)

                Text("Side Effects of Relapsing")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(mutedGray)
                    .fixedSize()

                Rectangle()
                    .fill(mutedGray.opacity(0.3))
                    .frame(height: 1)
            }

            // Three compact side effect items
            HStack(spacing: 14) {
                SideEffectItem(
                    icon: "🧠",
                    title: "BRAIN FOG",
                    subtitle: "Mind goes blank"
                )

                SideEffectItem(
                    icon: "💔",
                    title: "EMPTY",
                    subtitle: "Never satisfies"
                )

                SideEffectItem(
                    icon: "😞",
                    title: "GUILT",
                    subtitle: "Lasts for hours"
                )
            }
        }
    }
}

// MARK: - Side Effect Item
struct SideEffectItem: View {
    let icon: String
    let title: String
    let subtitle: String

    private let coralRed = Color(hex: "D64545")

    var body: some View {
        VStack(spacing: 8) {
            // Emoji icon
            Text(icon)
                .font(.system(size: 30))

            // Title
            Text(title)
                .font(.system(size: 11, weight: .heavy))
                .foregroundColor(coralRed)
                .tracking(0.5)

            // Subtitle
            Text(subtitle)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(coralRed.opacity(0.15), lineWidth: 1)
                )
        )
    }
}

#Preview {
    PanicView()
}
