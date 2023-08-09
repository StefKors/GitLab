//
//  BaseNoticeItem.swift
//
//
//  Created by Stef Kors on 25/07/2022.
//

import SwiftUI

public struct BaseNoticeItem: View {
    @EnvironmentObject public var noticeState: NoticeState
    // @Environment(\.colorScheme) private var colorScheme
    @Environment(\.openURL) private var openURL
    @State private var isHovering: Bool = false

    public var notice: NoticeMessage

    public init(notice: NoticeMessage) {
        self.notice = notice
    }

    public var body: some View {
        HStack(alignment: .center, spacing: 0) {
            if let statusCode = notice.statusCode {
                VStack(alignment: .center) {
                    ZStack {
                        HStack(alignment: .center) {
                            Image(systemName: "exclamationmark.icloud.fill")
                            // One bigger than the xmark icon to make sure background renders correctly
                                .font(.system(size: 19))
                                .help("Close")
                            Text("\(statusCode)")
                                .bold()
                        }
                    }
                }
                .padding()
                .background(notice.color.opacity(0.3))
            }
            VStack(alignment: .center) {
                ZStack {
                    HStack(alignment: .center) {
                        VStack(alignment: .leading) {
                            if notice.type == .branch {
                                Text(.init(notice.label)) + Text(" ") + Text(toRelativeDate(notice.createdAt))
                            } else {
                                Text(.init(notice.label))
                            }

                            if let url = notice.webLink {
                                Button(action: {
                                    openURL(url)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                                        withAnimation(.interpolatingSpring(stiffness: 500, damping: 15)) {
                                            noticeState.dismissNotice(id: notice.id)
                                        }
                                    }
                                }, label: {
                                    Label("Create merge request", image: "merge-request")
                                })
                            }
                        }.fixedSize(horizontal: false, vertical: true)
                        Spacer()
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18))
                            .help("Dismiss")
                            .opacity(isHovering ? 1 : 0.6)
                            .onHover { hoverState in
                                isHovering = hoverState
                            }
                            .onTapGesture {
                                noticeState.dismissNotice(id: notice.id)
                            }
                    }
                    .animation(.spring(), value: isHovering)
                }
            }
            .padding()
        }
        .modifier(NoticeTypeBackground(notice: notice))
        // TODO: fix on ios
        .shadow(color: Color(NSColor.shadowColor).opacity(0.15), radius: 5, x: 0, y: 3)
        // .shadow(color: Color(NSColor.shadowColor).opacity(0.15), radius: 5, x: 0, y: 3)
#if os(macOS)
#endif
    }

    fileprivate func toRelativeDate(_ date: Date) -> String {
        // guard let createdAt = createdAt,
        //       let date = GitLabISO8601DateFormatter.date(from: createdAt) else {
        //     return createdAt ?? ""
        // }

        let nowTime: Double = 60 * 3 // 3 min
        if abs(date.timeIntervalSinceNow) < nowTime {
            return "just now"
        }

        // ask for the full relative date
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date.now)
    }
}

public struct NoticeTypeBackground: ViewModifier {
    var notice: NoticeMessage

    let radius: CGFloat = 8
    public func body(content: Content) -> some View {
        if notice.type == .branch {
            content
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
        } else {
            content
                .background(notice.color.opacity(0.3), in: RoundedRectangle(cornerRadius: radius, style: .continuous))
        }
    }
}

struct BaseNoticeItem_Previews: PreviewProvider {
    static let networkManager = NetworkManager()
    static var previews: some View {
        VStack(spacing: 25) {
            BaseNoticeItem(notice: .previewInformationNotice)
            BaseNoticeItem(notice: .previewWarningNotice)
            BaseNoticeItem(notice: .previewErrorNotice)
            BaseNoticeItem(notice: .previewBranchPushNotice)
            Button("generate") {
                do {
                    let renderView = BaseNoticeItem(notice: .previewBranchPushNotice)
                        .padding(.bottom)
                        .padding(.horizontal)
                    // needed to render in the correct colorScheme
                        .colorScheme(.dark)

                    let renderer = ImageRenderer(content: renderView)
                    renderer.scale = 4.0
                    renderer.isOpaque = false
                    // renderer.proposedSize = .init(width: 120, height: 120)
                    guard let image = renderer.nsImage  else { return }
                    let folder = NSTemporaryDirectory() + "PreviewIcon/"
                    try? FileManager.default.removeItem(atPath: folder)
                    try FileManager.default.createDirectory(atPath: folder, withIntermediateDirectories: true)
                    let path = folder + "icon.png"
                    let imageRep = NSBitmapImageRep(data: image.tiffRepresentation!)
                    let pngData = imageRep?.representation(using: .png, properties: [:])
                    try pngData?.write(to: URL(filePath: path))
                    print(path.description)
                } catch {
                    print("error \(error.localizedDescription)")
                }
            }
        }
        .padding()
        .frame(height: 400)
        .environmentObject(self.networkManager)
        .environmentObject(self.networkManager.noticeState)
    }
}
