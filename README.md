# Label-Liar 2.0 - AI Health Auditor

![Logo](showcase/assets/logo.png)

**Label-Liar 2.0** is a state-of-the-art Hybrid AI application designed to help users navigate the complex world of food ingredient labels. By leveraging Artificial Intelligence, the app provides instant, personalized health audits, ensuring you know exactly what is in your food and how it affects your specific health profile.

---

## 🌟 Key Features

- **🔍 Smart OCR Scanning**: Utilizes Google ML Kit to extract text from product ingredient labels with high precision.
- **🧠 AI-Powered Auditing**: Integrated with **Google Gemini Pro** to interpret ingredients and identify potential health risks or benefits.
- **👤 Personalized Health Profiles**: Custom logic for specific dietary needs, including:
  - Diabetic-friendly audits.
  - Vegan & Vegetarian validation.
  - Allergy detection (Nuts, Gluten, Dairy, etc.).
  - Fitness-focused nutritional breakdown.
- **🎨 Premium UI/UX**: A beautiful **Glassmorphism-inspired** interface built with Flutter, optimized for a modern mobile experience.
- **📜 Audit History**: Save and review past scans to track your dietary habits.

---

## 🛠️ Technology Stack

### Frontend
- **Framework**: [Flutter](https://flutter.dev/) (Dart)
- **Scanning**: [Google ML Kit](https://developers.google.com/ml-kit) (OCR)
- **Design**: Glassmorphism with custom animations.

### Backend
- **Runtime**: [Node.js](https://nodejs.org/) & [Express.js](https://expressjs.com/)
- **Intelligence**: [Google Gemini Pro AI](https://deepmind.google/technologies/gemini/)
- **Database**: [MongoDB](https://www.mongodb.com/) (NoSQL) for user profiles and scan history.

---

## 🚀 Getting Started

### Prerequisites
- [Node.js](https://nodejs.org/) (v16+)
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [MongoDB Atlas](https://www.mongodb.com/cloud/atlas) or a local instance.

### 1. Backend Setup
The backend handles the core logic and AI integrations.
```bash
cd backend
npm install
# Create a .env file with your GEMINI_API_KEY and MONGO_URI
npm start
```
*The server will run on `http://localhost:5000`.*

### 2. Frontend Setup
The mobile application is optimized for Android.
```bash
cd frontend
flutter pub get
flutter run
```
**Note:** Ensure your physical device and dev machine are on the same Wi-Fi. Update the API URL in `lib/services/api_service.dart` if necessary.

---

## 🌐 Showcase Website
We have included a premium showcase website to demonstrate the app's features and design. You can view it locally at:
`showcase/index.html`

---

## 📞 Contact Details
Developed by **Kartik**.

- **LinkedIn**: [chipinapikarthik](https://www.linkedin.com/in/chipinapikarthik/)
- **Email**: [chkarthik853@gmail.com](mailto:chkarthik853@gmail.com)
- **GitHub**: [karthik7133/health](https://github.com/karthik7133/health.git)

---

## 📜 License
This project is licensed under the MIT License.
