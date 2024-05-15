//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/11/4.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public class BaseCombineDocumentsChain: DefaultChain {
    public func predict(args: [String: String] ) async throws -> String? {
        let output = try await self.combine_docs(docs: args["docs"]!, question: args["question"]!)
        return output
    }
    
    public func combine_docs(docs: String, question: String) async throws -> String? {
        ""
    }
}
