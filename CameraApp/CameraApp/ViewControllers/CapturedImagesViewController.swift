//
//  CapturedImagesViewController.swift
//  CameraApp
//
//  Created by Ozgun Dogus on 5.08.2024.
//


import UIKit

final class CapturedImagesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    var collectionView: UICollectionView!
    var capturedImages: [UIImage] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupCollectionView()
        setupNavigationBar()
        loadCapturedImages()
    }
    
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CapturedImageCell.self, forCellWithReuseIdentifier: "CapturedImageCell")
        collectionView.backgroundColor = .white
        
        view.addSubview(collectionView)
    }
    
    func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(deleteAllImages))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Home", style: .plain, target: self, action: #selector(navigateToHome))
    }
    
    func loadCapturedImages() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsPath, includingPropertiesForKeys: nil)
            
            for fileURL in fileURLs {
                if fileURL.pathExtension == "jpg" {
                    if let imageData = try? Data(contentsOf: fileURL) {
                        if let image = UIImage(data: imageData) {
                            capturedImages.append(image)
                        }
                    }
                }
            }
        } catch {
            print("Error loading images: \(error)")
        }
        
        collectionView.reloadData()
    }
    
    @objc func deleteAllImages() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsPath, includingPropertiesForKeys: nil)
            
            for fileURL in fileURLs {
                if fileURL.pathExtension == "jpg" {
                    try FileManager.default.removeItem(at: fileURL)
                }
            }
            
            capturedImages.removeAll()
            collectionView.reloadData()
        } catch {
            print("Error deleting images: \(error)")
        }
    }
    
    @objc func navigateToHome() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return capturedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CapturedImageCell", for: indexPath) as! CapturedImageCell
        cell.imageView.image = capturedImages[indexPath.item]
        return cell
    }
}


