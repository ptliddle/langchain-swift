//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/8/31.
//

import Foundation
import NIOPosix
import AsyncHTTPClient
import OpenAIKit

enum OpenAIError: Error {
    case noApiKey
}

public class ChatOpenAI: OpenAI {
    
    let httpClient: HTTPClient
    
    public init(apiKey: String? = nil, baseUrl: String? = nil, httpClient: HTTPClient, temperature: Double = 0.0, model: ModelID = Model.GPT3.gpt3_5Turbo16K, callbacks: [BaseCallbackHandler] = [], cache: BaseCache? = nil) {
        self.httpClient = httpClient
        super.init(apiKey: apiKey, baseUrl: baseUrl, temperature: temperature, model: model, callbacks: callbacks, cache: cache)
    }
//
//    let apiKey: String?
//    let baseUrl: String
//    
//    
//    public init(apiKey: String? = nil, baseUrl: String? = nil, httpClient: HTTPClient, temperature: Double = 0.0, model: ModelID = Model.GPT3.gpt3_5Turbo16K, callbacks: [BaseCallbackHandler] = [], cache: BaseCache? = nil) {
//        self.httpClient = httpClient
//        self.temperature = temperature
//        self.model = model
//        
//        if let apiKey = apiKey, let baseUrl = baseUrl {
//            self.apiKey = apiKey
//            self.baseUrl = baseUrl
//        }
//        else {
//            let env = Env.loadEnv()
//            self.apiKey = env["OPENAI_API_KEY"]
//            self.baseUrl = env["OPENAI_API_BASE"] ?? "api.openai.com"
//        }
//        
//        super.init(callbacks: callbacks, cache: cache)
//    }
//    
//    internal func setUpChat(_ httpClient: HTTPClient) throws -> OpenAIKit.Client {
//        guard let apiKey = apiKey else {
//            print("Please set openai api key.")
//            throw OpenAIError.noApiKey
//        }
//        
//        let configuration = Configuration(apiKey: apiKey, api: API(scheme: .https, host: baseUrl))
//
//        let openAIClient = OpenAIKit.Client(httpClient: httpClient, configuration: configuration)
//        
//        return openAIClient
//    }
    
    public override func _send(text: String, stops: [String] = []) async throws -> LLMResult {

        let openAIClient = try initiateChat(httpClient)
        
        let buffer = try await openAIClient.chats.stream(model: model, messages: [.user(content: text)], temperature: temperature)
        return OpenAIResult(generation: buffer)
    }
}



