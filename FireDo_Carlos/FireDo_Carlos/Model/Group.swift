//
//  Group.swift
//  FireDo_Carlos
//
//  Created by cmu on 14/06/2020.
//  Copyright © 2020 UPV. All rights reserved.
//

import Foundation

struct  Group {
    var name: String
    var imageURL: String
    var dictionary: [String: Any]{
        return ["name": name, "imageURL": imageURL]
    }
    
    init?(dictionary: [String: Any]) {
        self.name = dictionary["name"] as! String
        self.imageURL = dictionary["imageURL"] as! String
    }
}
