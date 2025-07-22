# ChatGPT Clone Backend API

## Base URL
`http://localhost:5000/api`

## Chat Endpoints

### Get All Chats
- **GET** `/chats`
- **Description**: Retrieves all chats for a specific user
- **Query Parameters**:
  - `uid` (string, required): User ID to filter chats by user
- **Response**: 
  ```json
  {
    "chats": [
      {
        "id": "string",
        "uid": "string",
        "title": "string",
        "messages": [/* latest message */],
        "createdAt": "datetime"
      }
    ],
    "count": number,
    "userId": "string"
  }
  ```

### Get Single Chat
- **GET** `/chats/:id`
- **Description**: Retrieves a specific chat with all its messages
- **Parameters**: 
  - `id` (string): Chat ID (MongoDB ObjectId)
- **Query Parameters**:
  - `uid` (string, required): User ID for access control
- **Response**: Chat object with all messages and images

### Create Chat
- **POST** `/chats`
- **Description**: Creates a new chat (title will be auto-generated after first complete conversation)
- **Body**:
  ```json
  {
    "uid": "user123", // Required: User ID who owns this chat
    "title": "Optional Custom Title" // Optional: defaults to "New Chat"
  }
  ```
- **Response**: 
  ```json
  {
    "success": true,
    "chat": {
      "id": "string",
      "uid": "string",
      "title": "string",
      "messages": [],
      "createdAt": "datetime"
    },
    "message": "Chat created successfully. Title will be auto-generated after first complete conversation (user message + AI response)."
  }
  ```

### Update Chat
- **PUT** `/chats/:id`
- **Description**: Updates a chat's title
- **Parameters**:
  - `id` (string): Chat ID (MongoDB ObjectId)
- **Body**:
  ```json
  {
    "title": "Updated Chat Title",
    "uid": "user123" // Required: for access control
  }
  ```
- **Response**: Updated chat object

### Delete Chat
- **DELETE** `/chats/:id`
- **Description**: Deletes a chat and all its messages
- **Parameters**:
  - `id` (string): Chat ID (MongoDB ObjectId)
- **Query Parameters**:
  - `uid` (string, required): User ID for access control
- **Response**: 204 No Content

### Generate Chat Title
- **POST** `/chats/:id/generate-title`
- **Description**: Generates a new title for chat based on conversation context (user message + AI response if available)
- **Parameters**:
  - `id` (string): Chat ID (MongoDB ObjectId)
- **Query Parameters**:
  - `uid` (string, required): User ID for access control
- **Response**:
  ```json
  {
    "success": true,
    "chat": {/* updated chat object */},
    "oldTitle": "string",
    "newTitle": "string",
    "basedOnMessage": "string (first 100 chars of first user message)",
    "hasConversationContext": boolean,
    "assistantResponse": "string (first 100 chars of first AI response, if available)"
  }
  ```

## Message Endpoints

### Get Messages
- **GET** `/chats/:chatId/messages`
- **Description**: Retrieves messages for a specific chat with pagination
- **Parameters**:
  - `chatId` (string): Chat ID (MongoDB ObjectId)
- **Query Parameters**:
  - `page` (number, optional): Page number (default: 1)
  - `limit` (number, optional): Messages per page (default: 50)
- **Response**: Object with messages array and pagination info

### Create Message
- **POST** `/chats/:chatId/messages`
- **Description**: Creates a new message in a chat (with optional image and auto-title generation after first complete conversation)
- **Parameters**:
  - `chatId` (string): Chat ID (MongoDB ObjectId)
- **Body**:
  ```json
  {
    "content": "Message content",
    "sender": "user", // or "assistant"
    "imageId": "optional_image_id" // Optional: ID of uploaded image
  }
  ```
- **Response**: 
  ```json
  {
    "success": true,
    "message": {
      "id": "string",
      "content": "string",
      "sender": "string",
      "imageId": "string or null",
      "image": {/* image object if imageId provided */},
      "createdAt": "datetime"
    },
    "titleGenerated": boolean,
    "newChatTitle": "string (if title was generated after first AI response)"
  }
  ```

### Delete Message
- **DELETE** `/messages/:messageId`
- **Description**: Deletes a specific message
- **Parameters**:
  - `messageId` (string): Message ID (MongoDB ObjectId)
- **Response**: 204 No Content

## Image Endpoints

### Upload Single Image
- **POST** `/images/upload`
- **Description**: Uploads a single image to Cloudinary
- **Content-Type**: `multipart/form-data`
- **Body**: Form data with `image` field containing the image file
- **File Requirements**:
  - Types: JPEG, PNG, GIF, WebP
  - Max size: 5MB
