//
//  AlgorithmViewController.swift
//  Game_Walker
//
//  Created by Jin Kim on 11/2/22.
//

import UIKit

class AlgorithmViewController: BaseViewController {
    
    @IBOutlet weak var startGameButton: UIButton!
    private var stationList: [Station]? = nil
    private var grid: [[Int]] = [[Int]]()
    private var totalrow : Int =  0
    private var totalcolumn : Int = 0
    
    private var team_smallerthaneight : Bool = false
    private var station_smallerthaneight : Bool = false
    private var round_smallerthaneight : Bool = false
    private var num_rounds : Int = 0
    private var num_teams : Int = 0
    private var num_stations : Int = 0
    

    private var collectionViewWidth = UIScreen.main.bounds.width * 0.85
    private var collectionViewCellWidth : Int = 0
    private var collectionViewCellSpacing = 4
    
    private var num_cols : Int = 8
    private var num_rows : Int = 8

    private var gamecode = UserData.readGamecode("gamecode")!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var pvpGameCount : Int = 1
    private var pveGameCount : Int = 0

    var indexPathA: IndexPath?
    var indexPathB: IndexPath?
    
    var originalcellAimage: UIImage?
    var originalcellAcolor: UIColor?
    var originalcellBimage: UIImage?
    var originalcellBcolor: UIColor?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        S.delegate_stationList = self
        S.getStationList(gamecode)
        H.delegate_getHost = self
        H.getHost(gamecode)
        collectionView.isScrollEnabled = true
        scrollView.isUserInteractionEnabled = true
        scrollView.isScrollEnabled = true
        collectionView.frame = CGRect(x: 0, y: 0, width: collectionViewWidth, height: collectionViewWidth)
        collectionView.dragInteractionEnabled = true

//        print(collectionView.frame, "  HMMMM  ")
        collectionView.delegate = self
//print("CELL WIDTH: ", cellWidth, " :CELL WIDTH")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.createGrid()
            self.collectionView.dataSource = self
            self.collectionView.dragDelegate = self
            self.collectionView.dropDelegate = self
            self.collectionView.clipsToBounds = true
            self.collectionView.isUserInteractionEnabled = true
            self.collectionView.register(UINib(nibName: "AlgorithmCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AlgorithmCollectionViewCell")
            

        }


    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

         
        let flowlayout = UICollectionViewFlowLayout()
        flowlayout.scrollDirection = .vertical
        
        

        print("cell spacing , cell width, view width : ", collectionViewCellSpacing, collectionViewCellWidth, collectionViewWidth)
        flowlayout.minimumLineSpacing = CGFloat(collectionViewCellSpacing)
        flowlayout.minimumInteritemSpacing = CGFloat(collectionViewCellSpacing)
        
        collectionView.collectionViewLayout = flowlayout
        
        print("MY CELL WIDTH?"  , collectionViewCellWidth)
        print("MY COLLECTION VIEW WIDTH?  ", collectionViewWidth)
        print("MY CALCS: " , collectionViewWidth / 8)
        
        print("SPACING SIZES: ", flowlayout.minimumLineSpacing, " AND iteritem: ", flowlayout.minimumInteritemSpacing)
        

        let contentWidth = (totalcolumn * 8 * collectionViewCellWidth) + ( 14 * Int(flowlayout.minimumInteritemSpacing))
    
        
        let widthConstraint = NSLayoutConstraint(item: collectionView!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 400)
//        widthConstraint.isActive = true
        
        print("widthConstraint i am trying to make: ", widthConstraint)
        print("ACUTAL WIDTH OF COLLECTION VIEW : ", collectionView.frame.width)
        
