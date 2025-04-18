# PhoneInfoga Docker Setup Guide

## Introduction
This guide provides a streamlined approach to setting up and running PhoneInfoga using Docker. Following these instructions will help you avoid common setup issues and get the application running quickly.

## Prerequisites and System Requirements

### Docker Installation
- Docker Desktop installed and running
- Minimum 4GB RAM recommended
- At least 2GB free disk space
- Internet connection for pulling dependencies

### System Architecture Support
- ARM64 (M1/M2 Mac): Requires platform-specific build
- AMD64 (Intel/AMD): Works with standard build
- Both architectures are fully supported with our Dockerfile

## Step-by-Step Installation Guide

### 1. Pre-installation Checks
```bash
# Verify Docker installation
docker --version

# Check available disk space
df -h

# Check system architecture
uname -m
```

2. **Required API Keys (Optional but Recommended)**
> Set up these APIs before building Docker image for full functionality

**Numverify API** (For phone number validation)
- Sign up at https://numverify.com/
- Get your API key from the dashboard
- Create a `.env` file in project root:
    ```
    NUMVERIFY_API_KEY=your_api_key_here
    ```

**Google Custom Search Engine** (For enhanced search results)
- Go to https://programmablesearchengine.google.com/
- Create a new search engine
- Get your Search Engine ID
- Create Google Cloud Project and enable Custom Search API
- Generate API key from Google Cloud Console
- Add to your `.env` file:
    ```
    GOOGLE_API_KEY=your_google_api_key
    GOOGLE_CSE_ID=your_search_engine_id
    ```

### 2. Building the Docker Image
```bash
# Clone the repository
git clone https://github.com/your-username/phoneinfoga.git
cd phoneinfoga

# For ARM64 (M1/M2 Mac) users:
docker build --platform linux/arm64 -t phoneinfoga .

# For AMD64 (Intel/AMD) users:
docker build -t phoneinfoga .
```

### 3. Running the Container
```bash
# Start the web interface (recommended)
docker run -p 5000:5000 phoneinfoga serve

# Start in detached mode (run in background)
docker run -d -p 5000:5000 phoneinfoga serve

# For scanning a specific number
docker run phoneinfoga scan -n "+1234567890"
```

The web interface will be available at http://localhost:5000

## Troubleshooting Guide

### Common Issues and Solutions

1. **Node.js Version Conflicts**
- Issue: "node-ipc incompatibility errors"
- Solution: Our Dockerfile uses Node.js 20.x, which is compatible with all dependencies
- No action needed from users as this is handled in the Dockerfile

2. **Architecture-Specific Issues**
- ARM64 users: Always use `--platform linux/arm64` during build
- AMD64 users: Standard build works without platform flag
- If you see "exec format error", ensure you used the correct platform flag

3. **Port Conflicts**
- If port 5000 is in use, change the port mapping:
```bash
docker run -p 8080:5000 phoneinfoga serve
```
Then access via http://localhost:8080

4. **Docker Build Failures**
- Ensure Docker has enough resources (4GB+ RAM recommended)
- Clear Docker cache if needed:
```bash
docker system prune -a
```

## Usage Instructions

### Accessing the Web Interface
1. Open your browser and navigate to http://localhost:5000
2. The web interface provides:
- Phone number input field
- Scanner selection options
- Results display
- API endpoint access

### Basic Usage Examples
```bash
# Scan a number with full results
docker run phoneinfoga scan -n "+1234567890"

# Get available scanners
docker run phoneinfoga scanners

# Check version
docker run phoneinfoga version
```

### API Usage
- The web interface provides a built-in API
- API endpoints are accessible at:
    - GET /api/v2/numbers
    - GET /api/v2/scanners
    - POST /api/v2/numbers/{number}/scan

## Development Notes

### Building for Different Architectures
```bash
# Build for multiple platforms
docker buildx build --platform linux/amd64,linux/arm64 -t phoneinfoga .
```

### Environment Variables
For additional scanner functionality, configure these optional environment variables:
```bash
# Add to your docker run command with -e flag
docker run -e NUMVERIFY_API_KEY="your-key" \
        -e GOOGLE_API_KEY="your-key" \
        -e GOOGLE_CSE_ID="your-id" \
        -p 5000:5000 phoneinfoga serve
```

## Manual Setup (Advanced Users)

This guide provides step-by-step instructions for setting up and running PhoneInfoga on your local machine.

## Prerequisites

Before starting, ensure you have the following installed:
- Go (version 1.16 or later)
- Node.js (version 14 or later)
- Yarn (will be installed during setup)
- Git
- VS Code (recommended) with Go extension

## Installation Steps

1. **Clone the Repository**
```bash
git clone https://github.com/your-username/phoneinfoga.git
cd phoneinfoga
```

2. **Install Go Dependencies**
```bash
go mod download
```

3. **Build Web Client**
```bash
cd client
npm install -g yarn      # Install Yarn if not already installed
yarn set version classic # Switch to Yarn Classic
yarn install            # Install dependencies
yarn build             # Build the client
cd ..                  # Return to root directory
```

4. **Run the Application**
```bash
# Run web interface
go run main.go serve    # Access at http://localhost:5000

# OR run CLI scanner
go run main.go scan -n "+914834567890"
```

## API Configuration

To enable all scanning features, you'll need to configure the following APIs:

### 1. Numverify API
- Sign up at https://numverify.com/
- Get your API key
- Set environment variable:
```bash
export NUMVERIFY_API_KEY="your-api-key"
```

### 2. Google Custom Search Engine (CSE)
1. Create a Custom Search Engine:
- Go to https://programmablesearchengine.google.com/
- Create a new search engine
- Get your Search Engine ID

2. Set up Google Cloud API:
- Create a project in Google Cloud Console
- Enable Custom Search API
- Generate an API key

3. Set environment variables:
```bash
export GOOGLE_API_KEY="your-google-api-key"
export GOOGLE_CSE_ID="your-search-engine-id"
```

## VS Code Setup

1. Install required extensions:
- Go (by Go Team at Google)
- Go Test Explorer (optional)

2. Install Go tools:
- Open Command Palette (Cmd+Shift+P or Ctrl+Shift+P)
- Run "Go: Install/Update Tools"
- Select all tools when prompted

3. Add recommended settings:
```json
{
    "go.useLanguageServer": true,
    "go.formatTool": "goimports",
    "[go]": {
        "editor.formatOnSave": true,
        "editor.codeActionsOnSave": {
            "source.organizeImports": true
        }
    }
}
```

## Troubleshooting

1. **Web Client Build Issues**
- If you encounter Yarn errors, ensure you're using Yarn Classic:
    ```bash
    yarn set version classic
    ```
- Clear Yarn cache if needed:
    ```bash
    yarn cache clean
    ```

2. **API Related Issues**
- "Numverify API key is not defined" - Set the NUMVERIFY_API_KEY environment variable
- "Country code XX is not supported" - Some countries aren't supported by OVH scanner
- "Google CSE ID/API key not defined" - Set GOOGLE_API_KEY and GOOGLE_CSE_ID environment variables

3. **Go Build Issues**
- Run `go mod tidy` to ensure dependencies are correct
- Clear Go module cache if needed:
    ```bash
    go clean -modcache
    go mod download
    ```


## Important Notes

- Always include country code with phone numbers
- Some scanners require API keys for full functionality
- The web interface provides a more user-friendly experience
- Follow local laws and regulations regarding phone number scanning
- Only scan phone numbers you have permission to investigate

