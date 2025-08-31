# 🚗 Car Dashboard - Android

A futuristic car dashboard application built with Flutter, designed with a terminal-inspired aesthetic for software engineers. Features real-time GPS tracking, Bluetooth connectivity with ESP32, and comprehensive vehicle monitoring.

## ✨ Features

### 📱 **Dashboard Display**

- **Speedometer**: Large center display with tachometer ring
- **Trip Computer**: Distance, fuel usage, average temperature, average speed
- **Warning System**: Oil pressure, battery voltage monitoring
- **Light Controls**: DRL, low/high beams, turn signals, hazard lights
- **Gauge Displays**: Coolant temperature, fuel level with color-coded alerts
- **Demo Mode**: Animated showcase of all dashboard features

### 🛰️ **GPS Tracking**

- **Real-time Speed**: High-accuracy GPS-based speedometer
- **Trip Tracking**: Automatic distance, time, and speed calculations
- **Data Persistence**: Trip data saved to local JSON file
- **Smart Filtering**: Motion detection to eliminate GPS drift

### 📡 **Bluetooth Connectivity**

- **ESP32 Integration**: Secure connection with car's onboard systems
- **Authentication**: Challenge-response protocol with SHA256 hashing
- **Real-time Data**: Receive sensor data from vehicle systems

## 🔧 Technical Specifications

### **GPS Speed Measurement**

#### **Measurement Frequency**

- **Update Trigger**: Every **1 meter** of movement OR when location changes significantly
- **Time Limit**: Maximum 5-second timeout per reading
- **Accuracy**: `LocationAccuracy.high` for precise readings
- **Speed Cap**: 300 km/h maximum (safety limit)

#### **Speed Calculation Method**

```dart
// GPS provides speed in m/s, converted to km/h
_currentSpeed = (position.speed * 3.6).clamp(0.0, 300.0);
```

#### **Trip Average Speed Calculation**

- **Method**: True distance/time calculation (not rolling average)
- **Formula**: `average_speed = distance_at_meaningful_speeds / time_at_meaningful_speeds`
- **Minimum Speed Threshold**: **10 km/h** - excludes parking, maneuvers, tight roads
- **Excludes**: Speeds <10 km/h (parking, traffic jams, tight turns)
- **Includes**: Only meaningful driving speeds for realistic trip average

#### **Distance Calculation**

- **Method**: Haversine formula via `Geolocator.distanceBetween()`
- **Threshold**: Only counts distance when moving >1 km/h (eliminates GPS drift)
- **Validation**: Distance increments capped at reasonable values (<0.1 km per reading)

#### **Average Speed Logic**

```dart
// Only count distance and time when speed >= 10 km/h
if (currentSpeed >= 10.0) {
  tripAverageDistance += distance;
  tripAverageTime += timeDifference;
}

// Calculate true trip average
tripAverage = tripAverageDistance / (tripAverageTime.inHours);
```

**Example**: 100km trip with 30 minutes of parking/maneuvering at <10 km/h

- **Traditional**: 100km ÷ 2.5 hours = 40 km/h
- **This App**: 100km ÷ 2.0 hours = 50 km/h (excludes slow maneuvers)

### **Bluetooth Communication**

#### **Device Connection**

- **Target Device**: `RAVO_CAR_DASH` (ESP32 Bluetooth Classic)
- **Authentication**: Required before data exchange
- **Auto-discovery**: Scans bonded devices for target

#### **Authentication Protocol**

```
1. ESP32 → App: CHALLENGE:<random_16_char_string>
2. App → ESP32: <SHA256(challenge + "super_secret_salt")>
3. ESP32 → App: AUTH OK | AUTH FAIL
```

**Security Features:**

- **Salt Protection**: `"super_secret_salt"` prevents replay attacks
- **SHA256 Hashing**: Cryptographic challenge-response
- **Auto-disconnect**: Failed authentication closes connection

#### **Data Format (JSON)**

```json
{
  "speed": 85.5,
  "rpm": 2500,
  "tripDistance": 245.8,
  "fuelUsage": 8.5,
  "avgTemperature": 22.0,
  "avgSpeed": 58.2,
  "coolantTemp": 85.0,
  "fuelLevel": 65.0,
  "oilWarning": false,
  "batteryVoltage": 12.6,
  "drlOn": true,
  "lowBeamOn": false,
  "highBeamOn": false,
  "leftTurnSignal": false,
  "rightTurnSignal": false,
  "hazardLights": false
}
```

#### **ESP32 Integration Code**

