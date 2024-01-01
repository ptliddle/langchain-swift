//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/21.
//

import Foundation

public struct MRKLOutputParser: BaseOutputParser {
    
    public init() {}
    
    public func parse(text: String) -> Parsed {
        print(text.uppercased())
        if text.uppercased().contains(FINAL_ANSWER_ACTION) {
            return Parsed.finish(AgentFinish(final: text))
        }

        // Adjusted pattern to capture multi-line JSON after "Action Input"
        let pattern = "Action\\s*:\\s*(.*?)\\s*Action Input\\s*:\\s*(.*)"
        let regex = try! NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators])

        if let match = regex.firstMatch(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count)) {
            let firstCaptureGroup = Range(match.range(at: 1), in: text).map { String(text[$0]) }
            let secondCaptureGroup = Range(match.range(at: 2), in: text).map { String(text[$0]) }

            return Parsed.action(AgentAction(action: firstCaptureGroup!, input: secondCaptureGroup!, log: text))
        } else {
            return Parsed.error
        }
    }
}
