//
//  GruposTableViewController.swift
//  FireDo_Carlos
//
//  Created by cmu on 16/06/2020.
//  Copyright © 2020 UPV. All rights reserved.
//

import UIKit

class GruposTableViewController: UITableViewController {

    var Array_grupos = [Group]()
    var actualizar: UIRefreshControl = UIRefreshControl()
    
        override func viewDidLoad() {
            super.viewDidLoad()
            update_table()
    
            // Uncomment the following line to preserve selection between presentations
            // self.clearsSelectionOnViewWillAppear = false
    
            // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
            // self.navigationItem.rightBarButtonItem = self.editButtonItem
        }
    
        @objc func update_table(){
            ServicioDatabase.shared.allGroups(){ groups in
             if let groups = groups {
                self.Array_grupos = groups
                self.tableView.reloadData()
             }
            }
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
    
        @IBAction func btn_cancelar(_ sender: UIBarButtonItem) {
            dismiss(animated: true, completion: nil)
        }
    
        // MARK: - Table view data source
    
        override func numberOfSections(in tableView: UITableView) -> Int {
            // #warning Incomplete implementation, return the number of sections
            return 1
        }
    
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            // #warning Incomplete implementation, return the number of rows
            return Array_grupos.count
        }
    
        /* */
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "celda_custom", for: indexPath)
            cell.textLabel?.text = Array_grupos[indexPath.row].name
            cell.textLabel?.textColor = UIColor(red: 0.035, green: 0.47, blue: 0.17, alpha: 1.0)
            cell.textLabel?.font = UIFont(name: "HelveticaNeue-CondensedBold", size: 24.0)
           // cell.imageView?.image = Array_grupos[indexPath.row].imageURL
            return cell
        }
       
       override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
       {
           let grupo = Array_grupos[indexPath.row]
           ServicioDatabase.shared.unir_gruop(group: grupo){error in
           if let error = error {
                self.mensaje_Warning(titulo:"Error al elegir el grupo", mensaje: "Houston tenemos problemas, al seleccionar el grupo, error de tipo \(error)")
            } else {
                self.dismiss(animated: true, completion: nil)
            }
           }
       }
    
        /*
        // Override to support conditional editing of the table view.
        override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            // Return false if you do not want the specified item to be editable.
            return true
        }
        */
    
        /*
        // Override to support editing the table view.
        override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                // Delete the row from the data source
                tableView.deleteRows(at: [indexPath], with: .fade)
            } else if editingStyle == .insert {
                // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            }
        }
        */
    
        /*
        // Override to support rearranging the table view.
        override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
    
        }
        */
    
        /*
        // Override to support conditional rearranging of the table view.
        override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
            // Return false if you do not want the item to be re-orderable.
            return true
        }
        */
    
        /*
        // MARK: - Navigation
    
        // In a storyboard-based application, you will often want to do a little preparation before navigation
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            // Get the new view controller using segue.destination.
            // Pass the selected object to the new view controller.
        }
        */

}