        if collectionViewCellWidth > 0  {
//            let borderView = VerticalBorderView(frame: CGRect(x: (collectionViewCellWidth + 2) + (collectionViewCellWidth + 5), y: 0, width: 2, height: Int(collectionViewWidth)))
//            collectionView.addSubview(borderView)
            createBorderLines()
        }
        

    }

    
    @IBAction func startGameButtonPressed(_ sender: UIButton) {
        alert2(title: "", message: "Everything set?")
    }
    
    func createBorderLines() {
        
        var positions: [(Int, Int)] = []

        for i in 0..<pvpGameCount {
            let one = i * 2 + 1
            let two = i * 2 + 2
            positions.append((one, two))
        }
        
        for position in positions {
            let first = position.0
            let second = position.1
        
            let borderView = VerticalBorderView(frame: CGRect(x: Int(getLinePosition(firstColumn: first, secondColumn: second) ?? 0), y: 0, width: 2, height: Int(collectionViewWidth)))
            collectionView.addSubview(borderView)
        }
    }
    
    func getLinePosition(firstColumn: Int, secondColumn: Int ) -> CGFloat? {
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let indexPath1 = IndexPath(item: firstColumn, section: 0)
            let indexPath2 = IndexPath(item: secondColumn, section: 0)
            
            if let attributes1 = layout.layoutAttributesForItem(at: indexPath1),
               let attributes2 = layout.layoutAttributesForItem(at: indexPath2) {
                let midpointX = (attributes1.frame.midX + attributes2.frame.midX) / 2.0
                return midpointX
            }
        }
        return nil
    }
    
    func createGrid() {
        num_stations = stationList!.count

//        if (num_stations < num_teams) {
//            alert(title:"We need more game stations!", message:"There are teams that don't have a game.")
//        }
//        if (num_teams < num_stations) {
//            alert(title:"We need more game stations!", message:"There are teams that don't have a game.")
//        }

        if (num_teams < 8) {
            team_smallerthaneight = true
            num_teams = 8
        }
        if (num_stations < 8) {
            station_smallerthaneight = true
            num_stations = 8
        }
        totalcolumn = max(num_teams, num_stations)
        totalrow = max(num_rounds, 8)
        
        num_cols = totalcolumn
        num_rows = totalrow
//        print(totalrow)
        for r in 0...(totalrow - 1) {
            var curr_row = [Int]()
            for t in 0...(totalcolumn - 1) {
                var number = (t + (r + 1))%totalcolumn
                if (number == 0) {
                    number = totalcolumn
                }
                curr_row.append(number)
            }
            grid.append(curr_row)
            curr_row.removeAll()
        }

        print("This is my grid: ", grid)
    }

}


extension AlgorithmViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int{
        return grid.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if ((num_stations < 8) && (num_teams < 8)) {
            return 8
        } else {
            return grid[section].count
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCell = collectionView.cellForItem(at: indexPath)
        let beforeSize = selectedCell?.contentView.frame.size
        if indexPathA == nil {
            // First selection
            indexPathA = indexPath
            
            let selectedCellA = collectionView.cellForItem(at: indexPathA!) as? AlgorithmCollectionViewCell
            originalcellAimage = selectedCellA?.algorithmCellBox.image
            originalcellAcolor = selectedCellA?.teamnumLabel.textColor

            selectedCellA?.makeCellSelected()

            
        } else if indexPathB == nil {
            // Second selection
            indexPathB = indexPath
            
            
            let selectedCellB = collectionView.cellForItem(at: indexPathB!) as? AlgorithmCollectionViewCell
            originalcellBimage = selectedCellB?.algorithmCellBox.image
            originalcellBcolor = selectedCellB?.teamnumLabel.textColor
            selectedCellB?.makeCellSelected()

        }
        
        if let indexPathA = indexPathA, let indexPathB = indexPathB {
            let itemA = grid[indexPathA.section][indexPathA.item]
            let itemB = grid[indexPathB.section][indexPathB.item]
            

            
            grid[indexPathA.section][indexPathA.item] = itemB
            grid[indexPathB.section][indexPathB.item] = itemA
            
            collectionView.performBatchUpdates({

                
                collectionView.moveItem(at: indexPathA, to: indexPathB)
                collectionView.moveItem(at: indexPathB, to: indexPathA)
            }, completion: { _ in
                // Swap completed
                print("swap completed:", self.grid)
                let selectedCellA = collectionView.cellForItem(at: indexPathA) as? AlgorithmCollectionViewCell
                let selectedCellB = collectionView.cellForItem(at: indexPathB) as? AlgorithmCollectionViewCell
                
                selectedCellA?.algorithmCellBox.image = self.originalcellAimage
                selectedCellA?.teamnumLabel.textColor = self.originalcellAcolor
                selectedCellB?.algorithmCellBox.image = self.originalcellBimage
                selectedCellB?.teamnumLabel.textColor = self.originalcellBcolor
                
                
                self.indexPathA = nil
                self.indexPathB = nil
            })
        }
    }
    

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlgorithmCollectionViewCell.identifier, for: indexPath) as? AlgorithmCollectionViewCell else {
            return UICollectionViewCell()
        }

        let teamnumberlabel = grid[indexPath.section][indexPath.item]
        
        print(teamnumberlabel)

        // start new code

        cell.configureAlgorithmNormalCell(cellteamnum : teamnumberlabel)
        
        //adding double tap to manually input cell number
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        cell.addGestureRecognizer(doubleTapGestureRecognizer)
        
        return cell
    }
    
    @objc func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        guard let cell = sender.view as? AlgorithmCollectionViewCell else { return }
        cell.makeCellOriginal()
        let alertController = UIAlertController(title: "Enter the team number", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.keyboardType = .numberPad
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            if let numberString = alertController.textFields?.first?.text,
               let number = Int(numberString) {
                
                cell.teamnumLabel.text = "\(number)"
            }
        }))
        present(alertController, animated: true, completion: nil)
        
        // deselects cell when it is double tapped.
        if let indexPaths = collectionView.indexPathsForSelectedItems, !indexPaths.isEmpty {
            let indexPath = indexPaths[0]
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }

}
        





