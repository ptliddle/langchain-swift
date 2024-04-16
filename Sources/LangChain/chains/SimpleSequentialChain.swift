//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/9/6.
//

import Foundation

public class SimpleSequentialChain: DefaultChain {
    let chains: [DefaultChain]
    public init(chains: [DefaultChain], memory: BaseMemory? = nil, outputKey: String = "output", inputKey: String = "input", callbacks: [BaseCallbackHandler] = []) {
        self.chains = chains
        super.init(memory: memory, outputKey: outputKey, inputKey: inputKey, callbacks: callbacks)
    }
    
    public override func _call(args: String) async throws -> (LLMResult?, Parsed) {
        var result: LLMResult? = LLMResult(llm_output: args)
        for chain in self.chains {
            if result != nil {
                do {
                    result = try await chain._call(args: result!.llm_output!).0
                }
                catch {
                    // Assume a failure here will corrupt the chain so hand error back don't keep going
                    print("Chain element failed with error \(error)")
                    throw error
                }
            } else {
                print("A chain of SimpleSequentialChain fail")
            }
        }
        return (result, Parsed.nothing)
    }
}
