# AR Model Processing Backend (C# + Blender)

## Prerequisites
- .NET 8 SDK
- Blender 4.x (in PATH: `blender --version`)
- Windows Firewall: Allow inbound TCP 5000

## Setup & Run
```bash
cd backend
dotnet restore
dotnet run --urls=http://0.0.0.0:5000
```

Console shows:
```
Network: http://192.168.x.x:5000 (use this IP in Flutter)
```

## API
- POST `/api/model/process`
  - Form-data: `file` (.fbx/.obj), `projectId` (string)
  - Returns: `{ modelUrl: "http://IP:5000/models/{id}.glb" }`
- GET `/models/{id}.glb` - Download processed model
- GET `/health` - OK
- GET `/swagger` - Docs

## Test Upload (curl)
```bash
curl -F "file=@house.fbx" -F "projectId=test" http://localhost:5000/api/model/process
```

## Flutter Integration
Update `database_service.dart`:
```dart
static const String backendUrl = 'http://192.168.x.x:5000'; // Your IP
Future uploadToBackend(...) => http.post(backendUrl + '/api/model/process'...)
```

## Troubleshooting
- Blender not found? Add to PATH or set FileName="C:\\Program Files\\Blender Foundation\\Blender 4.x\\blender.exe"
- Firewall? Windows Defender > Allow app dotnet.exe port 5000
- CORS? Already enabled for all origins

## Scale Later
- Auth (JWT/Firebase)
- Queue (Hangfire)
- Cloud (Docker/AWS)
