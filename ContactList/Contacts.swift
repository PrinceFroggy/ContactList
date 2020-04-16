//
//  Contacts.swift
//  ContactList
//
//  Created by Andrew Solesa on 2020-04-15.
//  Copyright © 2020 KSG. All rights reserved.
//

import Foundation

class Contacts
{
    var firstName: String?
    var lastName: String?
    var email: String?
    var phoneNumber: String?
    var image: String?
    
    init(firstName: String?, lastName: String?, email: String?, phoneNumber: String?, image: String?)
    {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phoneNumber = phoneNumber
        self.image = image
    }
}
