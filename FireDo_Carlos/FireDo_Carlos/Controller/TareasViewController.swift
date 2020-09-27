//
//  TareasViewController.swift
//  FireDo_Carlos
//
//  Created by cmu on 15/06/2020.
//  Copyright © 2020 UPV. All rights reserved.
//

import UIKit
import Firebase
import PromiseKit

class TareasViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
      
    @IBOutlet weak var tabla_tareas: UITableView!
    
    var Selec_grupo: Group!
    var ArrayTareas: [Tarea] = []
    var Id_grupo: String!
    var Handler: DatabaseHandle!
    
    let activity_indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 65, height: 65))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tabla_tareas.delegate = self
        tabla_tareas.dataSource = self
        print("Tareas ->grupo seleciconado \(String(describing: Selec_grupo!))")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Actualiza_tabla()
    }
    
    func Actualiza_tabla(){
        firstly {
            ServicioDatabase.shared.clave_unir(for: Selec_grupo)
        }.done { Id_grupo in
            self.Id_grupo = Id_grupo
            self.ArrayTareas.removeAll()
            self.Handler = Database.database().reference(withPath: "groups/\(Id_grupo)/tasks")
                .observe(.childAdded) {snapshot in
                    if let dictio = snapshot.value as? Dictionary<String,Any> {
                        let la_tarea = Tarea(dictonary: dictio)!
                        self.ArrayTareas.append(la_tarea)
                        print("Tarea añadida \(la_tarea)")
                    }
                    
                    let UltimoIndex = self.tabla_tareas!.numberOfSections - 1
                    
                    let UltimaFila = self.tabla_tareas.numberOfRows(inSection: UltimoIndex)
                    let _ = NSIndexPath(row: UltimaFila, section: UltimoIndex)
                    self.tabla_tareas.insertRows(at: [IndexPath(row: self.ArrayTareas.count-1, section: 0)], with: UITableView.RowAnimation.automatic)
            }
        } .cauterize()
    }
    
    func cargando_info(){
        activity_indicator.center = self.view.center
        activity_indicator.hidesWhenStopped = true
        activity_indicator.style = UIActivityIndicatorView.Style.medium
        self.view.addSubview(activity_indicator)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func add_Tarea(_ sender: UIBarButtonItem) {
        print("clic add tarea en TareasVC")
        let cuadro_Alerta = UIAlertController(title: "Añadir nueva tarea ", message: "Grupo \(Selec_grupo.name)", preferredStyle: .alert)
        cuadro_Alerta.addTextField { (textField) in
        textField.placeholder = "Escriba una nueva tarea hacer"
        }
        
        cuadro_Alerta.addAction(UIAlertAction(title: "Añadir",style: .default, handler:{
            (action) in
            let Nva_Tarea = cuadro_Alerta.textFields![0].text?.trimmingCharacters(in: .whitespacesAndNewlines)
            if Nva_Tarea!.isEmpty == false {
                let dato_tarea: [String: Any] = ["description": Nva_Tarea!, "status": Estados_tareas.Todo.rawValue]
                let tarea: Tarea = Tarea.init(dictonary: dato_tarea)!
                ServicioDatabase.shared.crearTarea(tarea, for: self.Selec_grupo)
            } else
            { //ai por algo no escribe nada el usuario debe aparecer esto
               let vacio = UIAlertController(title: "Error", message: "No debe dejar el campo vacío, escriba de nuevo", preferredStyle: .alert)
                vacio.addAction(UIAlertAction(title: "OK", style: .default, handler:
                    { (action) in
                        //self.dismiss(animated: true, completion: nil)
                }))
                self.present(vacio, animated: true, completion: nil)
            }
        } ))
        
        cuadro_Alerta.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: { (action) in
            
        }))
        self.present(cuadro_Alerta, animated: true, completion: nil)
    }
    
    @IBAction func sale_tarea(_ sender: UIBarButtonItem) {
        print("clic sale tarea en TareasVC")
        dismiss(animated: true, completion: {})
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ArrayTareas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if ArrayTareas.count > 0 {
            cell.textLabel?.text = ArrayTareas[indexPath.row].description
            cell.textLabel?.textColor = UIColor(red: 0.035, green: 0.47, blue: 0.17, alpha: 1.0)
            cell.textLabel?.font = UIFont(name: "HelveticaNeue-CondensedBold", size: 24.0)
             
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let color: UIColor = UIColor(red: 0.9778, green: 1.0, blue: 0.4627, alpha: 1.0)
        cell.backgroundColor = color
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Tareas \(indexPath.row)")
    }

}