extension AlgorithmViewController: StationList {
    func listOfStations(_ stations: [Station]) {
        self.stationList = stations
        self.num_stations = stations.count
        self.collectionView?.reloadData()
//        print("stationsList is empty? : " , stations.count , " and ", self.stationList!.count)
    }
    
}


extension AlgorithmViewController: GetHost {
    func getHost(_ host: Host) {
//        print("algorithm protocol")
        self.num_teams = host.teams
        self.num_rounds = host.rounds

        self.collectionView?.reloadData()
        
    }
}


extension AlgorithmViewController: UICollectionViewDelegateFlowLayout {


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (Int(collectionViewWidth - 20) - (16 * collectionViewCellSpacing)) / 8

        collectionViewCellWidth = width > 0 ? Int(width) : Int(width - 1)
//        collectionViewCellWidth = 30
        
//        collectionViewCellWidth = Int(collectionViewWidth / 11.5)
print("THIS IS MY COLLECTION VIEW CELL WIDTH AND VIEW WIDTH: ", collectionViewCellWidth, collectionViewWidth)
        
        return CGSize(width: collectionViewCellWidth, height: collectionViewCellWidth)

    }
    

//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//
//
//        return 2
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
////        return CGFloat(collectionViewCellWidth / 3)
//
//        return 2
//
//    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
//            let insets = flowLayout.sectionInset
//            print("Section insets: \(insets)")
//            return insets
//        }
//        return UIEdgeInsets.zero
//
//    }

//    func addviewsConstraints() {
////        print("HEYEYEYEYEY IM INNN")
//        let flowLayout = AlgorithmCustomFlowLayout()
//        collectionView.collectionViewLayout = flowLayout
//
//        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//
//        let contentSize = CGSize(width: collectionViewCellWidth * (num_cols + 1), height: collectionViewCellWidth * (num_rows + 1))
//
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        scrollView.contentSize = contentSize
//        collectionView.contentSize = contentSize
//        scrollView.isDirectionalLockEnabled = true
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//
//        NSLayoutConstraint.activate([
//            scrollView.widthAnchor.constraint(equalToConstant: collectionViewWidth),
//            scrollView.heightAnchor.constraint(equalToConstant: collectionViewWidth),
//            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            scrollView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//
//            collectionView.topAnchor.constraint(equalTo: scrollView.topAnchor),
//            collectionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
//            collectionView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
//            collectionView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
//            collectionView.widthAnchor.constraint(equalToConstant: contentSize.width),
//            collectionView.heightAnchor.constraint(equalToConstant: contentSize.height),
//            collectionView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
//            collectionView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor)
//        ])
//
//        print(collectionView.frame.size, "<- this is my collection view frame size! ", collectionView.contentSize, "<- This is my content Size!", scrollView.contentSize, "<- this is my scrollview content size!", scrollView.frame.size, " <- this is my scrollview frame size!")
//    }
}

extension AlgorithmViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if scrollView == collectionView {
//            print("------Collection view scrolling-----")
//        } else if scrollView == self.scrollView {
//            print("------Scroll view scrolling-------")
//        }
    }
}

extension AlgorithmViewController: UICollectionViewDropDelegate, UICollectionViewDragDelegate{
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = indexPath
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
    }
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard let destinationIndexPath = coordinator.destinationIndexPath else { return }
        
        coordinator.session.loadObjects(ofClass: NSArray.self as! any NSItemProviderReading.Type) { items in
            guard let sourceIndexPaths = items as? [IndexPath] else { return }
            
            collectionView.performBatchUpdates({
                var deleteIndexPaths = [IndexPath]()
                var insertIndexPaths = [IndexPath]()
                
                for sourceIndexPath in sourceIndexPaths {
                    if sourceIndexPath.section == destinationIndexPath.section {
                        if sourceIndexPath.item < destinationIndexPath.item {
                            deleteIndexPaths.append(sourceIndexPath)
                            insertIndexPaths.append(destinationIndexPath)
                        } else if sourceIndexPath.item > destinationIndexPath.item {
                            deleteIndexPaths.append(sourceIndexPath)
                            insertIndexPaths.append(destinationIndexPath)
                        }
                    } else {
                        // Moving to different section
                        deleteIndexPaths.append(sourceIndexPath)
                        insertIndexPaths.append(destinationIndexPath)
                    }
                }
                
                collectionView.deleteItems(at: deleteIndexPaths)
                collectionView.insertItems(at: insertIndexPaths)
                
            }, completion: nil)
            
            coordinator.drop(coordinator.items.first!.dragItem, toItemAt: destinationIndexPath)
        }
    }
}

