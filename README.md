# ShootingApp
An iOS augmented reality shooting game that uses location services and device orientation to create an interactive multiplayer experience with blockchain integration.

## Features
- Real-time player tracking
- Location-based shooting mechanics
- Live multiplayer interactions
- CoreData persistence
- WebSocket communication
- MetaMask wallet integration
- Achievement rewards through blockchain
- Secure wallet connection flow

## Requirements
- iOS 14.0+
- Xcode 14.0+
- Swift 5.0+
- Node.js server running WebSocket service
- MetaMask iOS app

## Installation
1. Clone the repositories
```bash
# iOS App
git clone https://github.com/JFCaBa/ShootingApp.git
# Server
git clone https://github.com/JFCaBa/ShootingApp-Server.git
```

2. Setup Server
```bash
cd ShootingApp-Server
npm install
npm start
```

3. Install Dependencies
```bash
cd ShootingApp
pod install
```

## Architecture
The app follows MVVM-C (Model-View-ViewModel-Coordinator) architecture pattern with the following components:
- **Models**: Data structures and business logic
- **Views**: UI components and controllers
- **ViewModels**: Presentation logic and state management
- **Coordinators**: Navigation and flow control
- **Services**: Web3 and blockchain integrations

## Blockchain Integration
The game uses MetaMask for wallet integration:
- Connect your MetaMask wallet to earn rewards
- Secure authentication flow
- Achievement tracking and rewards
- Optional wallet connection
- Deep linking support

## Server
The game requires a WebSocket server running on Node.js. The server handles:
- Real-time player connections
- Message broadcasting
- Player session management
- Game state synchronization
- Achievement verification

Server repository: [ShootingApp-Server](https://github.com/JFCaBa/ShootingApp-Server)

## Contributing
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request
