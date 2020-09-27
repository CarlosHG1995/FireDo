//
//  ViewController_Login.swift
//  FireDo_Carlos
//
//  Created by cmu on 12/06/2020.
//  Copyright © 2020 UPV. All rights reserved.
//

import UIKit
import Firebase

class ViewController_Login: UIViewController {

    @IBOutlet var txt_correo: UITextField!
    @IBOutlet var txt_password: UITextField!
    @IBOutlet var swt_login_ot: UISwitch!
    @IBAction func sw_login(_ sender: UISwitch) {
    }
    
    //para ocultar teclado al hacer clic en la pantalla
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
           self.view.endEditing(true)
       }
    
    let activity_indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 65, height: 65))
    
    var handle_auth_state: AuthStateDidChangeListenerHandle?
    var el_UID: String?
    var correo: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cargando_info()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser != nil {
            print("el usuario está identificado")
            self.performSegue(withIdentifier: "menu_viewC", sender: self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //inicia la autentificacion
        handle_auth_state = Auth.auth().addStateDidChangeListener({ (auth, user) in
            
            if let user = user {
                self.el_UID = user.uid
                self.correo = user.email
            }// termina exclude
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle_auth_state!)
    }
    @IBAction func action_btn_login(_ sender: UIButton) {
        guard let correo = txt_correo.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            else {return}
        guard let password = txt_password.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            else {return}
        if correo.isEmpty || password.isEmpty
        {
            mensaje_Warning(titulo: "Esta es una Advertencia.", mensaje: "Completa los campos de usuario y contraseña que estén vacíos.")
        } else {
            self.activity_indicator.startAnimating()
            self.view.isUserInteractionEnabled = false
            if (swt_login_ot.isOn)
            {
              //si el boton switch está activo tiene cuenta
                AuthenticationService.shared.loginUser(email: correo, password: password){error in
                self.activity_indicator.stopAnimating()
                self.view.isUserInteractionEnabled = true
                if let error = error {
                    self.mensaje_Warning(titulo: "Esto es un error login.", mensaje: " Houston tenemos problemas con el login de Firebase, el cual es: \(error)")
                } else {
                   // si no funciona aqui van lo que esta en el metodo datos_enviar_menu
                    self.datos_enviar_menu()
                }
                }
            } // cierro el if switch 
            //si el switch esta apagado es un registro de nuevo usuario
            else {
                AuthenticationService.shared.registerUser(email: correo, password: password) {error in
                self.activity_indicator.stopAnimating()
                self.view.isUserInteractionEnabled = true
                if let error = error {
                    self.mensaje_Warning(titulo: "Esto es un error de registro.", mensaje: " Houston tenemos problemas con el registro en Firebase, es un error de tipo: \(error)")
                }
                else {
                  // si no funciona aqui van lo que esta en el metodo datos_enviar_menu
                    self.datos_enviar_menu()
                }
                }
            }//cierro else del switch
        } //cierro el else de comprobar que no están vacios los campos
    }// cierro el action button
    
    func datos_enviar_menu(){
        self.txt_correo.text = ""
        self.txt_password.text = ""
        self.performSegue(withIdentifier: "menu_viewC", sender:self) 
    }
    
    @IBOutlet var btn_login: UIButton!
    
    func mensaje_Warning(titulo:String, mensaje:String)
       {
           let alertController = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
           
           alertController.addAction(UIAlertAction(title: "OK", style: .default, handler:
               { (action) in
                   self.dismiss(animated: true, completion: nil)
           }))
           self.present(alertController, animated: true, completion: nil)
       }
    
    // esto es la rueda de cargando
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

}
