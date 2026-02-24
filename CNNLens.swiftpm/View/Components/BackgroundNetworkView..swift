//
//  BackgroundNetworkView..swift
//  CNNLens
//
//  Created by Amnah Albrahim on 02/09/1447 AH.
//
import SwiftUI

struct Node: Identifiable {
    let id = UUID()
    var position: CGPoint
    var velocity: CGPoint
}

struct BackgroundNetworkView: View {
    // You can override this when embedding if needed
    var backgroundColor: Color = Color(red: 0.02, green: 0.05, blue: 0.12) // dark blue

    @State private var nodes: [Node] = (0..<30).map { _ in
        Node(
            position: CGPoint(x: CGFloat.random(in: 0...1000), y: CGFloat.random(in: 0...1000)),
            velocity: CGPoint(x: CGFloat.random(in: -0.5...0.5), y: CGFloat.random(in: -0.5...0.5))
        )
    }

    @State private var lastSize: CGSize = .zero

    private let timer = Timer.publish(every: 1/60, on: .main, in: .common).autoconnect()

    var body: some View {
        Canvas { context, size in
            // Fill dark blue background
            let rectPath = Path(CGRect(origin: .zero, size: size))
            context.fill(rectPath, with: .color(backgroundColor))

            // capture size (allowed)
            if lastSize != size {
                DispatchQueue.main.async { lastSize = size }
            }

            // draw network on top
            draw(context: &context)
        }
        .onReceive(timer) { _ in
            guard lastSize != .zero else { return }
            updateNodes(in: lastSize)
        }
    }

    private func draw(context: inout GraphicsContext) {
        for i in 0..<nodes.count {
            for j in i+1..<nodes.count {
                let dist = distance(nodes[i].position, nodes[j].position)
                if dist < 150 {
                    var path = Path()
                    path.move(to: nodes[i].position)
                    path.addLine(to: nodes[j].position)

                    let opacity = 1.0 - (dist / 150)
                    context.stroke(path, with: .color(.blue.opacity(opacity * 0.3)), lineWidth: 0.5)
                }
            }
        }

        for node in nodes {
            let rect = CGRect(x: node.position.x - 2, y: node.position.y - 2, width: 4, height: 4)
            context.fill(Path(ellipseIn: rect), with: .color(.blue.opacity(0.5)))
        }
    }

    private func updateNodes(in size: CGSize) {
        for i in 0..<nodes.count {
            nodes[i].position.x += nodes[i].velocity.x
            nodes[i].position.y += nodes[i].velocity.y

            if nodes[i].position.x <= 0 || nodes[i].position.x >= size.width { nodes[i].velocity.x *= -1 }
            if nodes[i].position.y <= 0 || nodes[i].position.y >= size.height { nodes[i].velocity.y *= -1 }
        }
    }

    private func distance(_ p1: CGPoint, _ p2: CGPoint) -> CGFloat {
        sqrt(pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2))
    }
}
