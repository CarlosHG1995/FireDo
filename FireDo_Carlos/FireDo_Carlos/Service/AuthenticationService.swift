//
//  AuthenticationService.swift
//  FireDo_Carlos
//
//  Created by cmu on 12/06/2020.
//  Copyright © 2020 UPV. All rights reserved.
//

import Foundation
import Firebase

class AuthenticationService {
    
    typealias  Handler_Complete = (Error?) -> Void
    
    static let shared = AuthenticationService()
    
    private init() {}
    

/**/
func registerUser(email: String, password: String, onComplete: @escaping Handler_Complete){
    Auth.auth().createUser(withEmail: email, password: password){ result, error in
        if let  error = error as NSError?, let errorCode = AuthErrorCode(rawValue: error.code)
        {
            print("Error al registrar el usuario \(errorCode)")
            onComplete(error)
            return
        }
        guard let user = result?.user, error == nil else {
            print("Error al obtener al usuario \(error!.localizedDescription)")
            onComplete(error!)
            return
        }
        ServicioDatabase.shared.saveUser(userId: user.uid, email: user.email!)
        print("Usuario resgistrado existosamente en fun registerUser ServicioDatab")
        onComplete(nil)
        
    }
}
func loginUser(email: String, password: String, onComplete: @escaping Handler_Complete){
    
    Auth.auth().signIn(withEmail: email, password: password) { [weak self]
    result, error in
        if let error = error as NSError?, let errorCode = AuthErrorCode(rawValue: error.code){
            print("Error al hacer el login al usuario \(errorCode)")
            onComplete(error)
            return
        }
        
        print("Usuario autenticado")
        onComplete(nil)
    }
        
}
    
    func logOut(onComplete: @escaping Handler_Complete){
        let FireBAuth = Auth.auth()
        do {
            try FireBAuth.signOut()
            onComplete(nil)
        } catch let signOutError as NSError {
            print("Error en sign out ")
            onComplete(signOutError)
        }
    }

}
