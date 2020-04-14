//
//  ViewController.swift
//  ContactList
//
//  Created by Andrew Solesa on 2020-04-14.
//  Copyright © 2020 KSG. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseAuth
import FirebaseDatabase

class ViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    
    var item: Contacts!
    
    var ref: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        ref = Database.database().reference()
        
        self.firstName.delegate = self
        self.lastName.delegate = self
        self.email.delegate = self
        self.phoneNumber.delegate = self
        
        if item != nil
        {
            self.imageView.load(url: URL(string: item.image!)!)
            self.firstName.text = item.firstName
            self.lastName.text = item.lastName
            self.email.text = item.email
            self.phoneNumber.text = item.phoneNumber
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        
        return true
    }
    
    func getPhotoWithCameraOrPhotoLibrary()
    {
        let c = UIImagePickerController()
        
        c.sourceType = UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
        
        c.delegate = self
        
        c.allowsEditing = false

        present(c, animated: true, completion: nil)
    }
    
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
     func uploadMedia(completion: @escaping (_ url: String?) -> Void)
     {
        let storageRef = Storage.storage().reference().child("\(randomString(length: 10)).png")
        if let uploadData = self.imageView.image?.jpegData(compressionQuality: 0.5) {
            storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                if error != nil {
                    print("error")
                    completion(nil)
                } else {

                    storageRef.downloadURL(completion: { (url, error) in

                        print(url?.absoluteString)
                        completion(url?.absoluteString)
                    })
                }
            }
        }
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem)
    {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func addPhoto(_ sender: UIButton)
    {
        self.getPhotoWithCameraOrPhotoLibrary()
    }
    
    @IBAction func save(_ sender: UIButton)
    {
        if self.firstName.text   != "" && self.lastName.text != ""
        && self.email.text!.isValidEmail && self.phoneNumber.text!.isValidPhone && self.imageView.image != nil
        {
            uploadMedia()
            { url in
                guard let url = url else { return }
                
                let post:[String : Any] = [
                    "firstName": self.firstName.text!,
                    "lastName": self.lastName.text!,
                    "email": self.email.text!,
                    "phoneNumber": self.phoneNumber.text!,
                    "myImageURL": url
                ]
                
                self.ref.child("Contacts").child("testpls").child(self.phoneNumber.text!).setValue(post)
            }
            
            dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        guard let selectedImage = info[.originalImage] as? UIImage else
        {
            fatalError("error")
        }
        
        imageView.image = selectedImage
        
        dismiss(animated: true, completion: nil)
    }
}

extension String {
    var isValidEmail: Bool {
        NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}").evaluate(with: self)
    }
    
    var isValidPhone: Bool
    {
        NSPredicate(format: "SELF MATCHES %@", "^\\d{3}-\\d{3}-\\d{4}$").evaluate(with: self)
    }
}
