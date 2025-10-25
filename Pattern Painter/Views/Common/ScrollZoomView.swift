//
//  ScrollZoomView.swift
//  Pattern Painter
//
//  Created by Trevor Behlman on 10/12/25.
//

import SwiftUI

struct ScrollZoomView<Content: View>: UIViewRepresentable {
    let scrollEnabled: Bool
    @Binding var offset: CGPoint
    @ViewBuilder var content: Content

    @Environment(\.minPuzzleMetrics) var minPuzzleMetrics
    @AppStorage("tileSize") var tileSize = AppDefaults.tileSize

    class Coordinator: NSObject, UIScrollViewDelegate {
        let representative: ScrollZoomView
        let host: UIHostingController<Content>
        let viewToZoom = UIView()
        let widthConstraint: NSLayoutConstraint
        let heightConstraint: NSLayoutConstraint
        var scrollView: UIScrollView?
        var isAnimating = false
        lazy var displayLink: CADisplayLink = {
            CADisplayLink(target: self, selector: #selector(displayLinkCallback))
        }()

        init(_ representative: ScrollZoomView, _ host: UIHostingController<Content>) {
            self.representative = representative
            self.host = host
            widthConstraint = viewToZoom.widthAnchor.constraint(equalToConstant: 0)
            heightConstraint = viewToZoom.heightAnchor.constraint(equalToConstant: 0)
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            guard !isAnimating else { return }
            representative.offset = scrollView.contentOffset
            representative.tileSize = AppDefaults.minTileSize * scrollView.zoomScale
        }

        @objc func displayLinkCallback(_ target: CADisplayLink) {
            let offset = scrollView?.layer.presentation()?.bounds.origin
            if let offset, offset != representative.offset {
                representative.offset = offset
            } else {
                displayLink.remove(from: .current, forMode: .common)
                isAnimating = false
            }
        }

        func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
            isAnimating = true
            self.scrollView = scrollView
            displayLink.preferredFrameRateRange = CAFrameRateRange(minimum: 240, maximum: 240)
            displayLink.add(to: .current, forMode: .common)
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            viewToZoom
        }
    }

    func makeCoordinator() -> Coordinator {
        let contentController = UIHostingController(rootView: content)
        contentController.sizingOptions = .intrinsicContentSize
        return Coordinator(self, contentController)
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.clipsToBounds = false
        scrollView.bouncesZoom = false
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = AppDefaults.maxTileSize / AppDefaults.minTileSize
        scrollView.zoomScale = tileSize / AppDefaults.minTileSize

        let viewToZoom = context.coordinator.viewToZoom
        viewToZoom.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(viewToZoom)

        let contentController = context.coordinator.host
        contentController.view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentController.view)

        updateConstraints(scrollView, context: context)

        NSLayoutConstraint.activate([
            viewToZoom.topAnchor.constraint(equalTo: scrollView.topAnchor),
            viewToZoom.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            viewToZoom.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            viewToZoom.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            context.coordinator.widthConstraint,
            context.coordinator.heightConstraint,
        ])

        return scrollView
    }

    func updateConstraints(_ scrollView: UIScrollView, context: Context) {
        context.coordinator.widthConstraint.constant = minPuzzleMetrics.totalSize.width
        context.coordinator.heightConstraint.constant = minPuzzleMetrics.totalSize.height
    }

    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        scrollView.isScrollEnabled = scrollEnabled
        context.coordinator.host.rootView = content
        updateConstraints(scrollView, context: context)
    }
}
