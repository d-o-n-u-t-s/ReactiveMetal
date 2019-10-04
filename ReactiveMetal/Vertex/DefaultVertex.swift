//
//  DefaultVertex.swift
//  ReactiveMetal
//
//  Created by s.kananat on 2018/12/05.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import simd

// MARK: Main
/// Vertex for mapping texture coordinates to render quad
public struct DefaultVertex {
    
    /// Position
    private(set) public var position: SIMD4<Float>
    
    /// Texture coordinates
    private(set) public var texcoord: SIMD2<Float>
    
    /// Initializes with positions and texture coordinates
    public init(position: SIMD4<Float>, texcoord: SIMD2<Float>) {
        self.position = position
        self.texcoord = texcoord
    }
}

// MARK: Protocol
extension DefaultVertex: Vertex {

    public init() { self.init(position: SIMD4<Float>(), texcoord: SIMD2<Float>()) }
    
    public static let functionName = "vertex_default"
}

// MARK: Public
public extension DefaultVertex {
    
    /// All coordinate vertices
    static let vertices: [DefaultVertex] = [.topLeft, .bottomLeft, .bottomRight, .topRight]
}

// MARK: Private
private extension DefaultVertex {
    
    /// Bottom left coordinate
    static let bottomLeft = DefaultVertex(position: SIMD4<Float>(-1, 1, 0, 1), texcoord: SIMD2<Float>(0, 0))
    
    /// Top left coordinate
    static let topLeft = DefaultVertex(position: SIMD4<Float>(-1, -1, 0, 1), texcoord: SIMD2<Float>(0, 1))
    
    /// Top right coordinate
    static let topRight = DefaultVertex(position: SIMD4<Float>(1, -1, 0, 1), texcoord: SIMD2<Float>(1, 1))

    /// Bottom right coordinate
    static let bottomRight =
        DefaultVertex(position: SIMD4<Float>(1, 1, 0, 1), texcoord: SIMD2<Float>(1, 0))
}
