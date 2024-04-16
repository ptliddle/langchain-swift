//
//  Anthropic.swift
//
//
//  Created by Peter Liddle on 4/16/24.
//

import Foundation
import SwiftAnthropic


enum AnthropicError: Error {
    case noApiKey
}

public class Anthropic: LLM {
   
    let temperature: Double
    let model: SwiftAnthropic.Model
    let maxTokensToSample = 1024
    
    let apiKey: String?
//    let baseUrl: String This is in the SDK for Anthropic, might want to be able to override later
    
    var systemPrompt: String? = nil
    
    public init(apiKey: String? = nil, baseUrl: String? = nil, temperature: Double = 0.0, model: SwiftAnthropic.Model = .claude21, callbacks: [BaseCallbackHandler] = [], cache: BaseCache? = nil, systemPrompt: String? = nil) {
        self.temperature = temperature
        self.model = model
        
        self.apiKey = apiKey ?? {
            let env = Env.loadEnv()
            return env["ANTHROPIC_API_KEY"]
        }()

        self.systemPrompt = systemPrompt
        
//        self.baseUrl = baseUrl ?? {
//            let env = Env.loadEnv()
//            return env["ANTHROPIC_API_BASE"] ?? "api.anthropic.com"
//        }()
        
        super.init(callbacks: callbacks, cache: cache)
    }
    
    public override func _send(text: String, stops: [String] = []) async throws -> LLMResult {
        
        guard let apiKey = apiKey else {
            print("Please set anthropic api key.")
            throw AnthropicError.noApiKey
        }
        
        let anthropicClient = AnthropicServiceFactory.service(apiKey: apiKey)
        
        let messageParameter = MessageParameter.Message(role: MessageParameter.Message.Role.user, content: .text(text) )
        
        let parameters = MessageParameter(model: model, messages: [messageParameter], maxTokens: maxTokensToSample, system: systemPrompt)

        do {
            
            let response = try await anthropicClient.createMessage(parameters, beta: nil)
            
            let usage = Usage(promptTokens: response.usage.inputTokens, completionTokens: response.usage.outputTokens, totalTokens: response.usage.inputTokens + response.usage.outputTokens)
            
            switch response.content.first {
            case let .text(text):
                return LLMResult(llm_output: text, usage: usage)
            case .toolUse:
                let msg = "Tool use currently not supported"
                print(msg)
                return LLMResult(llm_output: msg, usage: usage)
            case .none:
                return LLMResult(llm_output: "No response", usage: usage)
            }
        }
        catch let error as SwiftAnthropic.APIError {
            // Convert to LLMChainError
            throw LLMChainError.remote(error.displayDescription)
        }
        catch {
            throw error
        }
    }
}
