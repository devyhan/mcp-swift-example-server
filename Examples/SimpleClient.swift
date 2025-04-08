import Foundation
import MCP

// A simple MCP client example
@main
struct SimpleClient {
    static func main() async {
        print("Starting MCP client...")
        
        do {
            // Create client
            let client = Client(name: "TestClient", version: "1.0")
            
            // Connect to server using stdio transport
            let transport = StdioTransport()
            try await client.connect(transport: transport)
            
            // Initialize the connection
            let initResult = try await client.initialize()
            print("Connected to server: \(initResult.serverInfo.name) \(initResult.serverInfo.version)")
            
            // List available tools
            let tools = try await client.listTools()
            print("Available tools:")
            for tool in tools {
                print("- \(tool.name): \(tool.description)")
            }
            
            // Call the echo tool
            let message = "Hello, Model Context Protocol!"
            print("\nCalling swift_echo with message: \"\(message)\"")
            
            let result = try await client.callTool(
                name: "swift_echo", 
                arguments: ["message": .string(message)]
            )
            
            // Process the response
            if let content = result.content.first, case .text(let response) = content {
                print("Response: \"\(response)\"")
            } else {
                print("Unexpected response format")
            }
            
            // Disconnect
            await client.disconnect()
            print("Client disconnected")
            
        } catch {
            print("Error: \(error)")
            exit(1)
        }
    }
}
