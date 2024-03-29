//
//  HomeChildViewController.swift
//  CapstoneProject
//
//  Created by 김승찬 on 2022/05/08.
//

import UIKit
import XLPagerTabStrip
import CoreData

public class TomorrowChildViewController: UIViewController {
    
    static let identifier: String = "tomorrowChildViewController"
    
    // MARK: - Instance Properties
    public var homeChildView: HomeChildView! {
        guard isViewLoaded else { return nil }
        return (view as! HomeChildView)
    }
    
    let request: NSFetchRequest<Task> = Task.fetchRequest()
    var taskList: [Task] = []
    
    // MARK: - View Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        homeChildView.taskCollectionView.delegate = self
        homeChildView.taskCollectionView.dataSource = self
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.taskList = PersistenceManager.shared.fetch(request: request)
        
        // For Debugging
        taskList.flatMap {
            print($0.name)
            print($0.color)
            print($0.expectedTime)
        }
        
        self.homeChildView.taskCollectionView.reloadData()
    }
}

// TO-DO
// cell 당 마진, 크기 조절
// cell 터치 시에 효과 구현
// cell 드래그 앤 드롭 구현
extension TomorrowChildViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return taskList.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeTaskCell.identifier, for: indexPath) as! HomeTaskCell
       
        cell.taskBar.layer.cornerRadius = 8
        cell.taskBar.widthAnchor.constraint(equalToConstant: CGFloat(self.taskList[indexPath.row].expectedTime) * 2).isActive = true
        
        cell.taskBar.backgroundColor = UIColor(rgb: Int(self.taskList[indexPath.row].color))
        cell.taskNameLabel.text = self.taskList[indexPath.row].name

        var expectedMin =  Int(self.taskList[indexPath.row].expectedTime)
        var expectedHour = 0
        if expectedMin > 60 {
            expectedHour = Int(floor(Double(expectedMin / 60)))
            expectedMin -= (expectedHour * 60)
            cell.taskExpectedTimeLabel.text = "\(expectedHour)시간 \(expectedMin) 분"
        } else if expectedMin < 30 {
            cell.taskExpectedTimeLabel.text = ""
        } else {
            cell.taskExpectedTimeLabel.text = "\(expectedMin) 분"
        }
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.bounds.width, height: 90)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let taskDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "taskDetailViewController") as? TaskDetailViewController else { return }
        taskDetailViewController.modalTransitionStyle = .coverVertical
        taskDetailViewController.modalPresentationStyle = .fullScreen
        taskDetailViewController.tempTask = self.taskList[indexPath.row]
        
        self.navigationController?.pushViewController(taskDetailViewController, animated: true)
        self.present(taskDetailViewController, animated: true, completion: nil)
        
    }
}

extension TomorrowChildViewController: IndicatorInfoProvider {
    public func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return ""
    }
}
