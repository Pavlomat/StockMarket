//
//  ViewController.swift
//  PavlovTest
//
//  Created by Pavlov Matthew on 16.02.2021.
//

import UIKit
import Network

class ViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating {
    
    var shares = [Share]()
    var filtered = [Share]()
    var favorites = [Share]()
    
    let monitor = NWPathMonitor()
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //выполнение функции для подключения строки поиска начального экрана
        filterResults()
        
        configureSearchController()
        
        checkNetwork()
        
        self.navigationItem.title = "Акции"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // тк апи взяты с бесплатного сайта то есть ограничение на 100 запросов в месяц, на api pavlov осталось 60 запросов.
        
        // Время включения апи с mboum - 12:00 по Москве, при первом включении программы после установки до 12:00 нет данных, далее данные подгружаются, обновляются и сохраняются, чтобы при следующем включении до 12:00 появлялись последние данные за прошлый рабочий день.
        
        //api pavlov : https://mboum.com/api/v1/qu/quote/?symbol=AAPL,F,TSLA,LKOH,YNDX,BABA,MRNA,QIWI,GOLD,PLTR,BA,FB,AMD,V,ZM,FDX,SQ,SEDG,XOM,ROKU,BBBY,LRN,CNK,MU,BYND,AMAT,CCL,ALRS&apikey=pNDx1z6NL2s3xebLHhcV3tYWQnqlrs4GM3TeUq2pFZsb4ohRjI14cTs2uHru&format=json
        
        
        let urlString = "https://mboum.com/api/v1/qu/quote/?symbol=AAPL,F,TSLA,LKOH,YNDX,BABA,MRNA,QIWI,GOLD,PLTR,BA,FB,AMD,V,ZM,FDX,SQ,SEDG,XOM,ROKU,BBBY,LRN,CNK,MU,BYND,AMAT,CCL,ALRS&apikey=pNDx1z6NL2s3xebLHhcV3tYWQnqlrs4GM3TeUq2pFZsb4ohRjI14cTs2uHru&format=json"
        
