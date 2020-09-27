//
//  MenuViewController.swift
//  FireDo_Carlos
//
//  Created by cmu on 14/06/2020.
//  Copyright © 2020 UPV. All rights reserved.
//

import UIKit
import Firebase

class MenuViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
   
    let ID_reuse = "colection_cell"
    //var ic = ["1", "2", "3", "4", "5"]
   
       
    var ancho = 240.0
    var tamaño_cell = 200.0

    @IBOutlet weak var colection_view_grupos: UICollectionView!
    
    var Array_grupos = [Group]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        colection_view_grupos.delegate = self
        colection_view_grupos.dataSource = self
        
       
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        db_unirsegrupos()
    }
    
    func db_unirsegrupos(){
        ServicioDatabase.shared.grupos_unirse(for: Auth.auth().currentUser!.uid) { grupos in
                   if let gruposs = grupos {
                       self.Array_grupos = gruposs
                       if self.Array_grupos.count > 0 {
                           print("Lista de Array grupos \(self.Array_grupos)")
                           DispatchQueue.main.async {
                               self.colection_view_grupos.reloadData()
                           }
                       }
                   }
               }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        print("custom -> \(custom_colection_view())")
        custom_colection_view()
    }
    
    func mensaje_Warning(titulo:String, mensaje:String)
    {
           let alertController = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
           
           alertController.addAction(UIAlertAction(title: "OK", style: .default, handler:
               { (action) in
                   self.dismiss(animated: true, completion: nil)
           }))
           self.present(alertController, animated: true, completion: nil)
    }

    @IBAction func cerrar_sesion(_ sender: UIBarButtonItem) {
        print("btn item cerrar sesion clic")
        self.cerrar_Sesion()
    }
    
    @IBAction func crear_grupo(_ sender: UIBarButtonItem) {
        print("crear_Grupo")
        performSegue(withIdentifier: "crear_grupoVC", sender: self)
    }
    
    func cerrar_Sesion() {
        AuthenticationService.shared.logOut() { error in
            if let error = error {
                self.mensaje_Warning(titulo: "Error al cerrar sesión", mensaje: "Houston tenemos problemas al cerrar sesión del usuario, el error es: \(error)")
            } else {
                self.dismiss(animated: true, completion: {})
            }
        }
    }

    /*
    // MARK: - Navigation
*/
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "crear_grupoVC" {
            guard let new_grupo = segue.destination as? CrearGrupoViewController else { return}
       
        }
        else if segue.identifier == "TareasVC" {
            guard let tareas_VC = segue.destination as? TareasViewController else { return }
            guard let grupo_Elegido = sender as? Group else { return }
            
            tareas_VC.Selec_grupo = grupo_Elegido
            print("Grupo tarea seleccionada por el usuario \(String(describing: tareas_VC.Selec_grupo))")
        }
        
    }
    var CVFlowLayout: UICollectionViewFlowLayout!
    
    func custom_colection_view(){
        if CVFlowLayout == nil {
            let numPofila: CGFloat = 2
            let espacio: CGFloat = 4
            let interespacio: CGFloat = 4
            let ancho = (colection_view_grupos.frame.width - (numPofila - 1) * interespacio ) / numPofila
            let alto = ancho
            CVFlowLayout = UICollectionViewFlowLayout()
            CVFlowLayout.itemSize = CGSize(width: ancho, height: alto)
            CVFlowLayout.sectionInset = UIEdgeInsets.zero
            CVFlowLayout.scrollDirection = .vertical
            CVFlowLayout.minimumLineSpacing = espacio
            CVFlowLayout.minimumInteritemSpacing = interespacio
        }
    }
    
    // MARK: Protocolos de source  UICollection
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.Array_grupos.count
       }
       
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ID_reuse, for: indexPath as IndexPath) as! ColeccionGruposViewCell
        cell.config(with: Array_grupos[indexPath.item])
             print("array de grupos del usuario \(ID_reuse) , \n  \(cell.config(with: Array_grupos[indexPath.item])), \n  la cell es \(cell)")
        return cell
    }
    
    // MARK: Protocols de delegates de UICollection
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let TareasVC: TareasViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VC_tareas") as! TareasViewController
        TareasVC.Selec_grupo = Array_grupos[indexPath.item]
        self.present(TareasVC, animated: true, completion: nil)
    }
}
extension MenuViewController: UICollectionViewDelegateFlowLayout{
    
}
