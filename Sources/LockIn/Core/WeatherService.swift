import Foundation
import AppKit

public class WeatherService {
    public static let shared = WeatherService()

    private var timer: Timer?
    private var lastFetchTime: Date?
    private var cachedLat: Double = -6.2238
    private var cachedLon: Double = 106.6508
    private var cachedCity: String = "Alam Sutera"

    private init() {}

    public func start() {
        fetchWeather()
        timer?.invalidate()
        // Poll every 20 minutes (1200 seconds)
        timer = Timer.scheduledTimer(withTimeInterval: 1200.0, repeats: true) { [weak self] _ in
            self?.fetchWeather()
        }
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

    public func fetchWeather() {
        // Step 1: Update Location if needed or use cached
        fetchLocation { [weak self] lat, lon, city in
            guard let self = self else { return }
            self.cachedLat = lat
            self.cachedLon = lon
            self.cachedCity = city

            // Step 2: Fetch Weather from Open-Meteo
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
    }

    private func fetchLocation(completion: @escaping (Double, Double, String) -> Void) {
        if let city = DuckState.shared.weatherCityOverride,
           let lat = DuckState.shared.weatherLatOverride,
           let lon = DuckState.shared.weatherLonOverride {
            completion(lat, lon, city)
            return
        }

        guard let url = URL(string: "https://ipwho.is/") else {
            completion(cachedLat, cachedLon, cachedCity)
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self else { return }
            if let data = data, error == nil,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let lat = json["latitude"] as? Double,
               let lon = json["longitude"] as? Double,
               let city = json["city"] as? String {
                completion(lat, lon, city)
            } else {
                completion(self.cachedLat, self.cachedLon, self.cachedCity)
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
