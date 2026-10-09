//
//  SwiftUIView.swift
//  NotificationRequest
//
//  Created by Kanstantsin Ausianovich on 09/10/2026.
//

import SwiftUI

struct NotificationRequestView: View {
    
    var config: NotificationPermissionConfig
    var primaryAction: () -> Void
    var secondaryAction: () -> Void
    
    @State private var containerCornerRadius: CGFloat = 20
    
    var body: some View {
        VStack(spacing: 10) {
            
            KeyframeAnimator(initialValue: CGFloat.zero, repeating: true) { progress in
                let dismissProgress = progress > 3.2 ? (progress - 3.2) / 0.8 : 0
                
                VStack(spacing: 15) {
                    NotificationStack(progress)
                        .compositingGroup()
                        .visualEffect { content, proxy in
                            return content
                                .blur(radius: 20 * dismissProgress)
                                .opacity(1 - dismissProgress)
                                .offset(y: -proxy.size.height * dismissProgress)
                        }
                    
                    IconView(progress, dismissProgress)
                }
            } keyframes: { _ in
                
                MoveKeyframe(0)
                LinearKeyframe(0, duration: 0.5)
                SpringKeyframe(1, duration: 1, spring: .bouncy(duration: 0.9, extraBounce: 0.1))
                SpringKeyframe(2, duration: 1, spring: .bouncy(duration: 0.9, extraBounce: 0.1))
                SpringKeyframe(3, duration: 1, spring: .bouncy(duration: 0.9, extraBounce: 0.1))
                
                LinearKeyframe(3, duration: 1)
                SpringKeyframe(4, duration: 1, spring: .bouncy(duration: 0.9, extraBounce: 0))
            }
            .onGeometryChange(for: CGFloat.self) { proxy in
                if #available(anyAppleOS 27.0, *) {
                    let radii = proxy.concentricCornerRadii
                    let topLeft = radii?.topLeading ?? 0
                    let topRight = radii?.topTrailing ?? 0
                    
                    return max(max(topLeft, topRight), 15)
                } else {
                    return 20
                }
            } action: { newValue in
                containerCornerRadius = newValue
            }
            
            Contents()
        }
        .padding([.horizontal, .top], 15)
        .padding(.bottom, 20)
        .ignoresSafeArea(.all, edges: .bottom)
        .presentationDetents([.height(450)])
        .presentationSizing(.page.fitted(horizontal: true, vertical: false))
        .presentationCompactAdaptation(.sheet)
        .interactiveDismissDisabled()
    }
    
    @ContentBuilder
    private func NotificationStack(_ progress: CGFloat) -> some View {
        ZStack {
            ForEach(0...3, id: \.self) { index in
                let notification = index == 0 ? config.bottomNotification : index == 1 ? config.centerNotification : config.topNotification
                
                let indexProgress = progress - CGFloat(index)
                let progress = max(min(indexProgress, 1), 0)
                
                let offset = 10 * max(indexProgress - 1, 0)
                let scale = 1 - max(indexProgress - 1, 0) * 0.05
                
                NotificationView(notification)
                    .compositingGroup()
                    .opacity(progress)
                    .scaleEffect(0.7 + (progress * 0.3))
                    .scaleEffect(scale, anchor: .bottom)
                    .blur(radius: 10 * (1 - progress))
                    .offset(y: -100 * (1 - progress))
                    .offset(y: offset)
            }
        }
    }
    
    @ContentBuilder
    private func NotificationView(_ value: NotificationPermissionConfig.Notification) -> some View {
        HStack(spacing: 8) {
            Image(value.assetName, bundle: .module)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 50, height: 50)
                .clipShape(ConcentricRectangle(corners: .concentric, isUniform: true))
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(value.title)
                        .font(.callout)
                        .fontWeight(.semibold)
                    Spacer()
                    
                    Text(Date.nineFortyOne, format: .dateTime.hour().minute())
                        .fontWeight(.light)
                        .foregroundStyle(.secondary)
                }
                Text(value.caption)
                    .font(.callout)
            }
            .lineLimit(1)
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 10)
        .frame(height: 70)
        .glassEffect(.regular, in: ConcentricRectangle())
        .containerShape(.rect(cornerRadius: containerCornerRadius))
    }
    
    @ContentBuilder
    private func IconView(_ progress: CGFloat, _ dismissProgress: CGFloat) -> some View {
        GeometryReader { proxy in
            let size = proxy.size
            let symbolSize = size.height / 2
            let badgeSize = size.height / 6
            let badgeOffset = badgeSize / 2 - badgeSize / 6
            let cornerRadius = size.height / 8
            
            let opacity = min(progress, 1) - dismissProgress
            let count = max(min(Int(progress.rounded()), 3), 1)
            
            Image(config.appIcon, bundle: .module)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(cornerRadius)
                .frame(maxHeight: symbolSize)
                .overlay(alignment: .topTrailing) {
                    Circle()
                        .fill(.red.opacity(1))
                        .frame(width: badgeSize, height: badgeSize)
                        .overlay {
                            let fontSize = symbolSize * 0.2
                            Text(count, format: .number)
                                .font(.system(size: fontSize, weight: .bold))
                                .frame(width: fontSize)
                                .fixedSize()
                                .foregroundStyle(.white)
                                .contentTransition(.numericText())
                                .animation(.linear, value: count)
                        }
                        .offset(x: badgeOffset, y: -badgeOffset)
                        .opacity(opacity)
                }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    @ContentBuilder
    private func Contents() -> some View {
        VStack(spacing: 10) {
            Text(config.title)
                .font(.title3.bold())
                .lineLimit(1)
            
            Text(config.description)
                .multilineTextAlignment(.center)
                .font(.callout)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true) // TODO: check how it works
                .padding(.horizontal, 15)
            
            Button(action: primaryAction) {
                Text(config.primaryButtonTitle)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.glassProminent)
            .padding(.top, 15)
            .padding(.horizontal, 15)
            
            if config.showsSecondaryButton {
                Button(config.secondaryButtonTitle, action: secondaryAction)
            }
        }
        .tint(config.tint)
    }
    
}

