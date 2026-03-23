# Label-Liar 2.0 - AI Health Auditor

This project is a Hybrid AI application that scans food ingredients and provides a personalized health analysis using Google Gemini.

## Prerequisites
- Node.js & npm
- Flutter SDK
- Android Studio / Emulator

## Setup & Run

### 1. Backend (Node.js)
The backend handles the connection to MongoDB and the Gemini API.

```bash
cd backend
npm install
npm start
```
*Server runs on `http://localhost:5000`*

### 2. Frontend (Flutter)
The frontend is the mobile application (Optimized for Android).

```bash
cd frontend
flutter pub get
flutter run
```

**Note for Physical Devices:**
The app is configured to connect to your computer's local IP address (`http://192.168.0.105:5000/api`).
Ensure your phone and computer are on the same Wi-Fi network.

## Features
- **OCR Scanning**: Uses Google ML Kit to read ingredients.
- **AI Analysis**: Uses Gemini Pro to interpret ingredients based on user profiles.
- **Glassmorphism UI**: Premium, modern design.
- **Personalized Logic**: Detects "Diabetic", "Vegan", etc.

## Configuration
- **Backend Keys**: Stored in `backend/.env`.
- **API URL**: Configured in `frontend/lib/services/api_service.dart`.
