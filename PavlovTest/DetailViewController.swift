
//  DetailViewController.swift
//  PavlovTest
//
//  Created by Pavlov Matthew on 24.02.2021.
//

import UIKit

class DetailViewController: UITableViewController {
    
    static var share: Share?
    
    //организую вид Detail VC
    
    var titleString = [0: "Информация", 1: "Финансовые показатели", 2: "Оценка стоимости", 3: "Дивиденды", 4: "Торговля"]
    var rowString = [0: ["Тикер", "Биржа", "Местная валюта"], 1: ["Market Cap"], 2: ["P/E", "Рост EPS"], 3: ["Дата", "Див. доходность"], 4: ["Цена открытия", "Цена закрытия", "52 w High", "52 w Low", "Дневной объем торгов", "Месячный объем торгов"]]
    var rowInfo = [0: ["", "", ""], 1:["Стоимость компании"], 2: ["Цена акции/прибыль", "Средний рост за 5 лет"], 3: ["", "Годовая"], 4: ["", "", "", "", "Средний за 10 дней", "Средний за 3 месяца"]]

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.topItem?.backButtonTitle = "Назад"
        
        title = DetailViewController.share?.longName ?? DetailViewController.share?.symbol
        navigationItem.largeTitleDisplayMode = .never
        
        self.tabBarController?.tabBar.isHidden = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addToFavorites))
        
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titleString[section]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (rowString[section]?.count)!
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CellTwo", for: indexPath) as? DetailShareCell
        else {
            fatalError("Невозможно организовать вид!")
        }
        
        //блок вставки данных, в пустых клетках пишу if тк потом руками раскрываю опционалы данных
        var stats = [0: [DetailViewController.share?.symbol,
                         DetailViewController.share?.fullExchangeName,
                         DetailViewController.share?.financialCurrency],
                     1: ["if"],
                     2: ["if",
                         "if"],
                     3: ["\(DetailViewController.share?.dividendDate?.date.dropLast(16) ?? "Нет данных")",
                         "if"],
                     4: ["if",
                         "if",
                         "if",
                         "if",
                         "if",
                         "if"]]

        if DetailViewController.share?.marketCap == nil {
            stats[1]?[0] = "Нет данных"
        } else {
            stats[1]?[0] = "\(((DetailViewController.share?.marketCap)!)/1000000000) млрд. $"
        }

        if DetailViewController.share?.trailingPE == nil {
            stats[2]?[0] = "Нет данных"
        } else {
            stats[2]?[0] = "\(formatNumber((DetailViewController.share?.trailingPE)!)!)"
        }

        if DetailViewController.share?.epsForward == nil {
            stats[2]?[1] = "Нет данных"
        } else {
            stats[2]?[1] = "\((DetailViewController.share?.epsForward)!) %"
        }

        if DetailViewController.share?.trailingAnnualDividendYield == nil {
            stats[3]?[1] = "Нет данных"
        } else {
            stats[3]?[1] = "\(formatNumber(((DetailViewController.share?.trailingAnnualDividendYield)!)*100)!) %"
        }

        if DetailViewController.share?.regularMarketOpen == nil {
            stats[4]?[0] = "Нет данных"
        } else {
            stats[4]?[0] = "\((DetailViewController.share?.regularMarketOpen)!) $"
        }

        if DetailViewController.share?.regularMarketPreviousClose == nil {
            stats[4]?[1] = "Нет данных"
        } else {
            stats[4]?[1] = "\((DetailViewController.share?.regularMarketPreviousClose)!) $"
        }

        if DetailViewController.share?.fiftyTwoWeekHigh == nil {
            stats[4]?[2] = "Нет данных"
        } else {
            stats[4]?[2] = "\((DetailViewController.share?.fiftyTwoWeekHigh)!) $"
        }

        if DetailViewController.share?.fiftyTwoWeekLow == nil {
            stats[4]?[3] = "Нет данных"
        } else {
            stats[4]?[3] = "\((DetailViewController.share?.fiftyTwoWeekLow)!) $"
        }

        if DetailViewController.share?.averageDailyVolume10Day == nil {
            stats[4]?[4] = "Нет данных"
        } else {
            stats[4]?[4] = "\(((DetailViewController.share?.averageDailyVolume10Day)!)/1000000) млн. $"
        }

        if DetailViewController.share?.averageDailyVolume3Month == nil {
            stats[4]?[5] = "Нет данных"
        } else {
            stats[4]?[5] = "\(((DetailViewController.share?.averageDailyVolume3Month)!)/1000000) млн. $"
        }

        cell.parameterName.text = rowString[indexPath.section]?[indexPath.row]
        cell.parameterInfo.text = rowInfo[indexPath.section]?[indexPath.row]
        cell.parameterStats.text = stats[indexPath.section]?[indexPath.row]
        
        return cell
    }
    
    //аналогичная функция для обрезки и округления чисел
    func formatNumber (_ number: Double) -> String? {

        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2

        let formattedNumberString = formatter.string(from: NSNumber(value: number))
        return formattedNumberString?.replacingOccurrences(of: ".00", with: "")

    }
    
    //функция связывания значка добавить в избранные и метода в Main VC
    @objc func addToFavorites() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "disconnectPaxiSockets"), object: nil)
    }
    
}
