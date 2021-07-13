//
//  VideoNode.swift
//  ScrollingVideo
//
//  Created by Nidhi Kulkarni on 7/12/21.
//

import AsyncDisplayKit

class VideoNode: ASCellNode {
    // Used to play the HLS video
    var videoNode: ASVideoNode

    init(with url: URL) {
        videoNode = ASVideoNode()

        super.init()
        videoNode.shouldAutoplay = true
        videoNode.shouldAutorepeat = true
        // The player should preserve the video’s aspect ratio
        videoNode.gravity = AVLayerVideoGravity.resizeAspectFill.rawValue

        // Since nodes are not created on the main thread, make sure to set the asset on the main thread
        DispatchQueue.main.async {
            self.videoNode.asset = AVAsset(url: url)
        }

        addSubnode(videoNode)
    }
    
    override func layoutSpecThatFits(_: ASSizeRange) -> ASLayoutSpec {
        let ratio = UIScreen.main.bounds.height / UIScreen.main.bounds.width
        // Lays out a component at a fixed aspect ratio which can scale
        return ASRatioLayoutSpec(ratio: ratio, child: videoNode)
    }
}
