//
//  CameraViewModel.swift
//  Vision Classifier Live
//
//  Created by Daniel Zimmerman on 9/29/25.
//

import Foundation
import CoreGraphics
import Combine

final class CameraViewModel: ObservableObject {
    @Published var detections: [DetectionModel] = [
        DetectionModel(label: "keyboard", score: 0.92, normalizedBounds: CGRect(origin: CGPoint(x: 0.35, y: 0.35), size: CGSize(width: 0.30, height: 0.20))),
        DetectionModel(label: "mouse", score: 0.81, normalizedBounds: CGRect(origin: CGPoint(x: 0.08, y: 0.10), size: CGSize(width: 0.22, height: 0.18)))
    ]
}