```cpp
#include "BluetoothSerial.h"
#include "mbedtls/sha256.h"

BluetoothSerial SerialBT;
const char* btDeviceName = "RAVO_CAR_DASH";
const char* salt = "super_secret_salt";

// Send JSON data to dashboard
void sendDashboardData() {
  String jsonData = "{";
  jsonData += "\"speed\":" + String(getCurrentSpeed()) + ",";
  jsonData += "\"rpm\":" + String(getCurrentRPM()) + ",";
  jsonData += "\"batteryVoltage\":" + String(getBatteryVoltage()) + ",";
  jsonData += "\"coolantTemp\":" + String(getCoolantTemp()) + ",";
  jsonData += "\"fuelLevel\":" + String(getFuelLevel()) + ",";
  jsonData += "\"oilWarning\":" + String(getOilWarning() ? "true" : "false");
  jsonData += "}";

  SerialBT.println(jsonData);
}
```

### **Data Storage**

#### **Trip Data Persistence**

- **Location**: `app_documents_directory/trip_data.json`
- **Format**: JSON with full trip history and speed points
- **Auto-resume**: Active trips continue after app restart
- **Storage Frequency**: Every 10 GPS updates (reduces file I/O)

#### **Trip Data Structure**

```json
{
  "startTime": 1703123456789,
  "endTime": null,
  "totalDistance": 15.3,
  "maxSpeed": 87.2,
  "averageSpeed": 45.6,
  "totalTimeSeconds": 1240,
  "speedPoints": [
    {
      "timestamp": 1703123456789,
      "speed": 45.2,
      "latitude": 40.7128,
      "longitude": -74.006,
      "altitude": 10.5
    }
  ],
  "isActive": true
}
```

## 🚀 Installation & Setup

### **Prerequisites**

- Flutter SDK 3.5.3+
- Android device with API level 27+
- GPS and Bluetooth capabilities

### **Android Permissions**

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
```

### **Dependencies**

```yaml
dependencies:
  flutter: sdk: flutter
  google_fonts: ^6.1.0
  flutter_bluetooth_serial: ^0.4.0
  crypto: ^3.0.3
  provider: ^6.1.1
  permission_handler: ^11.3.1
  geolocator: ^10.1.1
  path_provider: ^2.1.2
```

### **Build & Deploy**

```bash
# Install dependencies
flutter pub get

# Connect Android device with USB debugging enabled
adb devices

# Deploy to device
flutter run -d <device_id>
```

## 🎮 Usage

### **Controls**

- **GPS Button**: Start/stop location tracking (green when active)
- **Bluetooth Button**: Connect/disconnect from ESP32 device
- **Demo Button**: Toggle animated demo mode

### **Status Indicators**

- **GPS Status**: TRACKING (green) | READY (cyan) | DISABLED (gray)
- **Bluetooth Status**: CONNECTED (green) | CONNECTING (cyan) | DISCONNECTED (gray)

### **Color Coding**

- **Green**: Success, normal operation, good status
- **Cyan**: Primary data, active connections
- **Yellow/Orange**: Warnings, medium priority alerts
- **Red**: Critical warnings, immediate attention required
- **Gray**: Inactive, disabled, or neutral status

## 🔧 Development

### **Architecture**

- **State Management**: Provider pattern with reactive UI updates
- **Services**: Modular GPS, Bluetooth, and Dashboard state services
- **Models**: Immutable data classes with JSON serialization
- **Widgets**: Reusable, styled components following design system

### **Key Files**

- `lib/services/gps_service.dart` - GPS tracking and trip calculation
- `lib/services/bluetooth_service.dart` - ESP32 communication
- `lib/services/dashboard_state.dart` - Central state management
- `lib/models/trip_data.dart` - Trip data model and persistence
- `lib/widgets/` - UI components (gauges, speedometer, etc.)

## 📊 Performance

### **GPS Efficiency**

- **Smart Updates**: Only processes movement >1 km/h
- **Battery Optimization**: Configurable distance filter (1m minimum)
- **Memory Management**: Rolling 10-reading history buffer

### **Bluetooth Reliability**

- **Auto-reconnection**: Handles connection drops gracefully
- **Error Recovery**: Automatic retry on authentication failure
- **Data Validation**: JSON parsing with fallback defaults

## 🛡️ Security

### **Bluetooth Security**

- **Encrypted Authentication**: SHA256 challenge-response
- **Device Pairing**: Requires manual Bluetooth pairing first
- **Salt Protection**: Prevents replay attacks
- **Auto-timeout**: Authentication expires after 10 seconds

### **Privacy**

- **Local Storage**: All trip data stored locally on device
- **No Cloud**: No data transmitted to external servers
- **Permission Control**: User-controlled GPS and Bluetooth access

## 🚗 ESP32 Integration

For complete ESP32 car integration, see the authentication code example above. The ESP32 should:

1. **Advertise** as `RAVO_CAR_DASH`
2. **Authenticate** incoming connections with challenge-response
3. **Send JSON data** at regular intervals (1-5 seconds recommended)
4. **Include all sensor readings** as shown in data format above

## 📝 License

This project is built for educational and personal use. Modify and adapt as needed for your vehicle integration projects.

---

**⚠️ Safety Notice**: This dashboard is intended for passenger use or stationary operation. Driver should not interact with the app while vehicle is in motion. Always prioritize road safety over dashboard monitoring.
