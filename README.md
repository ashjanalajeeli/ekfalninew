# Ekfalni - Charity Platform

A Flutter-based charity platform application that connects donors with those in need.

## Features

- User Authentication (Login/Register)
- Profile Management
- Donation Management
- Real-time Updates
- Secure API Integration
- Multi-language Support
- Responsive UI Design

## Getting Started

### Prerequisites

- Flutter SDK (^3.5.4)
- Dart SDK (^3.5.4)
- Android Studio / VS Code
- Git

### Installation

1. Clone the repository
```bash
git clone https://github.com/ashjanalajeeli/ekfalninew.git
```

2. Navigate to the project directory
```bash
cd ekfalninew
```

3. Install dependencies
```bash
flutter pub get
```

4. Run the build runner to generate necessary files
```bash
dart run build_runner build --delete-conflicting-outputs
```

5. Run the app
```bash
flutter run
```

### Environment Setup

1. Update the API base URL in `lib/config/api_config.dart`
2. Configure your backend server URL
3. Set up environment variables if needed

## Project Structure

```
lib/
├── config/         # Configuration files
├── models/         # Data models
├── services/       # API and other services
├── repositories/   # Data repositories
├── screens/        # UI screens
├── widgets/        # Reusable widgets
├── theme/         # Theme configuration
└── main.dart      # Entry point
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

Project Link: https://github.com/ashjanalajeeli/ekfalninew
