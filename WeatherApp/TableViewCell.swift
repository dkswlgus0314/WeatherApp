import UIKit

final class TableViewCell: UITableViewCell {
    
    static let id = "TableViewCell"
    
    private let dtTxtlabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .black
        label.textColor = .white
        return label
    }()
    
    private let templabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .black
        label.textColor = .white
        return label
    }()
    
    // TableView 의 style 과 id 로 초기화할때 사용하는 코드.
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    private func configureUI() {
        contentView.backgroundColor = .black
        [
            dtTxtlabel,
            templabel
        ].forEach { contentView.addSubview($0) }
        dtTxtlabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
        templabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
    }
    
    public func configureCell(forecastWeather: ForecastWeather) {
        dtTxtlabel.text = forecastWeather.dtTxt
        templabel.text = "\(forecastWeather.main.temp)°C"
    }
    
    // 인터페이스 빌더를 통해 셀을 초기화 할 때 사용하는 코드. 여기서는 fatalError 를 통해 명시적으로 인터페이스 빌더로 초기화 하지 않음을 나타냄.
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
