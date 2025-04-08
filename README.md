# MCP Swift Example Server

This project demonstrates a simple implementation of the [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) using Swift. It provides a basic echo functionality to clients.

## Features

- `swift_echo`: A simple tool that echoes back the input message
- Communication based on MCP protocol
- Extensible tool implementation using the toolbox pattern

## Requirements

- macOS 13 or later
- Swift 5.9 or later

## Installation and Running

```bash
# Clone the repository
git clone https://github.com/devyhan/mcp-swift-example-server.git
cd mcp-swift-example-server

# Build and run
swift build
swift run
```

## Usage

This server can communicate with any MCP client. Example:

```swift
// Client-side code example
let client = Client(name: "TestClient", version: "1.0")
try await client.connect(transport: StdioTransport())
try await client.initialize()

let tools = try await client.listTools()
// "swift_echo" tool will be available in the tools list

// Call the echo tool
let result = try await client.callTool(name: "swift_echo", arguments: ["message": "Hello, MCP!"])
// The result will contain "Hello, MCP!"
```

## Project Structure

- `main.swift`: Entry point for the server application
- `MCPServer`: MCP protocol server implementation
- `EchoToolbox`: Toolbox providing the basic echo tool

## License

MIT

## References

- [MCP Specification](https://spec.modelcontextprotocol.io/)
- [Swift MCP SDK GitHub](https://github.com/modelcontextprotocol/swift-sdk)