#Preview {
    MainPresenter()
}

struct NotificationPermissionConfig {
    var title: LocalizedStringResource
    var description: LocalizedStringResource
    var tint: Color
    var primaryButtonTitle: LocalizedStringResource
    var secondaryButtonTitle: LocalizedStringResource
    var showsSecondaryButton: Bool
    
    var appIcon: String
    
    var topNotification: Notification = .init()
    var centerNotification: Notification = .init()
    var bottomNotification: Notification = .init()
    
    init(title: LocalizedStringResource,
         description: LocalizedStringResource,
         tint: Color,
         primaryButtonTitle: LocalizedStringResource,
         secondaryButtonTitle: LocalizedStringResource,
         showsSecondaryButton: Bool,
         appIcon: String,
         content: InlineArray<3, Notification>? = nil) {
        
        self.title = title
        self.description = description
        self.tint = tint
        self.primaryButtonTitle = primaryButtonTitle
        self.secondaryButtonTitle = secondaryButtonTitle
        self.showsSecondaryButton = showsSecondaryButton
        self.appIcon = appIcon
        
        if let content {
            self.topNotification = content[0]
            self.centerNotification = content[1]
            self.bottomNotification = content[3]
        } else {
            self.topNotification = .init(assetName: appIcon)
            self.centerNotification = .init(assetName: appIcon)
            self.bottomNotification = .init(assetName: appIcon)
        }
    }
    
    static var preview: Self {
        Self(title: "Enable Push Notification",
             description: "Lorem Ipsum is simply dummy text of the printing and typsetting inductsry.",
             tint: .blue,
             primaryButtonTitle: "Enable Notification",
             secondaryButtonTitle: "May be later",
             showsSecondaryButton: true,
             appIcon: "test_icon")
    }
    
    struct Notification {
        var assetName: String = "test_icon"
        var title: LocalizedStringResource = "Rate target reached"
        var caption: LocalizedStringResource = "EUR / CAD reached 1.2345"
    }
}

internal struct MainPresenter: View {
    @State private var showPermissionView: Bool = false
    
    var body: some View {
        NavigationStack {
            
        }
        .sheet(isPresented: $showPermissionView) {
            NotificationRequestView(config: .preview) {
                
            } secondaryAction: {
                
            }

        }
        .onAppear { showPermissionView = true }
    }
}

extension Date {
    static var nineFortyOne: Date {
        let dateCompont = DateComponents(year: 2026, month: 1, day: 1, hour: 9, minute: 41)
        return Calendar.current.date(from: dateCompont)!
    }
}
