//
//  DefaultChainTests.swift
//  
//
//  Created by Peter Liddle on 2/10/24.
//

import XCTest
@testable import LangChain

class MockMemory: BaseMemory {
    
    public var memoryDataForTesting = [String: [String]]()
    func load_memory_variables(inputs: [String: Any]) -> [String: [String]] {
        return memoryDataForTesting
    }
    
    public var saveContextCalled = false
    public var saveContextInputs = [String: String]()
    public var saveContextOutputs = [String: String]()
    func save_context(inputs: [String: String], outputs: [String: String]) {
        saveContextCalled = true
        saveContextInputs = inputs
        saveContextOutputs = outputs
    }
    
    var clearCalled = false
    func clear() {
        clearCalled = true
    }
}

final class DefaultChainTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testPrepOutputs_withMemoryNil() {
        
        let objectUnderTest = DefaultChain(memory: nil, outputKey: "output", inputKey: "input")

            let inputs = ["key1": "value1", "key2": "value2"]
            let outputs = ["key2": "newvalue2", "key3": "value3"]

            let result = objectUnderTest.prep_outputs(inputs: inputs, outputs: outputs)

            let expected = ["key1": "value1", "key2": "newvalue2", "key3": "value3"]
            XCTAssertEqual(result, expected, "Result should merge inputs and outputs with outputs overriding")
        }

        func testPrepOutputs_withMemoryNotNil() {
            let mockMemory = MockMemory()
            let objectUnderTest = DefaultChain(memory: mockMemory, outputKey: "output", inputKey: "input")


            // You will have to mock or create an instance of the memory object and set it here
            let inputs = ["key1": "value1", "key2": "value2"]
            let outputs = ["key2": "newvalue2", "key3": "value3"]

            _ = objectUnderTest.prep_outputs(inputs: inputs, outputs: outputs)
            

            // Verify that the memory's save_context method was called with the correct parameters
            // This depends on how you implement or mock the memory object
            
            XCTAssertTrue(mockMemory.saveContextCalled)
            XCTAssertEqual(mockMemory.saveContextInputs, inputs)
            XCTAssertEqual(mockMemory.saveContextOutputs, outputs)
        }
    
    func testPrepInputs_WithMemoryNil() {
        let objectUnderTest = DefaultChain(memory: nil, outputKey: "output", inputKey: "input")


        let inputs = ["key1": "value1", "key2": "value2"]

        let result = objectUnderTest.prep_inputs(inputs: inputs)

        XCTAssertEqual(result, inputs, "Result should be the same as inputs when memory is nil")
    }

    func testPrepInputs_WithMemoryNotNil() {
        let mockMemory = MockMemory()
        let objectUnderTest = DefaultChain(memory: mockMemory, outputKey: "output", inputKey: "input")


        let inputs = ["key1": "value1", "key2": "value2"]
        // Assuming the memory object returns something like this
        let memoryData = ["key1": ["oldValue1"], "key3": ["value3"], "key4": ["valueA", "valueB"]]

        // Mock the memory to return memoryData when load_memory_variables is called
        mockMemory.memoryDataForTesting = memoryData

        let result = objectUnderTest.prep_inputs(inputs: inputs)

        // The expected result should have the inputs and the memory data merged
        let expected = ["key1": "value1", "key2": "value2", "key3": "value3", "key4": "valueA\nvalueB"]
        XCTAssertEqual(result, expected, "Result should merge inputs and memory data with memory data values joined by newline")
    }

}
