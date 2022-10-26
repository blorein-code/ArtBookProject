//
//  ViewController.swift
//  SanatKitabi
//
//  Created by Berke Topcu on 23.10.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var selectedCreationName = [String]()
    var selectedCreationID = [UUID]()
    var selectedName = ""
    var selectedID : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        getData()
    
    }
    //view değiştikce çalışması için lifecycle methodu
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newData"), object: nil)
    }
    //delegate ve datasource fonksiyonları; kaç satır gözüksün ve satırlarda ne gözüksün işlemlerini gerçekleştirir.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedCreationName.count
    }
    //çekilen verilerin satırlarda gösterilmesi
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var content = cell.defaultContentConfiguration()
        content.text = selectedCreationName[indexPath.row]
        cell.contentConfiguration = content
        return cell
    }
    
//Ekleme butonu fonksiyonu, tıklandığında 2. view controller'a gider
    @objc func addButtonClicked() {
        selectedName = ""
        performSegue(withIdentifier: "toDetailVC", sender: nil)
    }
    
    //core data'dan veri çekmek için appdelegate ile iletişim kurulup veri çekiliyor
    @objc func getData() {
        selectedCreationName.removeAll(keepingCapacity: false)
        selectedCreationID.removeAll(keepingCapacity: false)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Creations")
        fetchRequest.returnsObjectsAsFaults = false
        do {
         let results = try context.fetch(fetchRequest)
            
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let paintName = result.value(forKey: "creationName") as? String {
                        self.selectedCreationName.append(paintName)
                    }
                    if let paintID = result.value(forKey: "id") as? UUID {
                        self.selectedCreationID.append(paintID)
                    }
                    self.tableView.reloadData()
                }
            }
            
        } catch {
            "Hata var"
        }
       
        
    }
    //bir satır seçildiğinde tekrar detail vc gitmek için segue işlemleri burada yapılıyor
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedName = selectedCreationName[indexPath.row]
        selectedID = selectedCreationID[indexPath.row]
        performSegue(withIdentifier: "toDetailVC", sender: nil)
        
        
    }
    //segue yapıldıgında hangi View Controller dosyası çağrılmalı ve ne yapılmalı
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailVC" {
            let destinationVC = segue.destination as! DetailViewController
            destinationVC.chosenName = selectedName
            destinationVC.chosenID = selectedID
            
        }
    }
    //silme işlemleri için commit methodu
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Creations")
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let id = result.value(forKey: "id") as? UUID {
                            
                            if id == selectedCreationID[indexPath.row] {
                                
                                context.delete(result)
                                selectedCreationName.remove(at: indexPath.row)
                                selectedCreationID.remove(at: indexPath.row)
                                
                                self.tableView.reloadData()
                                
                                do {
                                    try context.save()
                                } catch {
                                    print("hata var burda")
                                }
                                break
                            }
                        }
                    }
                }
            } catch {
                print("remove'da hata")
            }
        }
    }
    
}

