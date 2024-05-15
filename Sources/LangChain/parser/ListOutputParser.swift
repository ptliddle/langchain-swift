//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/8/4.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
public struct ListOutputParser: BaseOutputParser {
    public func parse(text: String) -> Parsed {
        Parsed.list(text.components(separatedBy: ","))
    }
    
    
}
