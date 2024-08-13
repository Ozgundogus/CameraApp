//
//  FramesInfoBottomSheetViewController.swift
//  CameraApp
//
//  Created by Ozgun Dogus on 4.08.2024.
//

import UIKit

final class FramesInfoBottomSheetViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var totalDuration: Double = 0.0
    var totalFrames: Int = 0
    var totalSize: Int = 0
    let tableView = UITableView()
    let cellHeight: CGFloat = 44.0
    let numberOfRows = 6
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adjustPreferredContentSize()
    }
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        closeButton.tintColor = .label
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.isScrollEnabled = true
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.9),
            
            closeButton.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: -8),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            closeButton.widthAnchor.constraint(equalToConstant: 24),
            closeButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    @objc func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    func adjustPreferredContentSize() {
        let screenHeight = UIScreen.main.bounds.height
        let desiredHeight = screenHeight / 1.8
        view.frame.size.height = desiredHeight
        view.frame.origin.y = screenHeight - desiredHeight
        preferredContentSize = CGSize(width: view.frame.width, height: desiredHeight)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Size of the captured images: \(String(format: "%.2f", getTotalImageSize())) MB"
        case 1:
            cell.textLabel?.text = "Duration of the whole capture: \(String(format: "%.2f", totalDuration)) seconds"
        case 2:
            cell.textLabel?.text = "Frame rate: \(String(format: "%.2f", Double(totalFrames) / totalDuration)) frames per second"
        case 3:
            cell.textLabel?.text = "Total frames: \(totalFrames) frames"
        case 4:
            cell.textLabel?.text = "Total size: \(String(format: "%.2f", getTotalImageSize())) MB"
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func getTotalImageSize() -> Double {
        return Double(totalSize) / (1024 * 1024) 
    }
}
