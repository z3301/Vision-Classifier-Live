//
//  DetectionModel.swift
//  Vision Classifier Live
//
//  Created by Daniel Zimmerman on 9/29/25.
//

import Foundation
import CoreGraphics

struct DetectionModel: Identifiable {
    let id: UUID = UUID()
    let label: String
    let score: Double
    let normalizedBounds: CGRect
}


