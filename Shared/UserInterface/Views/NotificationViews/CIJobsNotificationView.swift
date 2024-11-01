//
//  CIJobsNotificationView.swift
//  
//
//  Created by Stef Kors on 29/06/2022.
//

import SwiftUI

 struct CIJobsNotificationView: View {
     var stages: [GitLab.FluffyNode?]

     init (stages: [GitLab.FluffyNode?]?) {
        self.stages = stages ?? []
    }

     var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(stages.indices, id: \.self) { index in
                if let stage = stages[index],
                   let jobs = stage.jobs?.edges?.map({ $0.node }) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(stage.name?.capitalized ?? "")
                            .fontWeight(.bold)
                            .padding(.bottom, 4)
                        ForEach(jobs.indices, id: \.self) { index in
                            if let job = jobs[index] {
                                HStack {
                                    CIStatusView(status: job.status)
                                    Text(job.name ?? "")
                                }
                            }
                        }
                    }.padding()
                }
            }
        }

    }
}

struct CIJobsNotificationView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CIJobsNotificationView(stages: [.previewBuild, .previewTest])
            Button("generate") {
#if os(macOS)
                do {
                    let renderView = CIJobsNotificationView(stages: [.previewBuild, .previewTest])
                        // .padding()
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
#endif
            }
        }
            // .frame(width: 200, height: 200, alignment: .center)
    }
}
