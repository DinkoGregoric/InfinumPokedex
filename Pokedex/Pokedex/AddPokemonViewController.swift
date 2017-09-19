//
//  AddPokemonViewController.swift
//  Pokedex
//
//  Created by Infinum Student Academy on 27/07/2017.
//  Copyright © 2017 Dinko Gregorić. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import CodableAlamofire

protocol ObjectPassable: class {
    func sendPokemon(_ pokemon: Pokemon?)
}

class AddPokemonViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    weak var delegate: ObjectPassable?
    var newUser: UserRegistered?
        
    @IBOutlet weak var pokeGender: UITextField!
    @IBOutlet weak var weight: UITextField!
    @IBOutlet weak var pokemonImage: UIImageView!
    @IBOutlet weak var pokemonName: UITextField!
    @IBOutlet weak var pokemonHeight: UITextField!
    @IBOutlet weak var pokemonDescription: UITextField!
    
    override func viewWillAppear(_ animated: Bool) {
        
        pokeGender.center.x -= view.bounds.width
        weight.center.x -= view.bounds.width
        pokemonName.center.x -= view.bounds.width
        pokemonHeight.center.x -= view.bounds.width
        pokemonDescription.center.x -= view.bounds.width
    }
    override func viewDidAppear(_ animated: Bool) {
        
        UIView.animate(withDuration: 0.5) {
            self.pokeGender.center.x += self.view.bounds.width
            self.weight.center.x += self.view.bounds.width
            self.pokemonName.center.x += self.view.bounds.width
            self.pokemonHeight.center.x += self.view.bounds.width
            self.pokemonDescription.center.x += self.view.bounds.width
        }
    }
    
    @IBAction func addPokemon(_ sender: Any) {
        uploadPokemonOnAPI(image: self.pokemonImage.image ?? UIImage())
    }

    @IBAction func AddImage(_ sender: Any) {
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.photoLibrary
        image.allowsEditing = false
        
        self.present(image, animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            pokemonImage.image = image
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func uploadPokemonOnAPI(image: UIImage) {
        
        guard
            let pokemonName = pokemonName.text,
            let pokemonHeight = pokemonHeight.text,
            let pokemonWeight = weight.text,
            let pokemonGender = pokeGender.text,
            let pokemonDescription = pokemonDescription.text,
            !pokemonName.isEmpty,
            !pokemonHeight.isEmpty,
            !pokemonWeight.isEmpty,
            !pokemonGender.isEmpty,
            !pokemonDescription.isEmpty
            else {
                return
        }
        
        let headers = ["Authorization": "Token token=" + newUser!.authToken + ", email=" + newUser!.email + ""]
        
        let attributes = [
            "name":pokemonName,
            "height":pokemonHeight,
            "weight":pokemonWeight,
            "gender_id":pokemonGender,
            "description": pokemonDescription
        ]
        
        Alamofire
            .upload(multipartFormData: { multipartFormData in
                multipartFormData.append(UIImageJPEGRepresentation(image, 0.5)!,
                                         withName: "data[attributes][image]",
                                         fileName: "image.jpeg",
                                         mimeType: "image/jpeg")
                for (key, value) in attributes {
                    multipartFormData.append(value.data(using: .utf8)!, withName: "data[attributes][" + key + "]")
                }
            }, to: "https://pokeapi.infinum.co/api/v1/pokemons", method: .post, headers: headers) { [weak self] result in
                switch result {
                case .success(let uploadRequest, _, _):
                    self?.processUploadRequest(uploadRequest)
                case .failure(let encodingError):
                    print(encodingError)
                }
        }
    }
    
    private func processUploadRequest(_ uploadRequest: UploadRequest) {
        uploadRequest.responseDecodableObject(keyPath: "data") { (response: DataResponse<Pokemon>) in
            switch response.result {
            case .success(let pokemon):
                print("DECODED: \(pokemon)")
                self.delegate?.sendPokemon(pokemon)
            case .failure(let error):
                print("FAILURE: \(error)")
            }
        }
    }
}
