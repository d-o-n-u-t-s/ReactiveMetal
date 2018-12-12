//
//  NoFilter.swift
//  MetalTest
//
//  Created by s.kananat on 2018/12/12.
//  Copyright © 2018 s.kananat. All rights reserved.
//

/// Filter that passes the input to the output
public final class NoFilter: Filter {
    
    public convenience init() {
        self.init(fragmentFunctionName: "fragment_nofilter")
    }
}
