//
//  ServicioDatabase.swift
//  FireDo_Carlos
//
//  Created by cmu on 14/06/2020.
//  Copyright © 2020 UPV. All rights reserved.
//

import Foundation
import PromiseKit
import Firebase

class ServicioDatabase {
    
    typealias CompleteHandler = (Error?) -> Void
    static let shared = ServicioDatabase()
    
    var refer: DatabaseReference!
    
    private init() {
        refer = Database.database().reference()
        print("inicia el init -> serviciodb \(refer!)")
    }
    
    func saveUser(userId: String, email: String){
        let data: [String: Any] = ["email": email]
        
        //hacer override
        self.refer.child("users").child(userId).setValue(data)
        print("guardar_user -> \(data)")
    }
    
    func create_group(name: String, image: Data, onComplete: @escaping CompleteHandler){
        let name_ima = "\(name)-\(UUID().uuidString).png"
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        
        let ref_url = Storage.storage().reference(forURL: "gs://firedo-ios-carlos.appspot.com").child("images/\(name_ima)")
        
        ref_url.putData(image, metadata: metadata) {
            metadata, error in
            if let error = error {
                print("Erro al cargar la imagen \(error)")
                onComplete(error)
                return
            }
            
            ref_url.downloadURL { url, error in
                if let error = error {
                    print("Error al obtener la url descarga \(error.localizedDescription)")
                    onComplete(error)
                    return
                }
                
                let dato: Dictionary<String, Any> = ["name": name, "imageURL":url?.absoluteString as Any]
                
                Database.database().reference(withPath: "groups").childByAutoId().setValue(dato)
                onComplete(nil)
            }
        }
    }
    
    func allGroups(onComplete: @escaping ([Group]?) -> Void){
        Database.database().reference(withPath: "groups").observeSingleEvent(of: .value) { snapshot in
            
            var groups_Array = [Group]()
            snapshot.children.forEach { group in
                guard let snapshot = group as? DataSnapshot,
                    let grup_Dic = snapshot.value as? Dictionary<String, Any> else {
                        //un posible error
                        onComplete(nil)
                        return
                }
                groups_Array.append(Group(dictionary: grup_Dic)!)
            }
            onComplete(groups_Array)
        }
    }
    
    
    func unir_gruop(group: Group, onComplete: @escaping CompleteHandler){
        
        Database.database().reference().child("groups")
        .queryOrdered(byChild: "name")
            .queryEqual(toValue: group.name)
            .observeSingleEvent(of: .value) { snapshot in
                
                //Obtner la clave del nodo del grupo
                let clave_group = (snapshot.children.allObjects.first as! DataSnapshot).key
                print("clave del grupo a unirse \(clave_group)")
                //leer valores del grupo elegido
                Database.database().reference(withPath: "groups/\(clave_group)/users")
                    .observeSingleEvent(of: .value) { snapshot in
                        
                        var usuarios_array = [String]()
                        if let usuarios = snapshot.value as? [String]{
                            usuarios_array = usuarios
                        }
                        
                        let userId = Auth.auth().currentUser!.uid
                        if usuarios_array.contains(userId){
                            onComplete(DatabseServiceError(description: "El usuario ya está en este grupo"))
                            return
                        }
                        //actualizar el nodo con el nuevo usuario
                        usuarios_array.append(userId)
                        snapshot.ref.setValue(usuarios_array)
                        
                        //unir nodo usuario
                        Database.database().reference(withPath: "users/\(userId)/groups")
                            .observeSingleEvent(of: .value) { snapshot in
                                
                                var grupos_Array = [String]()
                                //recupero los grupos ya existentes con DataSna
                                if let los_grupos = snapshot.value as? [String] {
                                    grupos_Array = los_grupos
                                }
                                // añadir nuevo grupo
                                
                                grupos_Array.append(clave_group)
                                print("grupos del usuario: \n \(grupos_Array)")
                                //sobreescribo el valor del nodo
                                snapshot.ref.setValue(grupos_Array)
                                onComplete(nil)
                        }
                }
        }
    }
    
    func grupos_unirse(for userId: String, onComplete: @escaping (([Group]?)) -> Void)
    {
        Database.database().reference(withPath: "users/\(userId)/groups")
            .observeSingleEvent(of: .value) { snapshot in
                guard let grupos_usuario = snapshot.value as? [String] else {
                    onComplete(nil)
                    return
                }
                let dispatch = DispatchGroup()
                var grupos = [Group]()
                
                grupos_usuario.forEach { groupId in
                dispatch.enter()
                    Database.database().reference(withPath: "groups/\(groupId)")
                        .observeSingleEvent(of: .value) { snapshot in
                            
                            guard let diccionar = snapshot.value as? Dictionary<String, Any> else {
                                dispatch.leave()
                                return
                            }
                            grupos.append(Group(dictionary: diccionar)!)
                            dispatch.leave()
                    }
                }
                dispatch.notify(queue: .main){
                    print("Termina todas las peticiones")
                    onComplete(grupos)
                }
        }
        
    }
    
    func crearTarea(_ tarea: Tarea, for grupo: Group ){
        Database.database().reference().child("groups")
        .queryOrdered(byChild: "name")
            .queryEqual(toValue: grupo.name)
            .observeSingleEvent(of: .value) { snapshot in
                
                let clave_grupo = (snapshot.children.allObjects.first as! DataSnapshot).key
                Database.database().reference(withPath: "groups/\(clave_grupo)/tasks")
                    .observeSingleEvent(of: .value) { snapshot in
                        var Array_tareas = [[String: Any]]()
                        if let tasks = snapshot.value as? [[String: Any]]{
                            Array_tareas = tasks
                        }
                        Array_tareas.append(tarea.dictionary)
                        snapshot.ref.setValue(Array_tareas)
                }
        }
        
    }
    
    func clave_unir(for grupo: Group) -> Promise<String> {
         return Promise { fulfill in
                   Database.database().reference().child("groups")
                       .queryOrdered(byChild: "name")
                       .queryEqual(toValue: grupo.name)
                       .observeSingleEvent(of: .value) { snapshot in
                       
                       let claveGrupo = (snapshot.children.allObjects.first as! DataSnapshot).key
                       fulfill.fulfill(claveGrupo)
                   }
               }
        
    }
    
}

struct  DatabseServiceError: Error {

    var description: String = ""
    init?(description: String){
        self.description = description
    }
}
