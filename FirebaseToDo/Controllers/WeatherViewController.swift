
//  ViewController.swift
//  Weather App
//
//  Created by Duxxless on 21.01.2022.
//

import UIKit


class WeatherViewController: UIViewController {
    
    var array = [String]()
    
    let defaultColor = UIColor(named: "DarkWhite")
    let backgroundImageView = UIImageView()
    let wheatherIconImageView = UIImageView()
    let temperatureLabel = UILabel()
    let feelsLikeTemperatureLabel = UILabel()
    let cityLabel = UILabel()
    let searchCityButton = UIButton()
    let weatherWeek = UIButton()
    let locationButton = UIButton()
    let spiner = UIActivityIndicatorView()
    let networkWeatherManager = NetworkWeatherManager()
    let networkTranslate = NetworkTranslate()
    
    let userDefaults = UserDefaults()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        spiner.startAnimating()
        setStyle()
        setLayout()
    
        if let city = userDefaults.object(forKey: "city") as? String {
            print(city)
            networkWeatherManager.fetchCurrentWeather(forCity: city) {   currentWeather in
                self.updateInterfaceWith(weather: currentWeather)
                self.array = currentWeather.weatherDetail()
            }
        }
    }
}
// MARK: - Methods
extension WeatherViewController {
    
    func setStyle() {
        
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.image = UIImage(named: "Background")
        backgroundImageView.contentMode = .scaleAspectFill
        
        wheatherIconImageView.translatesAutoresizingMaskIntoConstraints = false
        wheatherIconImageView.image = UIImage(systemName: "nil")
        wheatherIconImageView.tintColor = defaultColor
        wheatherIconImageView.contentMode = .scaleAspectFill
        
        temperatureLabel.alpha = 0
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        
        feelsLikeTemperatureLabel.alpha = 0
        feelsLikeTemperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        feelsLikeTemperatureLabel.font = UIFont.systemFont(ofSize: 22)
        feelsLikeTemperatureLabel.text = ""
        feelsLikeTemperatureLabel.textAlignment = .center
        feelsLikeTemperatureLabel.textColor = defaultColor
        
        searchCityButton.pulsate()
        searchCityButton.translatesAutoresizingMaskIntoConstraints = false
        let searchImage = UIImage(systemName: "magnifyingglass.circle.fill")
        searchCityButton.setBackgroundImage(searchImage, for: .normal)
        searchCityButton.tintColor = defaultColor
        searchCityButton.addTarget(self, action: #selector(presentAlert), for: .touchUpInside)
        
        weatherWeek.pulsate()
        weatherWeek.translatesAutoresizingMaskIntoConstraints = false
        let weatherWeekImage = UIImage(systemName: "line.3.horizontal.circle.fill")
        weatherWeek.setBackgroundImage(weatherWeekImage, for: .normal)
        weatherWeek.tintColor = defaultColor
        weatherWeek.addTarget(self, action: #selector(showDetail), for: .touchUpInside)
        
        cityLabel.translatesAutoresizingMaskIntoConstraints = false
        cityLabel.textAlignment = .right
        cityLabel.text = ""
        if let cityCapitalized = cityLabel.text?.capitalized {
            cityLabel.text = cityCapitalized
        } else { return }
        cityLabel.font = UIFont.systemFont(ofSize: 34)
        cityLabel.textColor = defaultColor
        
        locationButton.pulsate()
        locationButton.translatesAutoresizingMaskIntoConstraints = false
        let locationImage = UIImage(systemName: "location.circle.fill")
        locationButton.setBackgroundImage(locationImage, for: .normal)
        locationButton.tintColor = defaultColor
        locationButton.addTarget(self, action: #selector(findPosition), for: .touchUpInside)
        
        
        spiner.translatesAutoresizingMaskIntoConstraints = false
        spiner.style = .large
        spiner.color = defaultColor
        spiner.hidesWhenStopped = true
        spiner.startAnimating()
        
    }
    
    func makeTemperatureText(temperature: String) -> NSAttributedString {
        let boldAttributes: [NSAttributedString.Key : Any] = [
            .strokeColor: defaultColor,
            .foregroundColor : defaultColor,
            .font : UIFont.boldSystemFont(ofSize: 80)
        ]
        
        let celciusAttributes: [NSAttributedString.Key : Any] = [
            .font : UIFont.systemFont(ofSize: 60),
            .foregroundColor : defaultColor
        ]
        
        // let attributedString = NSAttributedString(string: temperature, attributes: boldAttributes)
        let attributedString = NSMutableAttributedString(string: temperature, attributes: boldAttributes)
        attributedString.append(NSAttributedString(string: "℃", attributes: celciusAttributes))
        return attributedString
    }

    // MARK: - Methods
    @objc func presentAlert() {
        
        searchCityButton.pulsate()
        presentSearchAlertController(tittle: "Введите название города", message: nil, style: .alert) { city in
            DispatchQueue.main.async {
                self.spiner.startAnimating()
            }
            //UserDefaults
            self.userDefaults.set(city, forKey: "city")
            self.networkWeatherManager.fetchCurrentWeather(forCity: city) { currentWeather in
                self.updateInterfaceWith(weather: currentWeather)
                self.array = currentWeather.weatherDetail()
            }
            self.networkWeatherManager.boolComplition = { error in
                if error == false {
                    self.errorAlertController()
                    DispatchQueue.main.async {
                        self.spiner.stopAnimating()
                    }
                }
            }
        }
    }
    
    @objc func showDetail() {
        
        let secondVC = SecondViewController()
        secondVC.detail = array
        self.navigationController?.pushViewController(secondVC, animated: true)
    }
    
    @objc func findPosition() {
        locationButton.pulsate()
        locationButton.opacityAnimation()
        //locationButton.shake()
    }
    
    func showAnimation() {
        
        self.wheatherIconImageView.pulsateImage()
        dispatch(object: temperatureLabel, time: 0.3, duration: 0.3)
        dispatch(object: feelsLikeTemperatureLabel, time: 0.5, duration: 0.5)
    }
    
    func updateInterfaceWith(weather: CurrentWeather) {

        self.temperatureLabel.alpha = 0
        self.wheatherIconImageView.alpha = 0
        self.feelsLikeTemperatureLabel.alpha = 0
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0) {
            self.wheatherIconImageView.pulsateImage()
            self.wheatherIconImageView.image = UIImage(systemName: weather.systemIconWheatherString)
            self.spiner.stopAnimating()
        }
        
        dispatch(object: self.temperatureLabel, time: 0.4, duration: 1)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.temperatureLabel.attributedText = self.makeTemperatureText(temperature: weather.temperatureString)
        }
        
        
        DispatchQueue.main.async {
            self.cityLabel.text = weather.cityName
            
        }
        
        dispatch(object: self.feelsLikeTemperatureLabel, time: 0.7, duration: 1)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0) {
            self.feelsLikeTemperatureLabel.text = "Ощущается как \(weather.feelsLikeTemperatureString)º"
        }
    }
}

private func dispatch(object: UILabel, time: Double, duration: Double) {
    
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time) {
        object.opacityAnimation(myDuration: duration)
    }
}

