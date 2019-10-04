//
//  Vertex.swift
//  ReactiveMetal
//
//  Created by s.kananat on 2018/12/05.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import MetalKit

// MARK: Main
/// A protocol for vertex struct
public protocol Vertex {
    
    /// Initializes
    init()
    
    /// Corresponding vertex shader function name
    static var functionName: String { get }
}

// MARK: Public
public extension Vertex {
    
    /// Makes descriptor for the vertex
    static var descriptor: MTLVertexDescriptor {
        let descriptor = MTLVertexDescriptor()
        
        var offset = 0
        
        let mirror = Mirror(reflecting: Self())
        
        for (index, element) in mirror.children.enumerated() {
            let (_, value) = element
            
            var format: MTLVertexFormat = .invalid
            
            var stride = 0
            switch value {
            
            case is SIMD2<Float>:     format = .float2;       stride = MemoryLayout<SIMD2<Float>>.stride
            case is SIMD3<Float>:     format = .float3;       stride = MemoryLayout<SIMD3<Float>>.stride
            case is SIMD4<Float>:     format = .float4;       stride = MemoryLayout<SIMD4<Float>>.stride
            default:            break
            }
            
            guard format != .invalid else { fatalError("Unsupported type found: \(type(of: value))") }
            
            descriptor.attributes[index].format = format
            descriptor.attributes[index].offset = offset
            descriptor.attributes[index].bufferIndex = 0
            
            offset += stride
        }
        
        descriptor.layouts[0].stride = MemoryLayout<Self>.stride
        
        return descriptor
    }
}
