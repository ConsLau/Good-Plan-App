//
//  AllImageCollectionViewController.swift
//  Hiu Lam Lau-A4-FinalApplication
//
//  Created by Cons Lau on 5/5/2023.
//

import UIKit

let reuseIdentifier = "ImageCell"

class AllImageCollectionViewController: UICollectionViewController, UISearchBarDelegate, UICollectionViewDelegateFlowLayout {
    
    
    // variable
    private var searchBar: UISearchBar!
    private var images: [URL] = []
    
    weak var imageSelectionDelegate: ImageSelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSearchBar()
        self.collectionView!.register(ImageCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    func setupSearchBar(){
        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.placeholder = "Search for images"
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        guard let searchText = searchBar.text, !searchText.isEmpty else{ return
        }
        
        fetchImages(for: searchText)
    }

    func fetchImages(for query: String){
        let apiKey = "HXYiQMCdJoKfNvxKhGpkSDacYVZOTZHbG0X4SzCQcsFVxStdu30TTcOF"
        let urlString = "https://api.pexels.com/v1/search?query=\(query)&per_page=15"
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data, error == nil else { return }
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let photos = json["photos"] as? [[String: Any]] {
                            self.images = photos.compactMap { photo in
                                if let src = photo["src"] as? [String: Any],
                                   let urlString = src["medium"] as? String {
                                    return URL(string: urlString)
                                }
                                return nil
                            }
                            DispatchQueue.main.async {
                                self.collectionView.reloadData()
                            }
                        }
                    } catch {
                        print("Error parsing JSON:", error)
                    }
                }.resume()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return images.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        
        let imageURL = images[indexPath.item]
        
        URLSession.shared.dataTask(with: imageURL) { data, response, error in
                    guard let data = data, error == nil else { return }
                    DispatchQueue.main.async {
                        if let image = UIImage(data: data) {
                                        cell.imageView.image = image
                                    }
                    }
                }.resume()

        // Configure the cell
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 30)/2
        return CGSize(width: width, height: width)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedImageURL = images[indexPath.item]
        imageSelectionDelegate?.didSelectImage(imageURL: selectedImageURL)
        navigationController?.popViewController(animated: true)
    }

    
}
