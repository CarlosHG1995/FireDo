//
//  CrearGrupoViewController.swift
//  FireDo_Carlos
//
//  Created by cmu on 14/06/2020.
//  Copyright © 2020 UPV. All rights reserved.
//

import UIKit

class CrearGrupoViewController: UIViewController, UINavigationControllerDelegate  {

    
    @IBOutlet weak var txt_nombre: UITextField!
    @IBOutlet weak var image_view: UIImageView!

    let activity_indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 65, height: 65))

    override func viewDidLoad() {
        super.viewDidLoad()
        //cargando_info()
        // Do any additional setup after loading the view.
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func btn_cancelar(_ sender: UIBarButtonItem) {
        self.cancelar()
    }
    
    func cancelar() {
        dismiss(animated: true, completion: {})
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

    @IBAction func btn_select_image(_ sender: UIButton) {
        print("clic btn elegir carrete de opciones de imagnes")
       let alertController = UIAlertController(title: "Seleccione una opción", message: "Para elegir imagen de grupo", preferredStyle: UIAlertController.Style.actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Cámara", style: .default, handler:
        { (action) in
            //como el simulador no soporta la opción de abrir la cámara
            //se omite, pero se podría hacer si se quiere para futuras
            //apps, el siguiente metodo es similar al de galeria, lo único que cambia es el sourceType el resto de código es el mismo
            self.tomarFotoCamara()
        }))
        
        alertController.addAction(UIAlertAction(title: "Galería", style: .default, handler:
        { (action) in
            self.actionSeleccionarFoto()
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler:
            { (action) in
        }))
        self.present(alertController, animated: true, completion: nil) 
    }
    func actionSeleccionarFoto()
    {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func tomarFotoCamara()
    {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.camera
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }

    @IBAction func btn_create_grupo(_ sender: UIBarButtonItem) {
        guard let nombre = txt_nombre.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        if let imagen_subir_Firebase = image_view.image
        {
            if let imagen_PNG = imagen_subir_Firebase.pngData()
            {
                ServicioDatabase.shared.create_group(name: nombre, image: imagen_PNG) {error in
                self.activity_indicator.stopAnimating()
                self.view.isUserInteractionEnabled = true
                if let error = error{
                    self.mensaje_Warning(titulo:"Error en crear grupo", mensaje: "Tenemos problemas al crear el grupo, error de tipo \(error)")
                } else{
                    self.mensaje_Warning(titulo: "Éxito al crear grupo", mensaje: "Grupo creado correctamente :)")
                    self.dismiss(animated: true, completion: nil)
                    //si hay error borrar lo siguiente
                    self.txt_nombre.text = ""
                    self.image_view.image = nil
                    
                }
                }
            }
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension  CrearGrupoViewController: UIImagePickerControllerDelegate  {

func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        if let IMAGEN_SELECCIONADA = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            image_view.image = IMAGEN_SELECCIONADA
        }
        self.dismiss(animated: true, completion: nil) //  selector de carrete se cierra al elegir la imagen
    }
    
}
