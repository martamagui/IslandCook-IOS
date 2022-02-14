//
//  TVCGetAllRecipes.swift
//  IslandCook
//
//  Created by Xavi Giron on 9/2/22.
//

import UIKit

class TVCGetAllRecipes: UITableViewController {
    
    var decodeData: [DatosDetalle] = []
    var urlImg: String?
//    let origen = "Local"
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let url = loadDataFromremoteUrl()
        decodeJson(url: url)
    }
    
//    Decodificamos archivo parseado
    
    func decodeJson(url: URL)
    {
        do
        {
            let decoder = JSONDecoder()
            let datosArchivo = try Data(contentsOf: url)
            
            decodeData = try decoder.decode([DatosDetalle].self, from: datosArchivo)
        }
        catch
        {
            print("Error, no se puede parsear el archivo")
        }
        
        
    }
    
//    Cargamos datos de nuestro server
    
    func loadDataFromremoteUrl() -> URL
    {
        guard let url = URL(string: "https://island-cook.herokuapp.com/api/recipe") else {
            fatalError("No se encuentra el JSON en la ruta remota")
        }
        return url
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return decodeData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        urlImg = decodeData[indexPath.row].picture_url

        // Configure the cell...
//        var iden = String()
        cell.textLabel?.text = decodeData [indexPath.row].name
        cell.imageView?.downloaded(from: urlImg!)

        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let celdaSeleccionada = miTabla.indexPathForSelectedRow?.row else {return}
        let postSeleccionado = decodeData[celdaSeleccionada]
        let vistaDetalle = segue.destination as! VCDetailRecipe
    
        vistaDetalle.id = postSeleccionado._id
        vistaDetalle.nombre = postSeleccionado.name
        vistaDetalle.steps = postSeleccionado.steps
        vistaDetalle.author = postSeleccionado.author
        vistaDetalle.imageUrl = postSeleccionado.picture_url
        vistaDetalle.ingredients = postSeleccionado.ingredients
    }
    
    
    @IBOutlet var miTabla: UITableView!
    
}

//Extensión de carga de la imagen de receta

extension UIImageView {
    
//    función de descarga de la imagen de receta
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFill) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFill) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
