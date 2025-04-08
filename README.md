# MCP Swift Example Server

## Basic Stdio Example

This is a basic example demonstrating how to create a simple server that communicates over standard input/output (stdio) using the Model Context Protocol Swift SDK. This setup is compatible with applications like Claude Desktop.

## Features

This simple server demonstrates:
* Setting up a basic MCP server
* Defining and registering a custom tool (`swift_echo`)
* Handling `ListTools` and `CallTool` requests
* Using `StdioTransport` for communication
* Detailed logging to stderr

## Getting Started

### Running the Echo Server

1. Clone this repository:
```bash
git clone https://github.com/devyhan/mcp-swift-example-server.git
cd mcp-swift-example-server
```

2. Build the server:
```bash
swift build -c release
```

This will create the executable at `.build/release/macros-mcp-example-server`. Note the full path to this executable.

### Configure Claude Desktop

To make this server available as a tool provider in Claude Desktop, you need to add it to your Claude Desktop configuration file (`claude_desktop_config.json`). The location of this file varies by operating system.

Add an entry like the following to the `mcpServers` object in your `claude_desktop_config.json`, replacing `/PATH/TO/YOUR/SERVER/` with the actual absolute path to the repository directory on your system:

```json
{
    "mcpServers": {
        // ... other servers maybe ...
        "swift_echo_example": {
            "command": "/PATH/TO/YOUR/SERVER/mcp-swift-example-server/.build/release/macros-mcp-example-server"
        }
        // ... other servers maybe ...
    }
}
```

* `swift_echo_example`: This is the name you'll refer to the server by within Claude Desktop (you can change this).
* `command`: This **must** be the absolute path to the compiled executable you built in the previous step.

## Client Example

The `Examples` directory contains a simple client implementation that demonstrates how to communicate with the MCP server:

```bash
# First start the server in one terminal:
swift run

# Then in another terminal, run the client example:
cd Examples
swift SimpleClient.swift
```

## Requirements

- macOS 13 or later
- Swift 5.9 or later

## Project Structure

- `main.swift`: Entry point for the server application
- `MCPServer`: MCP protocol server implementation
- `EchoToolbox`: Toolbox providing the basic echo tool

## License

MIT

## References

- [MCP Specification](https://spec.modelcontextprotocol.io/)
- [Swift MCP SDK GitHub](https://github.com/modelcontextprotocol/swift-sdk)
