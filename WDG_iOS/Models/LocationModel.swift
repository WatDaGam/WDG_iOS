//
//  LocationModel.swift
//  WDG_iOS
//
//  Created by 정찬웅 on 11/7/23.
//

import Foundation
import CoreLocation

// CLLocationCoordinate2D를 위한 Hashable 래퍼 구조체 정의
struct LocationHash: Hashable {
    let latitude: Double
    let longitude: Double
    
    init(coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }
    
    static func == (leftHash: LocationHash, rightHash: LocationHash) -> Bool {
        return leftHash.latitude == rightHash.latitude && leftHash.longitude == rightHash.longitude
    }
}

// 위치 정보를 관리하고 업데이트를 처리할 클래스 정의
class LocationModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var refreshLocation: CLLocation?
    private var lastRequestedTime: Date? // 마지막으로 역지오코딩 요청한 시간을 저장
    private var geocodeRequestDelay: TimeInterval = 60 // 60초 간격으로 요청하도록 초기 설정
    var tokenModel: TokenModel
    var authModel: AuthModel
    var postModel: PostModel
    @Published var location: CLLocation?
    @Published var currentLocation: CLLocation?
    @Published var locationName: String = "위치 정보 없음"
    @Published var defaultLocation: CLLocation = CLLocation(latitude: 37.5666612, longitude: 126.9783785)
    private var updateInterval = 0
    private let geocoder = CLGeocoder()
    private var locationCache: [LocationHash: String] = [:] // 위치 이름 캐시
    init(tokenModel: TokenModel, authModel: AuthModel, postModel: PostModel) {
        self.tokenModel = tokenModel
        self.authModel = authModel
        self.postModel = postModel
        super.init() // 'super.init()' 호출은 모든 프로퍼티를 초기화한 후에 호출해야 합니다.
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization() // 사용 중 권한 요청
        self.locationManager.startUpdatingLocation() // 위치 업데이트 시작
    }
    private func checkLocationServicesAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            // The user has not yet made a choice regarding whether the app can use location services.
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            // The user has denied the use of location services for the app or they are restricted.
            // Set the default location here
            self.location = self.defaultLocation
            self.currentLocation = self.defaultLocation
            self.updateLocationName(with: self.defaultLocation)
        case .authorizedWhenInUse, .authorizedAlways:
            // The app is authorized to use location services.
            locationManager.startUpdatingLocation()
        default:
            // Handle any future cases
            break
        }
    }
    private func updateLocationName(with location: CLLocation) {
        // 캐시된 위치 이름을 확인합니다.
        let coordinateKey = LocationHash(coordinate: location.coordinate)
        if let cachedName = locationCache[coordinateKey] {
            self.locationName = cachedName
            return
        }
        // 마지막 요청 시간을 확인하여 요청 간격을 준수합니다.
        if let lastReq = lastRequestedTime, Date().timeIntervalSince(lastReq) < geocodeRequestDelay {
            return
        }
        // 새로운 요청 시간을 기록합니다.
        lastRequestedTime = Date()
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            // 요청 실패 시 백오프 시간 증가
            if let error = error {
                print(error)
                self.geocodeRequestDelay *= 2 // 다음 요청 전에 대기 시간을 두 배로 늘립니다.
                self.locationName = "위치 정보를 찾을 수 없음"
                return
            }
            // 성공적으로 위치 정보를 받았을 때 백오프 시간을 초기화합니다.
            self.geocodeRequestDelay = 60
            if let placemark = placemarks?.first {
                if let city = placemark.locality, let country = placemark.country {
                    self.locationName = "\(city), \(country)"
                } else {
                    self.locationName = placemark.name ?? "알 수 없는 위치"
                }
                // 캐시에 위치 이름을 저장합니다.
                self.locationCache[coordinateKey] = self.locationName
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 가장 최근의 위치 정보 가져오기
        guard let latestLocation = locations.last else { return }
        print("위치 정보 수신")
        self.location = latestLocation
        // 위치를 업데이트할 때마다 역지오코딩을 수행
        print("updateInterval:", self.updateInterval)
        if postModel.getPosts().isEmpty {
            Task {
                await tokenModel.validateToken(authModel: authModel)
                await postModel.getStoryList(accessToken: tokenModel.getToken("accessToken") ?? "", lati: self.location?.coordinate.latitude, longi: self.location?.coordinate.longitude)
            }
        }
        if self.updateInterval == 0 {
            updateLocation(latestLocation)
            Task {
                await tokenModel.validateToken(authModel: authModel)
                await postModel.getStoryList(accessToken: tokenModel.getToken("accessToken") ?? "", lati: self.location?.coordinate.latitude, longi: self.location?.coordinate.longitude)
            }
            self.updateInterval = 60
        }
        self.updateInterval -= 1
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error getting location: \(error)")
        if currentLocation != nil {
            // 에러가 발생하더라도 이전 위치 정보(currentLocation)가 있으면 그 정보를 계속 사용합니다.
            // 이 경우 새로운 위치 업데이트가 실패하더라도 사용자에게 영향을 주지 않습니다.
            // 위치명이 이미 설정되어 있으면, 업데이트를 재시도하지 않아도 됩니다.
            // 그렇지 않은 경우에만 위치명을 업데이트합니다.
            if locationName == "위치 정보 없음" || locationName == "위치 정보를 찾을 수 없음" {
                updateLocationName(with: currentLocation!)
            }
        } else {
            // 이전 위치 정보가 없다면 사용자에게 위치 정보를 얻을 수 없음을 알립니다.
            locationName = "위치 정보를 찾을 수 없음"
        }
    }
    func reverseGeocode() {
        guard let location = currentLocation else { return }
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            if let error = error {
                print(error)
                self.locationName = "위치 정보를 찾을 수 없음"
            } else if let placemark = placemarks?.first {
                // 상세 주소 정보를 얻습니다.
                //                print(placemark)
                let city = placemark.locality ?? "" // 도시
                let subLocality = placemark.subLocality ?? "" // 부속 지역 이름 (예: 동/읍/면)
                let thoroughfare = placemark.thoroughfare ?? "" // 길 이름
                let subThoroughfare = placemark.subThoroughfare ?? "" // 길 번호
                let country = placemark.country ?? "" // 국가
                // 선택적으로 주소 구성 요소를 조합하여 상세한 주소 문자열을 생성합니다.
                self.locationName = [subLocality, city, country]
                    .filter { !$0.isEmpty }
                    .prefix(2)
                    .joined(separator: ", ")
                print(self.locationName)
            }
        }
    }
    func updateLocation(_ location: CLLocation) {
        self.currentLocation = location
        // 위치를 업데이트할 때마다 역지오코딩을 수행
        reverseGeocode()
    }
}
