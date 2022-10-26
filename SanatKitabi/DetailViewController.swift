//
//  DetailViewController.swift
//  SanatKitabi
//
//  Created by Berke Topcu on 23.10.2022.
//

import UIKit
import CoreData

class DetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var creationName: UITextField!
    @IBOutlet weak var creatorName: UITextField!
    @IBOutlet weak var createdDate: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    var chosenName = ""
    var chosenID : UUID?
    override func viewDidLoad() {
        super.viewDidLoad()
        if chosenName != "" {
            saveButton.isHidden = true
            if let uuidString = chosenID?.uuidString {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Creations")
                fetchRequest.returnsObjectsAsFaults = false
                fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
                do {
                    let results = try context.fetch(fetchRequest)
                    if results.count > 0 {
                        for result in results as! [NSManagedObject] {
                            if let name = result.value(forKey: "creationName") as? String {
                                creationName.text = name
                            }
                            if let artist = result.value(forKey: "creatorName") as? String {
                                creatorName.text = artist
                            }
                            if let year = result.value(forKey: "createdDate") as? Int {
                                createdDate.text = String(year)
                            }
                            if let imageData = result.value(forKey: "creationImage") as? Data {
                                let image = UIImage(data: imageData)
                                imageView.image = image
                            }

                            
                        }
                    }
                        
                } catch {
                    print("Hata gibi bişi")
                }
            }
        } else {
            saveButton.isHidden = false
            saveButton.isEnabled = false
        } // else durumunda zaten gelen veri boşsa artı butonuna bastığımızda göreceğimiz view ile aynı view gözükecektir
        var gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        var imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageView.addGestureRecognizer(imageGestureRecognizer)
        // Do any additional setup after loading the view.
        
    
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        print("tiklandi")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
      
        let newCreation = NSEntityDescription.insertNewObject(forEntityName: "Creations", into: context)
            print("new creation olustu")
        newCreation.setValue(creationName.text!, forKey: "creationName")
        newCreation.setValue(creatorName.text!, forKey: "creatorName")
        if let date = Int(createdDate.text!) {
            newCreation.setValue(date, forKey: "createdDate")
        }
        newCreation.setValue(UUID(), forKey: "id")
        let data = imageView.image?.jpegData(compressionQuality: 0.5)
        newCreation.setValue(data, forKey: "creationImage")
        print("do try catch e giriyoz")
        do {
            try context.save()
            print("Success")
        } catch {
            print("hata var")
        }
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
    }
    //photo library'e ulaşıp resim seçmek için gerekli işlemler
    @objc func imageTapped() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.editedImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    
    //klavyeyi kapatmak için
    
    @objc func closeKeyboard() {
        view.endEditing(true)
    }

}
