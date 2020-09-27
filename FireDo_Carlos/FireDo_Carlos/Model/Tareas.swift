//
//  Tareas.swift
//  FireDo_Carlos
//
//  Created by cmu on 15/06/2020.
//  Copyright © 2020 UPV. All rights reserved.
//

import Foundation

struct  Tarea {
    
    var description: String
    var status: Estados_tareas
    var dictionary: [String: Any]{
        return ["description": description, "status": status.rawValue]
    }
    
    init?(dictonary:[String: Any]) {
        self.description = dictonary["description"] as! String
        let _status = dictonary["status"] as! NSString
        self.status = Estados_tareas(rawValue: String(_status))!
    }
    
    
}

enum Estados_tareas: String {
    case Todo, EnProgreso, Terminado
}
