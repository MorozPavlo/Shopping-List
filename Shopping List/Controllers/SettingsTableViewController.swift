//
//  SettingsTableViewController.swift
//  Shopping List
//
//  Created by Pavel Moroz on 22.04.2020.
//  Copyright © 2020 Pavel Moroz. All rights reserved.
//

import UIKit
import StoreKit

protocol SetupButtonDelegate: AnyObject {
    func sutupButton()
}

class SettingsTableViewController: UITableViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var swicherCounts: UISwitch!
    @IBOutlet weak var addButtonSwitch: UISwitch!
    @IBOutlet weak var сurrentСurrency: UIButton!
    @IBOutlet weak var currentView: UIView!
    @IBOutlet weak var currentViewCell: UITableViewCell!
    
    
    private let appIconServise = AppIconServise()
    private let defaults = UserDefaults.standard
    
    private let currency = ["₴","₽","$","¥","£","€","₣","₤"]
    
    
    private var imageSetNames: [String] = ["shopping4@3x.png", "shopping0@3x.png","shopping1@3x.png","shopping2@3x.png","shopping3@3x.png"]
    private var imageNames: [String] = [NSLocalizedString("SlavaUkraine", comment: ""),
                                        NSLocalizedString("Main", comment: ""),
                                        NSLocalizedString("BlueBreeze", comment: ""),
                                        NSLocalizedString("Unusual", comment: ""),
                                        NSLocalizedString("Simplicity", comment: "")]
    
    var delegate: SetupButtonDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.dismiss(animated:true, completion: nil)
    }
    
    // MARK: UIPicker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currency.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currency[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        saveCurrency(currency[row])
        
    }
    
    
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "iconCell", for: indexPath) as! IconsCollectionViewCell
        
        
        let image = UIImage(named: imageSetNames[indexPath.row], in: Bundle.main, compatibleWith: nil)
        cell.iconImage.image = image
        cell.iconsName.text = imageNames[indexPath.row]
        cell.iconImage.layer.cornerRadius = 16
        cell.iconImage.clipsToBounds = true
        
        return cell
    }
    
    // MARK: Change Icon
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            appIconServise.changeAppIcon(to: .primaryAppIcon)
        case 1:
            appIconServise.changeAppIcon(to: .shopping1)
        case 2:
            appIconServise.changeAppIcon(to: .shopping2)
        case 3:
            appIconServise.changeAppIcon(to: .shopping3)
        default:
            appIconServise.changeAppIcon(to: .primaryAppIcon)
        }
        
        let alert = UIAlertController(title: NSLocalizedString("ChangedApplicationIcon", comment: ""), message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    
    // MARK: Swich Counts
    @IBAction func switchCountsAction(_ sender: UISwitch) {
        
        if sender.isOn {
            defaults.set(true, forKey: "costAccounting")
        } else {
            defaults.set(false, forKey: "costAccounting")
        }
        hideCurrencyCell()
    }
    
    @IBAction func switchButtonAction(_ sender: UISwitch) {
        
        if sender.isOn {
            defaults.set(true, forKey: "addButton")
        } else {
            defaults.set(false, forKey: "addButton")
        }
        delegate?.sutupButton()
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let costAccounting = defaults.bool(forKey: "costAccounting")
        if section == 0 {
            switch costAccounting {
            case true:
                return 2
            default:
                return 1
            }
        }
        if section == 1 {
            return 1
        }
        return 1
    }
    
    // MARK: UIPicker add to View
    
    @IBAction func chooseCurrency(_ sender: Any) {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 250,height: 150)
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 250, height: 150))
        pickerView.delegate = self
        pickerView.dataSource = self
        //выбранный элемент
        var index = 0
        let setCurrency = defaults.string(forKey: "currency")
        let myCurrency = setCurrency ?? NSLocalizedString("CurrentCurrency", comment: "")
        for i in currency {
            if myCurrency == i {
                break
            }
            index += 1
        }
        //выбранный элемент конец
        pickerView.selectRow(index, inComponent: 0, animated: true)
        vc.view.addSubview(pickerView)
        let editRadiusAlert = UIAlertController(title: NSLocalizedString("CurrencyChoose", comment: ""), message: "", preferredStyle: UIAlertController.Style.alert)
        editRadiusAlert.setValue(vc, forKey: "contentViewController")
        editRadiusAlert.addAction(UIAlertAction(title: NSLocalizedString("Save", comment: ""), style: .default, handler: { action in
            self.successfully()
        }))
        //editRadiusAlert.addAction(UIAlertAction(title: "Закрыть", style: .destructive, handler: nil))
        self.present(editRadiusAlert, animated: true)
    }
    
    // MARK: Alert
    
    private func successfully() {
        let alert = UIAlertController(title: NSLocalizedString("Successfully", comment: ""), message: NSLocalizedString("CurrencyChooseSuccessfully", comment: ""), preferredStyle: .alert)
        let alertAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default)
        alert.addAction(alertAction)
        present(alert, animated: true)
    }
    
    // MARK: Settings for Currency
    
    private func saveCurrency(_ currency:String) {
        defaults.set(currency, forKey: "currency")
        сurrentСurrency.setTitle(defaults.string(forKey: "currency"), for: .normal)
    }
    
    
    private func hideCurrencyCell() {
        let costAccounting = defaults.bool(forKey: "costAccounting")
        
        if costAccounting {
            currentViewCell.isHidden = false
            currentViewCell.frame.size.height = 60
            currentView.isHidden = false
            currentView.frame.size.height = 60
            
        } else {
            currentViewCell.isHidden = true
            currentViewCell.frame.size.height = 0
            currentView.isHidden = true
            currentView.frame.size.height = 0
        }
        tableView.reloadData()
    }
    
    private func updateUI() {
        self.title = NSLocalizedString("Settings", comment: "")
        collectionView.delegate = self
        collectionView.dataSource = self
        swicherCounts.isOn = defaults.bool(forKey: "costAccounting")
        addButtonSwitch.isOn = defaults.bool(forKey: "addButton")
        let currency = defaults.string(forKey: "currency") ?? NSLocalizedString("CurrentCurrency", comment: "")
        сurrentСurrency.setTitle(currency, for: .normal)
        hideCurrencyCell()
    }
    
    @IBAction func rateAction(_ sender: Any) {
        
        rateApp(id: "1512179736")
    }
    
    func rateApp(id : String) {
        guard let url = URL(string : "itms-apps://itunes.apple.com/app/id\(id)?mt=8&action=write-review") else { return }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}