- **Response**: 
  ```json
  {
    "success": true,
    "image": {
      "id": "string",
      "publicId": "string",
      "originalName": "string",
      "size": number,
      "format": "string",
      "dimensions": {
        "width": number,
        "height": number
      },
      "urls": {
        "thumbnail": "string",
        "small": "string",
        "medium": "string",
        "large": "string",
        "original": "string"
      },
      "createdAt": "datetime"
    }
  }
  ```

### Upload Multiple Images
- **POST** `/images/upload/multiple`
- **Description**: Uploads multiple images (max 5)
- **Content-Type**: `multipart/form-data`
- **Body**: Form data with `images` field containing multiple image files
- **Response**: Array of uploaded image objects

### Get All Images
- **GET** `/images`
- **Description**: Retrieves all uploaded images with pagination
- **Query Parameters**:
  - `page` (number, optional): Page number (default: 1)
  - `limit` (number, optional): Images per page (default: 20)
- **Response**: Object with images array and pagination info

### Get Single Image
- **GET** `/images/:id`
- **Description**: Retrieves a specific image
- **Parameters**:
  - `id` (string): Image ID (MongoDB ObjectId)
- **Response**: Image object with all variants

### Delete Image
- **DELETE** `/images/:id`
- **Description**: Deletes an image from both Cloudinary and database
- **Parameters**:
  - `id` (string): Image ID (MongoDB ObjectId)
- **Response**: 204 No Content

## OpenAI/AI Endpoints

### Generate AI Response
- **POST** `/ai/chats/:chatId/generate`
- **Description**: Generates an AI response for a chat using OpenAI
- **Parameters**:
  - `chatId` (string): Chat ID (MongoDB ObjectId)
- **Body**:
  ```json
  {
    "model": "gpt-3.5-turbo", // optional, default: gpt-3.5-turbo
    "max_tokens": 1000, // optional, default: 1000
    "temperature": 0.7, // optional, default: 0.7
    "includeSystemMessage": true // optional, default: true
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "message": {
      "id": "string",
      "content": "AI response text",
      "sender": "assistant",
      "createdAt": "datetime"
    },
    "usage": {
      "prompt_tokens": number,
      "completion_tokens": number,
      "total_tokens": number
    },
    "model": "string",
    "context": {
      "messagesUsed": number,
      "truncated": boolean,
      "hasContextSummary": boolean,
      "estimatedTokens": number
    },
    "costEstimate": {
      "inputTokens": number,
      "estimatedInputCost": number,
      "estimatedOutputCost": number,
      "estimatedTotalCost": number
    }
  }
  ```

### Stream AI Response
- **POST** `/ai/chats/:chatId/stream`
- **Description**: Streams AI response in real-time using Server-Sent Events
- **Parameters**:
  - `chatId` (string): Chat ID (MongoDB ObjectId)
- **Body**: Same as generate endpoint
- **Response**: Server-Sent Events stream
  - Chunk events: `{"content": "text", "type": "chunk", "model": "string"}`
  - Complete event: `{"type": "complete", "messageId": "string", "fullContent": "string"}`

### Get Available Models
- **GET** `/ai/models`
- **Description**: Returns list of available OpenAI models
- **Response**:
  ```json
  {
    "models": [
      {
        "id": "gpt-3.5-turbo",
        "name": "GPT-3.5 Turbo",
        "description": "Fast and efficient for most tasks",
        "supports_images": false,
        "max_tokens": 4096
      }
    ],
    "configured": true
  }
  ```

### Test OpenAI Connection
- **GET** `/ai/test`
- **Description**: Tests the OpenAI API connection
- **Response**:
  ```json
  {
    "success": true,
    "configured": true,
    "response": "Hello, API test successful!",
    "model": "gpt-3.5-turbo"
  }
  ```

## Data Models

### Chat
```json
{
  "id": "string (ObjectId)",
  "uid": "string (User ID)",
  "title": "string",
  "messages": "Message[]",
  "createdAt": "datetime"
}
```

### Message
```json
{
  "id": "string (ObjectId)",
  "chatId": "string (ObjectId)",
  "content": "string",
  "sender": "user" | "assistant",
  "imageId": "string (ObjectId, optional)",
  "image": "Image (optional)",
  "createdAt": "datetime"
}
```

### Image
```json
{
  "id": "string (ObjectId)",
  "publicId": "string",
  "originalName": "string",
  "size": "number (bytes)",
  "format": "string",
  "dimensions": {
    "width": "number",
    "height": "number"
  },
  "urls": {
    "thumbnail": "string (150x150)",
    "small": "string (300x300)",
    "medium": "string (600x600)", 
    "large": "string (1200x1200)",
    "original": "string"
  },
  "createdAt": "datetime"
}
```

