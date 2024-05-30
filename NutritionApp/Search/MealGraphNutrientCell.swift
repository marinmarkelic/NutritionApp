import SwiftUI

struct MealGraphNutrientCell: View {

    let nutrient: Nutrient
    let value: Float

    private let spacing: CGFloat = 4

    @State private var dimensions: NutrientCellDimensions = .empty

    var body: some View {
        HStack {
            Circle()
                .size(with: 12)
                .foregroundStyle(nutrient.color)
                .frame(alignment: .leading)

            ZStack {
                ZStack {
                    titleText
                        .onSizeChange { size in
                            dimensions = dimensions.update(titleSize: size)
                        }

                    valueText
                        .onSizeChange { size in
                            dimensions = dimensions.update(valueSize: size)
                        }
                }
                .hidden()

                if dimensions.layout == .vertical {
                    verticalLayout
                } else {
                    horizontalLayout
                }
            }
            .shiftLeft()
            .onSizeChange { size in
                dimensions = dimensions.update(containerSize: size)
            }
        }
    }

    private var horizontalLayout: some View {
        HStack {
            titleText

            valueText
        }
    }

    private var verticalLayout: some View {
        VStack(alignment: .leading) {
            titleText

            valueText
        }
    }

    private var titleText: some View {
        Text(nutrient.title)
            .color(emphasis: .medium)
            .bold()
    }

    private var valueText: some View {
        Text(text(for: value, unit: nutrient.unit))
            .color(emphasis: .medium)
    }

    private func text(for value: Float, unit: MeasuringUnit) -> String {
        switch unit {
        case .grams:
            guard value < 1 else { return String(format: "%.1f \(MeasuringUnit.grams.shortened)", value) }

            return "\((value * 1000).toInt()) \(MeasuringUnit.milligrams.shortened)"
        case .milligrams:
            guard value >= 1000 else { return "\(value.toInt()) \(nutrient.unit.shortened)" }

            return String(format: "%.1f \(MeasuringUnit.grams.shortened)", value / 1000)
        }
    }

}

private struct NutrientCellDimensions: Equatable {

    enum Layout {

        case vertical
        case horizontal

    }

    let containerSize: CGSize?
    let titleSize: CGSize?
    let valueSize: CGSize?

    static let empty = NutrientCellDimensions(containerSize: nil, titleSize: nil, valueSize: nil)

    private let spacingTolerance: CGFloat = 16

    var layout: Layout {
        guard
            let containerSize,
            let titleSize,
            let valueSize
        else { return .horizontal }

        let canFitHorizontally = containerSize.width > titleSize.width + valueSize.width + spacingTolerance
        return canFitHorizontally ? .horizontal : .vertical
    }

    func update(containerSize: CGSize) -> NutrientCellDimensions {
        NutrientCellDimensions(containerSize: containerSize, titleSize: titleSize, valueSize: valueSize)
    }

    func update(titleSize: CGSize) -> NutrientCellDimensions {
        NutrientCellDimensions(containerSize: containerSize, titleSize: titleSize, valueSize: valueSize)
    }

    func update(valueSize: CGSize) -> NutrientCellDimensions {
        NutrientCellDimensions(containerSize: containerSize, titleSize: titleSize, valueSize: valueSize)
    }

}
