import Foundation
import AppKit
import CoreLocation

public class WeatherService: NSObject, CLLocationManagerDelegate {
    public static let shared = WeatherService()

    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private var pollTimer: Timer?

    private var currentLat: Double = -6.2238
    private var currentLon: Double = 106.6508
    private var currentCity: String = "Alam Sutera"
    private var hasResolvedLocation: Bool = false

    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 500.0 // updates every 500m
    }

    public func start() {
        requestLiveLocation()
        fetchWeather()

        pollTimer?.invalidate()
        // Refresh every 15 minutes
        pollTimer = Timer.scheduledTimer(withTimeInterval: 900.0, repeats: true) { [weak self] _ in
            self?.requestLiveLocation()
            self?.fetchWeather()
        }
    }

    public func requestLiveLocation() {
        // If manual override is explicitly set by user, use that
        if let city = DuckState.shared.weatherCityOverride,
           let lat = DuckState.shared.weatherLatOverride,
           let lon = DuckState.shared.weatherLonOverride {
            self.currentLat = lat
            self.currentLon = lon
            self.currentCity = city
            fetchWeather()
            return
        }

        let status = locationManager.authorizationStatus
        if status == .notDetermined {
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        } else if status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }

    // MARK: - CLLocationManagerDelegate
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        if status == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        // Skip GPS updates if user manually set an override
        if DuckState.shared.weatherCityOverride != nil { return }

        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude

        self.currentLat = lat
        self.currentLon = lon

        geocoder.cancelGeocode()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            if let p = placemarks?.first {
                var resolved = p.locality ?? p.subLocality ?? p.administrativeArea ?? "Local"
                if p.subLocality?.lowercased().contains("pinang") == true ||
                   p.name?.lowercased().contains("alam sutera") == true ||
                   p.thoroughfare?.lowercased().contains("sutera") == true {
                    resolved = "Alam Sutera"
                }
                self.currentCity = resolved
                self.hasResolvedLocation = true
            }
            self.fetchWeatherForCoordinates(lat: lat, lon: lon, city: self.currentCity)
        }
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("[WeatherService] Location error: \(error.localizedDescription)")
    }

    public func fetchWeather() {
        if let city = DuckState.shared.weatherCityOverride,
           let lat = DuckState.shared.weatherLatOverride,
           let lon = DuckState.shared.weatherLonOverride {
            fetchWeatherForCoordinates(lat: lat, lon: lon, city: city)
        } else {
            fetchWeatherForCoordinates(lat: currentLat, lon: currentLon, city: currentCity)
        }
    }

    private func fetchWeatherForCoordinates(lat: Double, lon: Double, city: String) {
        let urlStr = "https://api.open-meteo.com/v1/forecast?latitude=\(lat)&longitude=\(lon)&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,is_day,precipitation"
        guard let url = URL(string: urlStr) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let current = json["current"] as? [String: Any] else {
                return
            }

            let temp = current["temperature_2m"] as? Double ?? 28.0
            let humidity = current["relative_humidity_2m"] as? Int ?? 65
            let feelsLike = current["apparent_temperature"] as? Double ?? temp
            let code = current["weather_code"] as? Int ?? 1
            let isDay = (current["is_day"] as? Int ?? 1) == 1
            let precip = current["precipitation"] as? Double ?? 0.0

            let (cond, icon, isRain) = self.parseWMO(code: code, isDay: isDay, precip: precip)
            let isHot = temp >= 32.0
            let isNight = !isDay

            DispatchQueue.main.async {
                DuckState.shared.weatherTemp = temp
                DuckState.shared.weatherFeelsLike = feelsLike
                DuckState.shared.weatherHumidity = humidity
                DuckState.shared.weatherCity = city
                DuckState.shared.weatherCondition = cond
                DuckState.shared.weatherIcon = icon
                DuckState.shared.isRaining = isRain
                DuckState.shared.isNight = isNight
                DuckState.shared.isHotSunny = (isHot && isDay)

                DynamicIslandWindow.shared?.contentView?.needsDisplay = true
                MenuBarController.shared.updateMenu()
                SyncServer.shared.broadcastState()
            }
        }.resume()
    }

    public func setLocationOverride(city: String, lat: Double, lon: Double) {
        DuckState.shared.weatherCityOverride = city
        DuckState.shared.weatherLatOverride = lat
        DuckState.shared.weatherLonOverride = lon
        fetchWeather()
    }

    public func clearLocationOverride() {
        DuckState.shared.weatherCityOverride = nil
        DuckState.shared.weatherLatOverride = nil
        DuckState.shared.weatherLonOverride = nil
        requestLiveLocation()
        fetchWeather()
    }

    public func searchAndSetCity(_ query: String, completion: @escaping (Bool) -> Void) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let encoded = trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://geocoding-api.open-meteo.com/v1/search?name=\(encoded)&count=1&language=en&format=json") else {
            completion(false)
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self, let data = data, error == nil,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let results = json["results"] as? [[String: Any]],
                  let first = results.first,
                  let lat = first["latitude"] as? Double,
                  let lon = first["longitude"] as? Double else {
                DispatchQueue.main.async { completion(false) }
                return
            }
            let name = first["name"] as? String ?? trimmed
            DispatchQueue.main.async {
                self.setLocationOverride(city: name, lat: lat, lon: lon)
                completion(true)
            }
        }.resume()
    }

    private func parseWMO(code: Int, isDay: Bool, precip: Double) -> (condition: String, icon: String, isRain: Bool) {
        switch code {
        case 0:
            return (isDay ? "Clear Sky" : "Clear Night", isDay ? "sun.max.fill" : "moon.stars.fill", false)
        case 1, 2:
            return ("Partly Cloudy", isDay ? "cloud.sun.fill" : "cloud.moon.fill", false)
        case 3:
            return ("Overcast", "cloud.fill", false)
        case 45, 48:
            return ("Foggy", "cloud.fog.fill", false)
        case 51, 53, 55:
            return ("Light Drizzle", "cloud.drizzle.fill", true)
        case 61, 63, 65:
            return ("Rain Showers", "cloud.rain.fill", true)
        case 80, 81, 82:
            return ("Heavy Rain", "cloud.heavyrain.fill", true)
        case 95, 96, 99:
            return ("Thunderstorm", "cloud.bolt.rain.fill", true)
        default:
            if precip > 0.1 {
                return ("Rain", "cloud.rain.fill", true)
            }
            return (isDay ? "Partly Cloudy" : "Cloudy Night", isDay ? "cloud.sun.fill" : "cloud.moon.fill", false)
        }
    }
}
