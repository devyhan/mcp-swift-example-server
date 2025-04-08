import MCP
import Foundation

// 도구 모음 정의
struct EchoToolbox {
    
    // 메타데이터
    static let toolboxName = "SwiftEcho"
    static let toolboxDescription = "Basic echo functionality"
    
    // 도구 생성 함수
    func getMCPTools() -> [Tool] {
        return [
            Tool(
                name: "swift_echo",
                description: "A simple tool that echoes back its input arguments.",
                inputSchema: .object([
                    "message": .object([
                        "type": "string",
                        "description": "The text to echo back"
                    ])
                ])
            )
        ]
    }
    
    // 도구 호출 처리 함수
    func handle_swift_echo_call(arguments: [String: Value]?) throws -> [Tool.Content] {
        guard let arguments = arguments,
              let messageValue = arguments["message"],
              let message = String(messageValue) else {
            return [.text("Missing or invalid 'message' parameter")]
        }
        
        return [.text(message)]
    }
}

// MCP 서버 구현
class MCPServer {
    private var server: Server
    private let toolboxes: [EchoToolbox]
    
    init(name: String, version: String, toolboxes: [EchoToolbox]) {
        self.toolboxes = toolboxes
        
        // 서버 생성
        self.server = Server(
            name: name,
            version: version,
            capabilities: .init(
                tools: .init(listChanged: false)
            )
        )
    }
    
    func start() async throws {
        // 모든 도구 수집
        var allTools: [Tool] = []
        for toolbox in toolboxes {
            allTools.append(contentsOf: toolbox.getMCPTools())
        }
        
        // ListTools 핸들러 등록
        await server.withMethodHandler(ListTools.self) { _ in
            return ListTools.Result(tools: allTools)
        }
        
        // CallTool 핸들러 등록
        await server.withMethodHandler(CallTool.self) { [weak self] params in
            guard let self = self else {
                throw Error.internalError("Server was deallocated")
            }
            
            // 도구 이름으로 처리할 툴박스 찾기
            for toolbox in self.toolboxes {
                let tools = toolbox.getMCPTools()
                if let tool = tools.first(where: { $0.name == params.name }) {
                    // 도구 찾음 - 실제 핸들러 처리
                    // 예시: EchoToolbox에서는 handle_swift_echo_call 메서드 호출
                    if params.name == "swift_echo" {
                        let content = try toolbox.handle_swift_echo_call(arguments: params.arguments)
                        return CallTool.Result(content: content)
                    }
                }
            }
            
            // 도구를 찾지 못함
            throw Error.methodNotFound("Tool not found: \(params.name)")
        }
        
        // 서버 시작
        let transport = StdioTransport()
        try await server.start(transport: transport)
    }
    
    func waitUntilCompleted() async {
        await server.waitUntilCompleted()
    }
    
    func stop() async {
        await server.stop()
    }
}

// 실제 서버 실행 코드
@main
struct MCPServerMain {
    static func main() async {
        fputs("log: main: starting (async).\n", stderr)
        
        do {
            // 도구 모음 생성
            let echoToolbox = EchoToolbox()
            
            // 서버 생성
            let server = MCPServer(
                name: "SwiftEchoServer",
                version: "1.0.0",
                toolboxes: [echoToolbox]
            )
            
            // 서버 시작
            try await server.start()
            fputs("log: main: server started successfully.\n", stderr)
            
            // 서버 완료 대기
            fputs("log: main: waiting for server completion...\n", stderr)
            await server.waitUntilCompleted()
            fputs("log: main: server has stopped.\n", stderr)
            
        } catch {
            fputs("error: main: server setup/run failed: \(error)\n", stderr)
            exit(1)
        }
        
        fputs("log: main: Server processing finished. Exiting.\n", stderr)
    }
}
