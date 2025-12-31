import SwiftUI
import SwiftData

struct MindMapCanvasView: View {
    let nodes: [MindMapNode]
    @Binding var selectedNode: MindMapNode?
    @Binding var offset: CGSize
    @Binding var scale: CGFloat

    @State private var dragOffset: CGSize = .zero
    @State private var nodeDragOffsets: [UUID: CGSize] = [:]
    @GestureState private var magnificationState: CGFloat = 1.0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Connection lines
                ForEach(nodes, id: \.id) { node in
                    ForEach(node.children, id: \.id) { child in
                        ConnectionLine(
                            from: node.position,
                            to: child.position,
                            offset: totalOffset,
                            scale: totalScale
                        )
                        .stroke(Color.secondary, lineWidth: 2 / totalScale)
                    }
                }

                // Nodes - Equatable로 최적화됨
                ForEach(nodes, id: \.id) { node in
                    let nodeDragOffset = nodeDragOffsets[node.id] ?? .zero
                    let centerX = geometry.size.width / 2
                    let centerY = geometry.size.height / 2

                    NodeView(
                        node: node,
                        isSelected: selectedNode?.id == node.id,
                        scale: totalScale
                    )
                    .equatable()
                    .position(
                        x: (node.position.x + nodeDragOffset.width) * totalScale + totalOffset.width + centerX,
                        y: (node.position.y + nodeDragOffset.height) * totalScale + totalOffset.height + centerY
                    )
                    .simultaneousGesture(
                        // 탭 제스처 - 즉시 반응
                        TapGesture()
                            .onEnded { _ in
                                if selectedNode?.id != node.id {
                                    selectedNode = node
                                }
                            }
                    )
                    .simultaneousGesture(
                        // 드래그 제스처 - 동시에 감지
                        DragGesture(minimumDistance: 3)
                            .onChanged { value in
                                nodeDragOffsets[node.id] = CGSize(
                                    width: value.translation.width / totalScale,
                                    height: value.translation.height / totalScale
                                )
                                if selectedNode?.id != node.id {
                                    selectedNode = node
                                }
                            }
                            .onEnded { value in
                                let finalOffset = CGSize(
                                    width: value.translation.width / totalScale,
                                    height: value.translation.height / totalScale
                                )
                                // 실제로 이동했을 때만 위치 업데이트
                                if abs(finalOffset.width) > 0.1 || abs(finalOffset.height) > 0.1 {
                                    node.position = CGPoint(
                                        x: node.position.x + finalOffset.width,
                                        y: node.position.y + finalOffset.height
                                    )
                                }
                                nodeDragOffsets.removeValue(forKey: node.id)
                            }
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation
                    }
                    .onEnded { _ in
                        offset.width += dragOffset.width
                        offset.height += dragOffset.height
                        dragOffset = .zero
                    }
            )
            .gesture(
                MagnificationGesture()
                    .updating($magnificationState) { value, state, _ in
                        state = value
                    }
                    .onEnded { value in
                        scale *= value
                        scale = min(max(scale, 0.3), 3.0)
                    }
            )
        }
    }

    private var totalOffset: CGSize {
        CGSize(
            width: offset.width + dragOffset.width,
            height: offset.height + dragOffset.height
        )
    }

    private var totalScale: CGFloat {
        scale * magnificationState
    }
}

struct ConnectionLine: Shape {
    let from: CGPoint
    let to: CGPoint
    let offset: CGSize
    let scale: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let startPoint = CGPoint(
            x: from.x * scale + offset.width + rect.width / 2,
            y: from.y * scale + offset.height + rect.height / 2
        )

        let endPoint = CGPoint(
            x: to.x * scale + offset.width + rect.width / 2,
            y: to.y * scale + offset.height + rect.height / 2
        )

        // Bezier curve for smooth connection
        let controlPoint1 = CGPoint(
            x: startPoint.x,
            y: startPoint.y + (endPoint.y - startPoint.y) / 3
        )

        let controlPoint2 = CGPoint(
            x: endPoint.x,
            y: endPoint.y - (endPoint.y - startPoint.y) / 3
        )

        path.move(to: startPoint)
        path.addCurve(to: endPoint, control1: controlPoint1, control2: controlPoint2)

        return path
    }
}
