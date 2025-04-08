# Development Guide

This document provides information for developers who want to extend or modify this MCP server example.

## Prerequisites

- macOS 13 or later
- Swift 5.9 or later
- Xcode 15 or later (optional for development)

## Project Structure

- `Package.swift` - Swift Package Manager configuration
- `Sources/macros-mcp-example-server/main.swift` - Main server implementation
- `Examples/SimpleClient.swift` - Sample client implementation

## Building and Running

### Build the server

```bash
swift build
```

### Run the server

```bash
swift run
```

### Debug with Xcode

Generate Xcode project:

```bash
swift package generate-xcodeproj
```

Open the generated project and run/debug from Xcode.

## Adding New Tools

To add a new tool to the server:

1. Extend the `EchoToolbox` class or create a new toolbox implementation 
2. Add your tool definition in the `getMCPTools()` method
3. Add a handler method for your tool (e.g., `handle_my_new_tool_call()`)
4. Update the `CallTool` handler in the `MCPServer` class to recognize and dispatch to your new tool

Example for adding a "calculator" tool:

```swift
// Add to EchoToolbox
func getMCPTools() -> [Tool] {
    return [
        // Existing echo tool
        Tool(
            name: "swift_echo",
            description: "A simple tool that echoes back its input arguments.",
            inputSchema: .object([
                "message": .object([
                    "type": "string",
                    "description": "The text to echo back"
                ])
            ])
        ),
        
        // New calculator tool
        Tool(
            name: "calculator",
            description: "Performs basic arithmetic operations.",
            inputSchema: .object([
                "a": .object(["type": "number", "description": "First number"]),
                "b": .object(["type": "number", "description": "Second number"]),
                "operation": .object([
                    "type": "string", 
                    "description": "Operation to perform (add, subtract, multiply, divide)"
                ])
            ])
        )
    ]
}

// Add handler for calculator tool
func handle_calculator_call(arguments: [String: Value]?) throws -> [Tool.Content] {
    guard let arguments = arguments,
          let aValue = arguments["a"],
          let bValue = arguments["b"],
          let operationValue = arguments["operation"],
          let a = Double(aValue),
          let b = Double(bValue),
          let operation = String(operationValue) else {
        return [.text("Missing or invalid parameters")]
    }
    
    var result: Double
    switch operation {
    case "add":
        result = a + b
    case "subtract":
        result = a - b
    case "multiply":
        result = a * b
    case "divide":
        guard b != 0 else {
            return [.text("Division by zero error")]
        }
        result = a / b
    default:
        return [.text("Unknown operation: \(operation)")]
    }
    
    return [.text("Result: \(result)")]
}
```

Then update the `CallTool` handler to use your new tool:

```swift
if params.name == "swift_echo" {
    let content = try toolbox.handle_swift_echo_call(arguments: params.arguments)
    return CallTool.Result(content: content)
} else if params.name == "calculator" {
    let content = try toolbox.handle_calculator_call(arguments: params.arguments)
    return CallTool.Result(content: content)
}
```

## Testing

To test your server implementation:

1. Run the server in one terminal:
   ```
   swift run
   ```

2. Build and run the sample client in another terminal:
   ```
   cd Examples
   swift SimpleClient.swift
   ```

## MCP Protocol Reference

For more information about the Model Context Protocol:

- [MCP Specification](https://spec.modelcontextprotocol.io/)
- [Swift MCP SDK GitHub](https://github.com/modelcontextprotocol/swift-sdk)
