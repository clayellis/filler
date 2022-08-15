//
//  DimensionPicker.swift
//  Filler
//
//  Created by Clay Ellis on 7/26/22.
//

import SwiftUI

struct DimensionPicker: View {
    @Binding var width: Int
    @Binding var height: Int
    var bounds: ClosedRange<Int> = 5...100

    var body: some View {
        GroupBox {
            VStack {
                HStack {
                    Text("Width:")
                    TextField("Width", value: $width, format: .number)
                    Stepper("Width", value: $width, in: bounds)
                }

                HStack {
                    Text("Height:")
                    TextField("Height", value: $height, format: .number)
                    Stepper("Height", value: $height, in: bounds)
                }
            }
            .textFieldStyle(.roundedBorder)
            .keyboardType(.decimalPad)
            .multilineTextAlignment(.trailing)
            .labelsHidden()
        }
        .padding()
        .onChange(of: width) { _ in
            bounds.clamp(&width)
        }
        .onChange(of: height) { _ in
            bounds.clamp(&height)
        }
    }
}

extension ClosedRange {
    func clamp(_ input: inout Bound) where Bound: Comparable {
        if input < lowerBound {
            input = lowerBound
        } else if input > upperBound {
            input = upperBound
        }
    }
}

struct DimensionPicker_Previews: PreviewProvider {
    struct Preview: View {
        @State var width: Int
        @State var height: Int

        var body: some View {
            DimensionPicker(width: $width, height: $height)
        }
    }

    static var previews: some View {
        Preview(width: 10, height: 10)
    }
}
