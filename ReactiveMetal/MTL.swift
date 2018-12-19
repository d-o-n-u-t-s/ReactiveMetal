//
//  MTL.swift
//  ReactiveMetal
//
//  Created by s.kananat on 2018/12/05.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import AVFoundation

#if arch(i386) || arch(x86_64)
#else
import MetalKit
#endif

// MARK: Main
/// Shared Metal resources
public class MTL {
    
    /// Metal enabled device
    public let device: MTLDevice
    
    /// Command queue of metal enabled device
    public let commandQueue: MTLCommandQueue
    
    /// Preferred texture size
    public var preferredTextureSize = (width: 720, height: 1080)
    
    /// Cached internal library
    private let internalLibrary: MTLLibrary
    
    /// Cached external library
    private let externalLibrary: MTLLibrary

    /// Initializes
    private init?() {
        guard let device = MTLCreateSystemDefaultDevice(),
            let commandQueue = device.makeCommandQueue()
            else { return nil }
        
        self.device = device
        self.commandQueue = commandQueue
        
        let bundle = Bundle(for: MTL.self)
        guard let path = bundle.path(forResource: "default", ofType: "metallib"),
            let library = try? device.makeLibrary(filepath: path)
            else { return nil }
        
        self.internalLibrary = library
        self.externalLibrary = device.makeDefaultLibrary()!
    }
}

// MARK: Public
public extension MTL {
    
    /// Shared instance
    static let `default`: MTL! = MTL()
    
    // TODO: fix
    /// Get function. Internal library takes priority.
    func function(name: String) -> MTLFunction? {
        if let function = self.internalLibrary.makeFunction(name: name)
        { return function }
        
        return self.externalLibrary.makeFunction(name: name)
    }
    
    /// Makes pipeline state
    func makePipelineState(fragmentFunctionName: String = "fragment_basic") -> MTLRenderPipelineState? {
        return self.makePipelineState(vertex: BasicVertex.self, fragmentFunctionName: fragmentFunctionName)
    }
    
    /// Makes pipeline state with specified vertex type
    func makePipelineState<V: Vertex>(vertex: V.Type, fragmentFunctionName: String = "fragment_basic") -> MTLRenderPipelineState? {

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        // Vertex function
        guard let vertexFunction = self.function(name: V.functionName) else {
            fatalError("vertexFunction `\(V.functionName)` not found.") }
        
        pipelineDescriptor.vertexFunction = vertexFunction
        
        // Fragment function
        guard let fragmentFunction = self.function(name: fragmentFunctionName)  else { fatalError("fragmentFunction `\(fragmentFunctionName)` not found.") }
            
        pipelineDescriptor.fragmentFunction = fragmentFunction
        
        // Vertex descriptor
        pipelineDescriptor.vertexDescriptor = V.descriptor
        
        return try? self.device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
   
    #if arch(i386) || arch(x86_64)
    #else
    /// Makes texture cache
    func makeTextureCache() -> CVMetalTextureCache? {
        var textureCache: CVMetalTextureCache?
        
        guard CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, self.device, nil, &textureCache) == kCVReturnSuccess else { return nil }
        
        return textureCache
    }

    /// Makes `MTLTexture` from `CMSampleBuffer`
    func makeTexture(from buffer: CMSampleBuffer, format: MTLPixelFormat = .bgra8Unorm, textureCache: CVMetalTextureCache) -> MTLTexture? {
        
        guard let imageBuffer = CMSampleBufferGetImageBuffer(buffer) else { return nil }
        
        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)

        var metalTexture: CVMetalTexture?
        
        guard CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache, imageBuffer, nil, format, width, height, 0, &metalTexture) == kCVReturnSuccess else { return nil }
        
        guard metalTexture != nil else { return nil }
        
        return CVMetalTextureGetTexture(metalTexture!)
    }
    #endif
    
    /// Makes empty `MTLTexture`
    func makeEmptyTexture(width: Int, height: Int) -> MTLTexture? {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm, width: width, height: height, mipmapped: false)
        descriptor.usage = [.renderTarget, .shaderRead]
        
        return self.device.makeTexture(descriptor: descriptor)
    }
    
    /// Makes empty `MTLTexture` with the preferred texture size
    func makeEmptyTexture() -> MTLTexture? {
        return self.makeEmptyTexture(width: self.preferredTextureSize.width, height: self.preferredTextureSize.height)
    }
    
    /// Makes `MTLBuffer` from `Array<T>`
    func makeBuffer<T>(from array: [T]) -> MTLBuffer? {
        guard array.count > 0 else { return nil }
        
        return self.device.makeBuffer(bytes: array, length: array.count * MemoryLayout<T>.stride)
    }
}