## Error Responses

### 400 Bad Request
```json
{
  "error": "Error message"
}
```

### 404 Not Found
```json
{
  "error": "Resource not found"
}
```

### 500 Internal Server Error
```json
{
  "error": "Internal server error message"
}
```

## Environment Variables

Create a `.env` file in the backend directory:

```
DATABASE_URL="mongodb://localhost:27017/chatgpt-clone"
PORT=5000
OPENAI_API_KEY=sk-your-actual-openai-api-key
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
```

### OpenAI Setup
1. Sign up at [OpenAI](https://platform.openai.com/)
2. Go to API Keys section and create a new API key
3. Replace `sk-your-actual-openai-api-key` with your real API key
4. **Important**: Never commit your actual API key to version control

### Cloudinary Setup
1. Sign up at [Cloudinary](https://cloudinary.com/)
2. Get your credentials from the dashboard
3. Replace the placeholder values in `.env`

### Flutter Integration Example

```dart
// For single image upload
Future<String?> uploadImage(File imageFile) async {
  final request = http.MultipartRequest(
    'POST',
    Uri.parse('http://localhost:5000/api/images/upload'),
  );
  
  request.files.add(
    await http.MultipartFile.fromPath('image', imageFile.path),
  );
  
  final response = await request.send();
  if (response.statusCode == 201) {
    final responseData = await response.stream.bytesToString();
    final data = json.decode(responseData);
    return data['image']['id']; // Return image ID for message
  }
  return null;
}

// For sending message with image
Future<void> sendMessageWithImage(String chatId, String content, String? imageId) async {
  final response = await http.post(
    Uri.parse('http://localhost:5000/api/chats/$chatId/messages'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'content': content,
      'sender': 'user',
      'imageId': imageId, // Optional
    }),
  );
}

// Generate AI response
Future<Map<String, dynamic>?> generateAIResponse(String chatId, {
  String model = 'gpt-3.5-turbo',
  int maxTokens = 1000,
  double temperature = 0.7,
}) async {
  final response = await http.post(
    Uri.parse('http://localhost:5000/api/ai/chats/$chatId/generate'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'model': model,
      'max_tokens': maxTokens,
      'temperature': temperature,
    }),
  );
  
  if (response.statusCode == 200) {
    return json.decode(response.body);
  }
  return null;
}

// Stream AI response (using Server-Sent Events)
Stream<String> streamAIResponse(String chatId, {
  String model = 'gpt-3.5-turbo',
  int maxTokens = 1000,
  double temperature = 0.7,
}) async* {
  final request = http.Request(
    'POST',
    Uri.parse('http://localhost:5000/api/ai/chats/$chatId/stream'),
  );
  
  request.headers['Content-Type'] = 'application/json';
  request.body = json.encode({
    'model': model,
    'max_tokens': maxTokens,
    'temperature': temperature,
  });
  
  final client = http.Client();
  final response = await client.send(request);
  
  await for (final chunk in response.stream.transform(utf8.decoder)) {
    final lines = chunk.split('\n');
    for (final line in lines) {
      if (line.startsWith('data: ')) {
        final data = line.substring(6);
        if (data.trim().isNotEmpty) {
          try {
            final parsed = json.decode(data);
            if (parsed['type'] == 'chunk') {
              yield parsed['content'];
            } else if (parsed['type'] == 'complete') {
              client.close();
              return;
            }
          } catch (e) {
            // Handle parsing errors
          }
        }
      }
    }
  }
}

// Complete chat flow example
class ChatService {
  static const String baseUrl = 'http://localhost:5000/api';
  
  // Send user message and get AI response
  Future<void> sendMessageAndGetResponse(String chatId, String message, {File? image}) async {
    String? imageId;
    
    // Upload image if provided
    if (image != null) {
      imageId = await uploadImage(image);
    }
    
    // Send user message
    await sendMessageWithImage(chatId, message, imageId);
    
    // Generate AI response
    final aiResponse = await generateAIResponse(chatId);
    
    if (aiResponse != null && aiResponse['success'] == true) {
      print('AI Response: ${aiResponse['message']['content']}');
      print('Tokens used: ${aiResponse['usage']['total_tokens']}');
      print('Estimated cost: \$${aiResponse['costEstimate']['estimatedTotalCost']}');
    }
  }
  
  // Test OpenAI connection
  Future<bool> testOpenAIConnection() async {
    final response = await http.get(
      Uri.parse('$baseUrl/ai/test'),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['configured'] == true;
    }
    return false;
  }
}
```
