//
//  ViewController.swift
//  WeatherApp
//
//  Created by ahnzihyeon on 7/15/24.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    // 테이블 뷰에 넣을 데이터 소스.
    private var dataSource = [ForecastWeather]()
    
    // URL 쿼리에 넣을 아이템들
    // 서울역 위경도
    private let urlQueryItems: [URLQueryItem] = [
        URLQueryItem(name: "lat", value: "37.5"),
        URLQueryItem(name: "lon", value: "126.9"),
        URLQueryItem(name: "appid", value: "e5439cdce49e67d2b4272632937decbf"),
        URLQueryItem(name: "units", value: "metric")
    ]
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Seoul"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 30)
        return label
    }()
    private let tempLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 50)
        return label
    }()
    private let tempMinLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()
    private let tempMaxLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()
    private let tempStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 20
        stackView.distribution = .fillEqually
        return stackView
    }()
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .black
        return imageView
    }()
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .black
        // delegate: "대리자. 대신 수행해주는 사람." tableView 의 여러가지 속성 세팅을 이 ViewController 에서 대신 세팅해주겠다.
        tableView.delegate = self
        // dataSource: 테이블 뷰에 넣을 데이터를 이 ViewController 에서 세팅해주겠다.
        tableView.dataSource = self
        // 테이블 뷰에 테이블 뷰 셀 등록.
        tableView.register(TableViewCell.self, forCellReuseIdentifier: TableViewCell.id)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchCurrentWeatherData()
        fetchForecastData()
    }
    
    
    //서버 데이터를 불러오는 메서드
    //currentData와 forecast API를 2개 사용하기 때문에 공통으로 사용하기 위해서 T를 사용해 재활용이 가능하게 하기 위한 코드
    private func fetchData<T: Decodable>(url: URL,completion: @escaping (T?) -> Void) {
        let session = URLSession(configuration: .default)
        session.dataTask(with: URLRequest(url: url)) { data, response, error in
            guard let data = data, error == nil else {
                print("데이터 로드 실패")
                completion(nil) //오류가 있거나 데이터가 없으면 nil
                return
            }
            //http status code 성공범위
            let successRange = 200..<300
            //응답이 HTTPURLResponse 타입이고 상태 코드가 성공 범위 내에 있는지 확인
            if let response = response as? HTTPURLResponse, successRange.contains(response.statusCode) {
                guard let decodedData = try? JSONDecoder().decode(T.self, from: data) else {
                    print("JSON 디코딩 실패")
                    completion(nil)
                    return
                }
                completion(decodedData)
            } else {
                print("응답 오류")
                completion(nil)
            }
        }.resume()
    }
    
    
    // 서버에서 현재 날씨 데이터를 불러오는 메서드
    private func fetchCurrentWeatherData() {
        var urlComponents = URLComponents(string: "https://api.openweathermap.org/data/2.5/weather")
        urlComponents?.queryItems = self.urlQueryItems
        
        guard let url = urlComponents?.url else {
            print("잘못된 URL")
            return
        }
        
        fetchData(url: url) { [weak self] (result: CurrentWeatherResult?) in
            guard let self, let result else { return }
            // tempLabel에 값을 넣어줘야하는 UI 작업은 메인 쓰레드에서 작업
            DispatchQueue.main.async {
                self.tempLabel.text = "\(Int(result.main.temp))°C"
                self.tempMinLabel.text = "최소: \(Int(result.main.temp_min))°C"
                self.tempMaxLabel.text = "최고: \(Int(result.main.temp_max))°C"
            }
            guard let imageUrl = URL(string: "https://openweathermap.org/img/wn/\(result.weather[0].icon)@2x.png") else { return }
            
            // image 를 로드하는 작업은 백그라운드 쓰레드 작업
            if let data = try? Data(contentsOf: imageUrl) {
                if let image = UIImage(data: data) {
                    // 이미지뷰에 이미지를 그리는 작업은 UI 작업이기 때문에 다시 메인 쓰레드에서 작업.
                    DispatchQueue.main.async {
                        self.imageView.image = image
                    }
                }
            }
        }
    }
    
    
    // 서버에서 5일 간 날씨 예보 데이터를 불러오는 메서드
    private func fetchForecastData() {
        var urlComponents = URLComponents(string: "https://api.openweathermap.org/data/2.5/forecast")
        urlComponents?.queryItems = self.urlQueryItems
        
        guard let url = urlComponents?.url else {
            print("잘못된 URL")
            return
        }
        
        fetchData(url: url) { [weak self] (result: ForecastWeatherResult?) in
            guard let self, let result else { return }
            
            // result 콘솔에 찍어보기
            for forecastWeather in result.list {
                print("\(forecastWeather.main)\n\(forecastWeather.dtTxt)\n\n")
            }
            
            // UI 작업은 메인 쓰레드에서
            DispatchQueue.main.async {
                self.dataSource = result.list
                self.tableView.reloadData()  //데이터를 넣었으면 반드시 reloadData해야한다.
            }
        }
    }
    
    private func configureUI(){
        view.backgroundColor = .black
        
        [
            titleLabel,
            tempLabel,
            tempStackView,
            imageView,
            tableView
        ].forEach{view.addSubview($0)}
        
        [
            tempMaxLabel,
            tempMinLabel
        ].forEach{tempStackView.addArrangedSubview($0)} //stackView에 추가할 때는 addArrangedSubview
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(120)
        }
        
        tempLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
        }
        
        tempStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(tempLabel.snp.bottom).offset(10)
        }
        
        imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(160)
            $0.top.equalTo(tempStackView.snp.bottom).offset(20)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(50)
        }
    }
    
}

extension ViewController: UITableViewDelegate {
    // 테이블 뷰 셀의 높이 크기 지정.
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        40
    }
}

extension ViewController: UITableViewDataSource {
    // 테이블 뷰의 indexPath 마다 테이블 셀 지정.
    // indexPath = 테이블 뷰의 행과 섹션을 지정. 여기서 섹션은 사용하지 않고 행만 사용함.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.id) as? TableViewCell else { return UITableViewCell() }
        cell.configureCell(forecastWeather: dataSource[indexPath.row])
        return cell
    }
    // 테이블 뷰 섹션에 행이 몇 개 들어가는가. 여기서 섹션은 없으니 그냥 총 행 개수를 입력하면 된다.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }
}
