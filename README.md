## Overview

WhatsApp Web MCP provides a seamless integration between WhatsApp Web and AI models by:

- Creating a standardized interface through the Model Context Protocol (MCP)
- Offering MCP Server access to WhatsApp functionality
- Providing flexible deployment options through SSE or Command modes
- Supporting both direct WhatsApp client integration and API-based connectivity

## Disclaimer

**IMPORTANT**: This tool is for testing purposes only and should not be used in production environments.

Disclaimer from WhatsApp Web project:

	@@ -24,23 +25,24 @@ Disclaimer from WhatsApp Web project:

To learn more about using WhatsApp Web MCP in real-world scenarios, check out these articles:

- [**Integrating WhatsApp with AI: Guide to Setting Up a WhatsApp MCP server**](https://medium.com/@pnizer/integrating-whatsapp-with-ai-a-complete-guide-to-setting-up-whatsapp-web-mcp-with-claude-and-f7a2180dca78)
- [**Integrating OpenAI Agents Python SDK with Anthropic's MCP**](https://medium.com/@pnizer/integrating-openai-agents-python-sdk-with-anthropics-mcp-229c686d9033)

## Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/pnizer/wweb-mcp.git
   cd wweb-mcp
   ```

2. Install globally or use with npx:

   ```bash
   # Install globally
   npm install -g .

   # Or use with npx directly
   npx .
   ```
	@@ -85,11 +87,13 @@ The API key is stored in the authentication data directory (specified by `--auth
### Authentication Methods

#### Local Authentication (Recommended)

- Scan QR code once
- Credentials persist between sessions
- More stable for long-term operation

#### No Authentication

- Default method
- Requires QR code scan on each startup
- Suitable for testing and development
	@@ -142,19 +146,25 @@ When a message is received and passes the filters, a POST request will be sent t
### Running Modes

#### WhatsApp API Server

Run a standalone WhatsApp API server that exposes WhatsApp functionality through REST endpoints:

```bash
npx wweb-mcp --mode whatsapp-api --api-port 3001
```

#### MCP Server (Standalone)

Run an MCP server that directly connects to WhatsApp Web:

```bash
npx wweb-mcp --mode mcp --mcp-mode standalone --transport sse --sse-port 3002
```

#### MCP Server (API Client)

Run an MCP server that connects to the WhatsApp API server:

```bash
# First, start the WhatsApp API server and note the API key from the logs
npx wweb-mcp --mode whatsapp-api --api-port 3001
	@@ -165,6 +175,7 @@ npx wweb-mcp --mode mcp --mcp-mode api --api-base-url http://localhost:3001/api

### Available Tools


| Tool | Description | Parameters |
|------|-------------|------------|
| `get_status` | Check WhatsApp client connection status | None |
	@@ -179,6 +190,7 @@ npx wweb-mcp --mode mcp --mcp-mode api --api-base-url http://localhost:3001/api
| `search_groups` | Search for groups by name, description, or member names | `query`: Search term to find groups |
| `get_group_by_id` | Get detailed information about a specific group | `groupId`: ID of the group to get |
| `download_media_from_message` | Download media from a message | `messageId`: ID of the message containing media to download |
| `send_media_message` | Send a media message to a WhatsApp contact | `number`: Phone number to send to<br>`source`: Media source with URI scheme (use `http://` or `https://` for URLs, `file://` for local files)<br>`caption` (optional): Text caption for the media |

### Available Resources

	@@ -194,6 +206,7 @@ npx wweb-mcp --mode mcp --mcp-mode api --api-base-url http://localhost:3001/api
### REST API Endpoints

#### Contacts & Messages

| Endpoint | Method | Description | Parameters |
|----------|--------|-------------|------------|
| `/api/status` | GET | Get WhatsApp connection status | None |
	@@ -202,9 +215,11 @@ npx wweb-mcp --mode mcp --mcp-mode api --api-base-url http://localhost:3001/api
| `/api/chats` | GET | Get all chats | None |
| `/api/messages/{number}` | GET | Get messages from a chat | `limit` (query): Number of messages |
| `/api/send` | POST | Send a message | `number`: Recipient<br>`message`: Message content |
| `/api/send/media` | POST | Send a media message | `number`: Recipient<br>`source`: Media source with URI scheme (use `http://` or `https://` for URLs, `file://` for local files)<br>`caption` (optional): Text caption |
| `/api/messages/{messageId}/media/download` | POST | Download media from a message | None |

#### Group Management

| Endpoint | Method | Description | Parameters |
|----------|--------|-------------|------------|
| `/api/groups` | GET | Get all groups | None |
	@@ -222,13 +237,15 @@ npx wweb-mcp --mode mcp --mcp-mode api --api-base-url http://localhost:3001/api
##### Option 1: Using NPX

1. Start WhatsApp API server:

   ```bash
   npx wweb-mcp -m whatsapp-api -s local
   ```

2. Scan the QR code with your WhatsApp mobile app

3. Note the API key displayed in the logs:

   ```
   WhatsApp API key: 1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef
   ```
	@@ -256,18 +273,21 @@ npx wweb-mcp --mode mcp --mcp-mode api --api-base-url http://localhost:3001/api
##### Option 2: Using Docker

1. Start WhatsApp API server in Docker:

   ```bash
   docker run -i -p 3001:3001 -v wweb-mcp:/wwebjs_auth --rm wweb-mcp:latest -m whatsapp-api -s local -a /wwebjs_auth
   ```

2. Scan the QR code with your WhatsApp mobile app

3. Note the API key displayed in the logs:

   ```
   WhatsApp API key: 1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef
   ```

4. Add the following to your Claude Desktop configuration:

   ```json
   {
       "mcpServers": {
	@@ -311,6 +331,7 @@ The project is structured with a clean separation of concerns:
3. **MCP Server (API Client)**: Connection to WhatsApp API server

This architecture allows for flexible deployment scenarios, including:

- Running the API server and MCP server on different machines
- Using the MCP server as a client to an existing API server
- Running everything on a single machine for simplicity
	@@ -330,6 +351,7 @@ src/
```

### Building from Source

```bash
npm run build
```
	@@ -390,19 +412,21 @@ This workflow requires an NPM_TOKEN secret to be configured in your GitHub repos
## Troubleshooting

### Claude Desktop Integration Issues

- It's not possible to start wweb-mcp in command standalone mode on Claude because Claude opens more than one process, multiple times, and each wweb-mcp needs to open a puppeteer session that cannot share the same WhatsApp authentication. Because of this limitation, we've split the app into MCP and API modes to allow for proper integration with Claude.

## Features

- Sending and receiving messages
- Sending media messages (images only)
- Downloading media from messages (images, audio, documents)
- Group chat management
- Contact management and search
- Message history retrieval

## Upcoming Features

- Support for sending all media file types (video, audio, documents)
- Enhanced message templates for common scenarios
- Advanced group management features
- Contact management (add/remove contacts)
	@@ -417,6 +441,7 @@ This workflow requires an NPM_TOKEN secret to be configured in your GitHub repos
5. Create a Pull Request

Please ensure your PR:

- Follows the existing code style
- Includes appropriate tests
- Updates documentation as needed
