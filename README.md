# 🌍 Earthquake Forecast - Real-Time Earthquake Monitoring & Awareness

<div align="center">

**A modern Flutter application for real-time earthquake monitoring and awareness**

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

[Features](#-features) • [Screenshots](#-screenshots) • [Installation](#-installation) • [Architecture](#-architecture) • [Contributing](#-contributing)

</div>

---

## 📖 About

This application was created in response to the recent earthquake incident in Bangladesh that left many people scared and uncertain about seismic activity. The goal is to raise awareness that earthquakes happen frequently around the world and to provide real-time information so people can stay informed and prepared.

**Mission:** To help people understand earthquake patterns globally and stay aware of seismic activity in their region, reducing fear through knowledge and preparedness.

## ✨ Features

### 🏠 Home Screen
- **Real-time earthquake data** from multiple global sources (USGS, EMSC)
- **Smart search** across past month's data
- **Intelligent filters:**
  - 🌍 All (24-hour data)
  - 📍 Near Me (location-based with 1000km radius)
  - ⚠️ Significant (major earthquakes from past month)
- **Modern glassmorphism UI** with Apple-style design
- **Smart data updates** with skeleton loaders (no full-page refresh)
- **Animated filter chips** with smooth transitions

### 🗺️ Interactive Map
- **Real-time earthquake markers** color-coded by magnitude
- **Region-based filtering:**
  - 🌍 World
  - 🌏 Asia
  - 🌍 Europe
  - 🌎 Americas
  - 🌍 Africa
  - 🌏 Oceania
- **Modern search bar** with glassmorphism design
- **Theme synchronization** with home screen
- **Zoom controls** with glossy buttons
- **Dark/Light map tiles** (CartoDB for dark mode)

### 📰 News & Forecasts
- **Earthquake forecasts** from reliable sources
- **Country-based filtering**
- **Search functionality**
- **Clean, modern card design**

### 🎨 Modern UI/UX
- **Glassmorphism design** throughout the app
- **Floating bottom navigation** with backdrop blur
- **Smooth animations** (300ms transitions)
- **Dark/Light theme support**
- **Gradient badges** for magnitude display
- **Responsive design** for all screen sizes

### 🔔 Notifications
- **Real-time alerts** for new earthquakes
- **Nearby earthquake notifications** (within 100km)
- **Background data fetching** with WorkManager
- **Custom app icon** for notifications

### 🌐 Multi-Source Data
- **USGS API** - Primary global earthquake data
- **EMSC API** - European-Mediterranean coverage
- **Intelligent deduplication** - Removes duplicates based on:
  - Location (within 10km)
  - Time (within 5 minutes)
  - Magnitude (within 0.3)

## 📱 Screenshots

<div align="center">

<img src="https://drive.google.com/file/d/1qHlLYR7ZT6V0bDvE1xre3NN7fEP9EgOP/view?usp=sharing" width="250" />
<img src="https://drive.google.com/file/d/1qHlLYR7ZT6V0bDvE1xre3NN7fEP9EgOP/view?usp=sharing" width="250" />
<!-- <img src="https://drive.google.com/uc?export=view&id=YOUR_SCREENSHOT_ID_3" width="250" /> -->

</div>


## 🚀 Installation

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Android Studio / Xcode (for mobile development)

### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/abuzafor99/earthquake-forecast.git
   cd earthquake-forecast
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Configuration

#### News API (Optional)
To enable real earthquake news:
1. Get a free API key from [NewsAPI.org](https://newsapi.org)
2. Update `lib/features/earthquake/data/sources/earthquake_api.dart`:
   ```dart
   static const String _newsApiKey = 'YOUR_API_KEY_HERE';
   ```

## 🏗️ Architecture

This project follows **Clean Architecture** principles with **GetX** for state management:

```
lib/
├── core/                    # Shared utilities and widgets
│   ├── controllers/         # Theme, Location controllers
│   ├── widgets/            # Reusable widgets
│   ├── services/           # Platform services
│   └── utils/              # Utilities
├── features/
│   └── earthquake/
│       ├── data/           # API clients, repositories
│       ├── domain/         # Repository interfaces
│       └── presentation/   # UI, controllers, widgets
└── main.dart              # App entry point
```

### Key Technologies
- **State Management:** GetX
- **Networking:** Dio
- **Maps:** flutter_map
- **Local Storage:** Hive, SharedPreferences
- **Background Tasks:** WorkManager
- **Notifications:** flutter_local_notifications

## 🎯 Key Features Explained

### Smart Data Updates
Instead of refreshing the entire screen, new earthquake data appears at the top with a skeleton loader, keeping existing data visible for a smooth user experience.

### Multi-API Integration
The app fetches data from multiple sources and intelligently merges them:
1. Fetch from USGS (all_month.geojson)
2. Fetch from EMSC (past 30 days)
3. Merge all data sources
4. Apply intelligent deduplication
5. Display unique earthquakes sorted by time

### Region-Based Map Navigation
Select a region from the dropdown to automatically center the map:
- **Asia:** Centers at 34°N, 100°E
- **Europe:** Centers at 54°N, 15°E
- **Americas:** Centers at 15°N, 90°W
- And more...

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **USGS** for providing comprehensive earthquake data
- **EMSC** for European-Mediterranean seismic data
- **NewsAPI** for earthquake-related news
- **Flutter community** for amazing packages and support

## 📧 Contact

**Developer:** [Abuzafor99]
- GitHub: [@yourusername](https://github.com/abuzafor99)
- Email: abuzafor.dev@gmail.com

---

<div align="center">

**Made with ❤️ to raise earthquake awareness and help people stay informed**

*Inspired by the recent earthquake in Bangladesh - Let's stay prepared, not scared!*

</div>
