//
//  TableViewController.swift
//  ContactList
//
//  Created by Andrew Solesa on 2020-04-14.
//  Copyright © 2020 KSG. All rights reserved.
//

import UIKit
import Firebase

class ContactsTableViewCell: UITableViewCell
{
    @IBOutlet weak var myImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var number: UILabel!
}

class TableViewController: UITableViewController, UISearchBarDelegate
{
    var ref:DatabaseReference!
    var myContacts = [Contacts]()
    var filteredMyContacts = [Contacts]()
    var searchBar: UISearchBar?
    
    var row = 0
    var loading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar = UISearchBar()
        searchBar!.sizeToFit()
        
        searchBar!.delegate = self
        searchBar!.placeholder = "Search names here..."
        
        navigationItem.titleView = searchBar
        
        Auth.auth().signIn(withEmail: "test@gmail.com", password: "1234567890")
        { (result, error) in
            if let _eror = error
            {
                print(_eror.localizedDescription)
            }
            else
            {
                if let _res = result
                {
                    print(_res)
                }
            }
        }
        
        self.tableView.rowHeight = 124
        
        loading = false
        
        loadTable()
        refreshTable()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @IBAction func sorter(_ sender: UIBarButtonItem)
    {
        isEditing = !isEditing
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        self.searchBar!.endEditing(true)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if searchBar!.text != ""
        {
            return filteredMyContacts.count
        }
        return myContacts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ContactsTableViewCell
        
        if searchBar!.text != ""
        {
            let test = filteredMyContacts[indexPath.row]
            cell.name.text = test.firstName! + " " + test.lastName!
            cell.number.text = test.phoneNumber!
            cell.myImage.load(url: URL(string: test.image!)!)
            return cell
        }
        else
        {
            let test = myContacts[indexPath.row]
            cell.name.text = test.firstName! + " " + test.lastName!
            cell.number.text = test.phoneNumber!
            cell.myImage.load(url: URL(string: test.image!)!)
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            ref.child("Contacts").child("testpls").child(myContacts[indexPath.row].phoneNumber!).removeValue
            { error,arg  in
              if error != nil
              {
                  print("error \(error)")
              }
            }
            myContacts.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        row = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = myContacts[sourceIndexPath.row]
        myContacts.remove(at: sourceIndexPath.row)
        myContacts.insert(itemToMove, at: destinationIndexPath.row)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        self.tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        if searchBar.text == nil || searchBar.text == ""
        {
           searchBar.perform(#selector(self.resignFirstResponder), with: nil, afterDelay: 0.1)
        }
        
        let searchString = searchBar.text
        filteredMyContacts = myContacts.filter({ (item) -> Bool in
            let value: NSString = item.firstName as! NSString
            return (value.range(of: searchString!, options: .caseInsensitive).location != NSNotFound)
        })
        self.tableView.reloadData()
    }

    func loadTable()
    {
        ref = Database.database().reference()
        
        ref.child("Contacts").child("testpls").queryOrdered(byChild: "phoneNumber").observe(.childAdded, with:
            { (snapshot) in
                
                let results = snapshot.value as? [String : AnyObject]
                let firstName = results?["firstName"]
                let lastName = results?["lastName"]
                let email = results?["email"]
                let phoneNumber = results?["phoneNumber"]
                let image = results?["myImageURL"]
                let contact = Contacts(firstName: firstName as! String?, lastName: lastName as! String?, email: email as! String?, phoneNumber: phoneNumber as! String?, image: image as! String?)
                
                self.myContacts.append(contact)
                
                DispatchQueue.main.async
                {
                    self.tableView.reloadData()
                }
             })
    }
    
    func refreshTable()
    {
        ref = Database.database().reference()
        
        ref.child("Contacts").child("testpls").queryOrdered(byChild: "phoneNumber").observe(.childChanged, with:
            { (snapshot) in
                
                let results = snapshot.value as? [String : AnyObject]
                let firstName = results?["firstName"]
                let lastName = results?["lastName"]
                let email = results?["email"]
                let phoneNumber = results?["phoneNumber"]
                let image = results?["myImageURL"]
                
                self.myContacts[self.row].firstName = firstName as! String
                self.myContacts[self.row].lastName = lastName as! String
                self.myContacts[self.row].email = email as! String
                self.myContacts[self.row].phoneNumber = phoneNumber as! String
                self.myContacts[self.row].image = image as! String
                
                DispatchQueue.main.async
                {
                    self.tableView.reloadData()
                }
             })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueContactUpdateScene"
        {
            let nav = segue.destination as! UINavigationController
            let vc = nav.viewControllers[0] as! ViewController
            let indexPath = tableView.indexPath(for: sender as! UITableViewCell)
            let selectedData = myContacts[indexPath!.row]
            vc.item = selectedData
            loading = true
        }
    }
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}

