//
//  ViewController.swift
//  ScrollingVideo
//
//  Created by Nidhi Kulkarni on 7/12/21.
//

import UIKit
import AsyncDisplayKit


class ViewController: UIViewController, UIScrollViewDelegate {
    
    var tableNode: ASTableNode!
    var videoURLs : [String] = []
    var lastNode: VideoNode?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        navigationItem.title = "Feed"
        self.tableNode = ASTableNode(style: .plain)
        self.wireDelegates()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.insertSubview(tableNode.view, at: 0)
        self.applyStyle()
        self.tableNode.leadingScreensForBatching = 1.0;  // overriding default of 2.0
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.tableNode.frame = self.view.bounds;
    }

    func applyStyle() {
        self.tableNode.view.separatorStyle = .singleLine
        self.tableNode.view.isPagingEnabled = true
    }

    func wireDelegates() {
        self.tableNode.delegate = self
        self.tableNode.dataSource = self
    }
}


extension ViewController: ASTableDataSource {
    func tableNode(_: ASTableNode, numberOfRowsInSection _: Int) -> Int {
        return videoURLs.count;
    }

    func tableNode(_: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let url = videoURLs[indexPath.row]
        return {
            let node = VideoNode(with: URL(string: url)!)
            return node
        }
    }
}


extension ViewController: ASTableDelegate {
    func tableNode(_: ASTableNode, constrainedSizeForRowAt _: IndexPath) -> ASSizeRange {
        let width = UIScreen.main.bounds.size.width
        let min = CGSize(width: width, height: (UIScreen.main.bounds.size.height / 3) * 2)
        let max = CGSize(width: width, height: .infinity)
        return ASSizeRangeMake(min, max)
    }
}

extension ViewController {

    func shouldBatchFetch(for _: ASTableNode) -> Bool {
        return true
    }

    func tableNode(_: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
        // Get the next page of results
        retrieveNextPageWithCompletion { newPosts in
            self.insertNewRowsInTableNode(newURLs: newPosts)
            context.completeBatchFetching(true)
        }
    }
    
    func retrieveNextPageWithCompletion(block: @escaping ([String]) -> Void) {
        DispatchQueue.main.async {
            block(["http://vjs.zencdn.net/v/oceans.mp4", "http://vjs.zencdn.net/v/oceans.mp4"])
        }
    }

    func insertNewRowsInTableNode(newURLs: [String]) {
        guard !newURLs.isEmpty else {
            return
        }
        let section = 0
        var indexPaths: [IndexPath] = []
        let total = videoURLs.count + newURLs.count
        for row in videoURLs.count ... total - 1 {
            let path = IndexPath(row: row, section: section)
            indexPaths.append(path)
        }
        videoURLs.append(contentsOf: newURLs)
        tableNode.insertRows(at: indexPaths, with: .none)
    }
}
