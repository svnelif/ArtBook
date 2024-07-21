//
//  DetailsVC.swift
//  ArtBookProject
//
//  Created by Elif Ataseven  on 16.07.2024.
//

import UIKit
import CoreData

class DetailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var chosenPainting = ""
    var chosenPaintingId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenPainting != ""{
            
            saveButton.isHidden = true
            
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let context = appDelegate?.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            let idString = chosenPaintingId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!) // id'si idString'e eşit olan veriyi buluyor.
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context!.fetch(fetchRequest)
                
                if results.count > 0 {
                    for result in results as! [NSManagedObject]{
                        if let name = result.value(forKey: "name") as? String{
                            nameText.text = name
                        }
                        if let artist = result.value(forKey: "artist") as? String{
                            artistText.text = artist
                        }
                        if let year = result.value(forKey: "year") as? Int{
                            yearText.text = String(year)
                        }
                        if let imageData = result.value(forKey: "image") as? Data{
                            let imagee = UIImage(data: imageData)
                            imageView.image = imagee
                        }
                            
                    }
                }
            }catch{
                print("Error!")
            }
            
        }else{
            saveButton.isHidden = false
            saveButton.isEnabled = false
            
            nameText.text = ""
            yearText.text = ""
            artistText.text = ""
        }
        
        // Recognizers
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
        
    }

    @objc func selectImage(){
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true)
        
        saveButton.isEnabled = true
        
    }
    
    @objc func hideKeyboard (){
        view.endEditing(true) //Bu view içinde yapılan değişiklikleri bitiriyor.
    }
    
    @IBAction func saveClicked(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        //Attributes
        newPainting.setValue(nameText.text, forKey: "name")
        newPainting.setValue(artistText.text , forKey: "artist")
        
        if let year = Int(yearText.text!){
            newPainting.setValue(year, forKey: "year")
        }
        newPainting.setValue(UUID(), forKey: "id")
        let data = imageView.image?.jpegData(compressionQuality: 0.5)
        newPainting.setValue(data, forKey: "image")
        
        do{
            try context.save()
            print("Success")
        }catch{
            print("Error!")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
    }
}
