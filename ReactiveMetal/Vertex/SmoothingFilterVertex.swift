//
//  SmoothingFilterVertex.swift
//  ReactiveMetal
//
//  Created by s.kananat on 2018/12/20.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import simd

// MARK: Main
/// Unidirectional smoothing filter vertex
struct SmoothingFilterVertex {
    
    /// Position
    var position: SIMD4<Float>
    
    /// Texture coordinates
    var texcoord: SIMD2<Float>
    
    /// Texture size
    var size: SIMD2<Float>
}

// MARK: Protocol
extension SmoothingFilterVertex: Vertex {
    
    public init() { self.init(position: SIMD4<Float>(), texcoord: SIMD2<Float>(), size: SIMD2<Float>())}
    
    public static let functionName = "vertex_smoothing"
}

// MARK: Internal
internal extension SmoothingFilterVertex {
    
    static func vertices(for size: SIMD2<Float>) -> [SmoothingFilterVertex] {
        return [
            SmoothingFilterVertex(position: SIMD4<Float>(-1, 1, 0, 1), texcoord: SIMD2<Float>(0, 0), size: size),
            SmoothingFilterVertex(position: SIMD4<Float>(-1, -1, 0, 1), texcoord: SIMD2<Float>(0, 1), size: size),
            SmoothingFilterVertex(position: SIMD4<Float>(1, -1, 0, 1), texcoord: SIMD2<Float>(1, 1), size: size),
            SmoothingFilterVertex(position: SIMD4<Float>(1, 1, 0, 1), texcoord: SIMD2<Float>(1, 0), size: size)
        ]
    }
}
