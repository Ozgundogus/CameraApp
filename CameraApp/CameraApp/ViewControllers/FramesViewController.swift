//
//  FramesViewController.swift
//  CameraApp
//
//  Created by Ozgun Dogus on 1.08.2024.
//


import UIKit

class FramesViewController: UIViewController, UICollectionViewDataSource {
    var frames: [UIImage] = []
    var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupCollectionView()
    }
    
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.register(FrameCell.self, forCellWithReuseIdentifier: "FrameCell")
        collectionView.backgroundColor = .white
        
        view.addSubview(collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return frames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FrameCell", for: indexPath) as! FrameCell
        cell.imageView.image = frames[indexPath.item]
        return cell
    }
}

