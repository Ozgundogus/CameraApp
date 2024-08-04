//
//  FramesInfoBottomSheetViewController.swift
//  CameraApp
//
//  Created by Ozgun Dogus on 4.08.2024.
//


import UIKit

class FramesInfoBottomSheetViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var videoSegments: [URL] = []
    var totalDuration: Double = 0.0
    var frameRate: Double = 0.0
    var totalFrames: Int = 0
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
        adjustPreferredContentSize()
    }
    
    func setupUI() {
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.isScrollEnabled = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func adjustPreferredContentSize() {
        // Calculate the height of the table view content
        let contentHeight = cellHeight * CGFloat(numberOfRows)
        
        preferredContentSize = CGSize(width: view.frame.width, height: contentHeight)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Size of the captured: \(getTotalFileSize()) MB"
        case 1:
            cell.textLabel?.text = "Amount of the captured: \(videoSegments.count) segments"
        case 2:
            cell.textLabel?.text = "Duration of the whole capture: \(totalDuration) seconds"
        case 3:
            cell.textLabel?.text = "Frame rate: \(frameRate) frames per second"
        case 4:
            cell.textLabel?.text = "Total duration: \(Int(totalDuration)) seconds"
        case 5:
            cell.textLabel?.text = "Total frames: \(totalFrames) frames"
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func getTotalFileSize() -> Double {
        var totalSize: Double = 0.0
        for url in videoSegments {
            if let fileSize = try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Double {
                totalSize += fileSize ?? 0.0
            }
        }
        return totalSize / (1024 * 1024)
    }
}