        //загрузка api из интернета по urlString
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let url = URL(string: urlString) {
                if let data = try? Data(contentsOf: url) {
                    self?.parse(json: data)
                    return
                }
            }
        }

        //загрузка сохраненных данных для доступа без интернета
        let defaults = UserDefaults.standard
        
        if let savedShares = defaults.object(forKey: "shares") as? Data {
            let jsonDecoder = JSONDecoder()
            do {
                shares = try jsonDecoder.decode([Share].self, from: savedShares)
            } catch {
                print("Не удалось загрузить данные")
            }
        }
        if let savedFavorites = defaults.object(forKey: "favorites") as? Data {
            let jsonDecoder = JSONDecoder()
            do {
                favorites = try jsonDecoder.decode([Share].self, from: savedFavorites)
            } catch {
                print("Не удалось загрузить данные")
            }
        }
                
        //соединение знака "добавить в избранные" из DetailVC с этим VC
        NotificationCenter.default.addObserver(self, selector: #selector(addFavorites(_:)), name: Notification.Name(rawValue: "addFavorites"), object: nil)
    }
    
    //организация строки поиска акций
    func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Найти акции"
        navigationItem.searchController = searchController
        self.definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
    
    
    //тк не создаю дополнительный VC то получаю доступ к копии основного VC по тэгу (объявление в SceneDelegate)
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tabBarController?.selectedIndex == 0 {
            return filtered.count
        } else {
            return filtered.count
        }
    }
    
    //организация VC и присвоение данных лейблам
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? ShareCell
        else {
            fatalError("Невозможно организовать вид!")
        }
        if tabBarController?.selectedIndex == 0 {
            let share = filtered[indexPath.row]
            cell.longName.text = share.longName
            cell.symbol.text = share.symbol
            cell.price.text = formatNumber(share.regularMarketPrice!) //formatNumber() функция для округления данных с апи
            
            if share.regularMarketChange! >= 0 {
                cell.dayChange.textColor = UIColor(red: 0, green: 0.7, blue: 0, alpha: 1)
            } else {
                cell.dayChange.textColor = UIColor(red: 0.7, green: 0, blue: 0, alpha: 1)
            }
            cell.dayChange.text = formatNumber(share.regularMarketChange!)
            
            if share.regularMarketChangePercent! >= 0 {
                cell.dayPercentage.textColor = UIColor(red: 0, green: 0.7, blue: 0, alpha: 1)
            } else {
                cell.dayPercentage.textColor = UIColor(red: 0.7, green: 0, blue: 0, alpha: 1)
            }
            cell.dayPercentage.text = formatNumber(share.regularMarketChangePercent!)! + "%"
        } else {
            //пишу filterResults() чтобы при добавлении акции в избранные она сразу там отображалась, НО при первом входе в приложение после установки при добавлении акции в избранные для отображения ее в избранном надо нажать на строку поиска во вкладке "избранные" и отпустить ее, после этого акции будут появляться автоматически даже после выключения приложения. Не допер, как пофиксить
            filterResults()
            let share = filtered[indexPath.row]
            cell.longName.text = share.longName
            cell.symbol.text = share.symbol
            cell.price.text = formatNumber(share.regularMarketPrice!)
            
            if share.regularMarketChange! >= 0 {
                cell.dayChange.textColor = UIColor(red: 0, green: 0.7, blue: 0, alpha: 1)
            } else {
                cell.dayChange.textColor = UIColor(red: 0.7, green: 0, blue: 0, alpha: 1)
            }
            cell.dayChange.text = formatNumber(share.regularMarketChange!)
            
            if share.regularMarketChangePercent! >= 0 {
                cell.dayPercentage.textColor = UIColor(red: 0, green: 0.7, blue: 0, alpha: 1)
            } else {
                cell.dayPercentage.textColor = UIColor(red: 0.7, green: 0, blue: 0, alpha: 1)
            }
            cell.dayPercentage.text = formatNumber(share.regularMarketChangePercent!)! + "%"
        }
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            if tabBarController?.selectedIndex == 0 {
                DetailViewController.share = filtered[indexPath.row]
                navigationController?.pushViewController(vc, animated: true)
                tableView.deselectRow(at: indexPath, animated: true)
            } else {
                DetailViewController.share = filtered[indexPath.row]
                navigationController?.pushViewController(vc, animated: true)
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
    
    //парсим для загрузки апи джейсона и сохраняем полученные данные
    func parse(json: Data) {
        let decoder = JSONDecoder()
        if let jsonShares = try? decoder.decode([Share].self, from: json) {
            shares = jsonShares
            save()
            performSelector(inBackground: #selector(filterResults), with: nil)
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
    
    //функция для сохранения данных и изменений в списке озбранных
    func save() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(shares) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "shares")
        } else {
            print("Не удалось сохранить данные")
        }
        if let savedFavorites = try? jsonEncoder.encode(favorites) {
            let defaults = UserDefaults.standard
            defaults.setValue(savedFavorites, forKey: "favorites")
        } else {
            print("Не удалось сохранить данные")
        }
    }
    
    //функция для округления числовых данных
    func formatNumber (_ number: Double) -> String? {
        
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        
        let formattedNumberString = formatter.string(from: NSNumber(value: number))
        return formattedNumberString?.replacingOccurrences(of: ".00", with: "")
        
    }

    //функция для добавления и удаления (при повторном нажатии на кнопку) акции в избранные с Detail VC
    @objc func addFavorites(_ notification: Notification) {
        if favorites.contains(DetailViewController.share!) {
            if let index = favorites.firstIndex(of: DetailViewController.share!) {
                favorites.remove(at: index)
                tableView.reloadData()
                save()
            }
        } else {
            favorites.append(DetailViewController.share!)
            tableView.reloadData()
            save()
        }
    }
    
    //функция для поиска акций по тикеру или названию
    @objc func filterResults() {
        DispatchQueue.main.async { [weak self] in
            if self?.navigationController?.tabBarItem.tag == 0 {
                
                DispatchQueue.main.async { [weak self] in
                    guard let searchBarText = self?.searchController.searchBar.text?.lowercased() else { return }
                    if searchBarText.isEmpty {
                        self?.filtered = self!.shares
                    } else {
                        self?.filtered = self!.shares.filter() { share in
                            if let _ = share.longName!.range(of: searchBarText, options: .caseInsensitive) {
                                return true
                            }
                            if let _ =  share.symbol.range(of: searchBarText, options: .caseInsensitive) {
                                return true
                            }
                            return false
                        }
                    }
                }
                DispatchQueue.main.async { [weak self] in
                    self?.tableView.reloadData()
                }
            } else {
                DispatchQueue.main.async { [weak self] in
                    guard let searchBarText = self?.searchController.searchBar.text?.lowercased() else { return }

                    if searchBarText.isEmpty {
                        self?.filtered = self!.favorites
                    } else {
                        self?.filtered = self!.favorites.filter() { share in
                            if let _ = share.longName!.range(of: searchBarText, options: .caseInsensitive) {
                                return true
                            }
                            if let _ =  share.symbol.range(of: searchBarText, options: .caseInsensitive) {
                                return true
                            }
                            return false
                        }
                    }
                }
                DispatchQueue.main.async { [weak self] in
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    //необходимые для поиска функции
    func updateSearchResults(for searchController: UISearchController) {
        filterResults()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterResults()
    }
    
    //функция, чтобы вывести сообщение о потере связи с интернетом
    func checkNetwork() {
        monitor.pathUpdateHandler = { [self] path in
            if path.status != .satisfied {
                DispatchQueue.main.async { [weak self] in
                    let ac = UIAlertController(title: "Внимание", message: "Нет доступа к интернету, oтображение последних загруженных данных.", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self?.present(ac, animated: true)
                }
            }
        }
        
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
}

