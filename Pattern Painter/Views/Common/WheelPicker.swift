//
//  WheelPicker.swift
//  Pattern Painter
//
//  Created by Trevor Behlman on 8/27/25.
//

import SwiftUI

struct PickerItem<Value: Equatable> {
    let title: String
    let value: Value
}

struct WheelPicker<Value: Equatable>: UIViewRepresentable {
    @Binding var selection: Value
    let items: [PickerItem<Value>]

    class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate, UIGestureRecognizerDelegate {
        @Binding var selection: Value
        let items: [PickerItem<Value>]

        init(selection: Binding<Value>, items: [PickerItem<Value>]) {
            self._selection = selection
            self.items = items
        }

        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            1
        }

        func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing reusableView: UIView?) -> UIView {
            let view: UILabel
            if let reusableLabel = reusableView as? UILabel {
                view = reusableLabel
            } else {
                view = UILabel()
                view.textAlignment = .center
                view.font = UIFont.preferredFont(forTextStyle: .title3)
            }
            view.text = items[row].title
            updateSelection(in: pickerView)
            return view
        }

        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            items.count
        }

        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            selection = items[row].value
        }

        func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
            30
        }

        func updateSelection(in pickerView: UIPickerView) {
            let centerY = pickerView.frame.midY
            var closestDistance: CGFloat = .infinity
            var closestRow = -1
            for row in items.indices {
                if let view = pickerView.view(forRow: row, forComponent: 0), let rect = view.frame(in: pickerView) {
                    let distance = abs(rect.midY - centerY)
                    if distance > closestDistance {
                        break
                    }
                    closestDistance = distance
                    closestRow = row
                }
            }
            if items.indices.contains(closestRow) {
                selection = items[closestRow].value
            }
        }

        @objc func gesture(_ gestureRecognizer: UIGestureRecognizer) {
            guard gestureRecognizer.state == .changed, let pickerView = gestureRecognizer.view as? UIPickerView else { return }
            updateSelection(in: pickerView)
        }

        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            true
        }
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: Self.UIViewType, context: Self.Context) -> CGSize? {
        proposal.replacingUnspecifiedDimensions()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(selection: $selection, items: items)
    }

    func makeUIView(context: Context) -> UIPickerView {
        let view = UIPickerView()
        view.dataSource = context.coordinator
        view.delegate = context.coordinator
        let gesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.gesture(_:)))
        gesture.delegate = context.coordinator
        view.addGestureRecognizer(gesture)
        if let selectedRow = items.firstIndex(where: { $0.value == selection }) {
            view.selectRow(selectedRow, inComponent: 0, animated: false)
        }
        return view
    }

    func updateUIView(_ view: UIPickerView, context: Context) {}
}

#Preview {
    @Previewable @State var value = 5

    VStack {
        WheelPicker(selection: $value, items: (5...15).map {
            PickerItem(title: "\($0)", value: $0)
        })
        .frame(height: 150)
        Divider()
        Text(verbatim: "\(value)")
    }
}
