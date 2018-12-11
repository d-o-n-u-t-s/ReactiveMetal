//
//  MTLImageSource.swift
//  MetalTest
//
//  Created by s.kananat on 2018/12/06.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import MetalKit

/// Protocol for image source using metal enabled device
protocol MTLImageSource: ImageSource where Data == MTLTexture { }
