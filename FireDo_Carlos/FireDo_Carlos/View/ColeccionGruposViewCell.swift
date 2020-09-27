//
//  ColeccionGruposViewCell.swift
//  FireDo_Carlos
//
//  Created by cmu on 15/06/2020.
//  Copyright © 2020 UPV. All rights reserved.
//

import UIKit
import SDWebImage

class ColeccionGruposViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imagen_grupo: UIImageView!
    @IBOutlet weak var nombre_grupo: UILabel!
    
    func config(with grupo: Group){
        nombre_grupo.text = grupo.name
        imagen_grupo.sd_setImage(with: URL(string: grupo.imageURL), completed: nil)
        print("imagen grupo es \( imagen_grupo.sd_setImage(with: URL(string: grupo.imageURL), completed: nil)) \n y group name es \(nombre_grupo.text = grupo.name)")
    }
    
    
}
