//
//  VideoNode.swift
//  ScrollingVideo
//
//  Created by Nidhi Kulkarni on 7/12/21.
//

import AsyncDisplayKit
import MUXSDKStats


class VideoCellNode: ASCellNode {
    // Used to play the HLS video
    var videoNode: ASVideoNode
    var playerBinding: MUXSDKPlayerBinding?
    var playerName: String?
    
    init(with url: URL, playerName: String) {
        self.videoNode = ASVideoNode()
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
        videoNode.delegate = self;
        
    }
    
    override func layoutSpecThatFits(_: ASSizeRange) -> ASLayoutSpec {
        let ratio = UIScreen.main.bounds.height / UIScreen.main.bounds.width
        // Lays out a component at a fixed aspect ratio which can scale
        return ASRatioLayoutSpec(ratio: ratio, child: videoNode)
    }
}

extension VideoCellNode: ASVideoNodeDelegate {
    func videoNode(_ videoNode: ASVideoNode, willChange state: ASVideoNodePlayerState, to toState: ASVideoNodePlayerState) {
        if (toState == .playing && self.playerBinding == nil) {
            DispatchQueue.main.async {
                // initialize the Mux SDK
                self.playerName = UUID().uuidString
                let playerData = MUXSDKCustomerPlayerData(environmentKey: "YOUR_ENV_KEY_HERE");
                // insert player metadata
                let videoData = MUXSDKCustomerVideoData();
                // insert video metadata
                // if you're using AVPlayerLayer instead of AVPlayerViewController use this instead:
                self.playerBinding = MUXSDKStats.monitorAVPlayerLayer(videoNode.playerLayer!, withPlayerName: self.playerName!, playerData: playerData!, videoData: videoData)!;
            }
        }
        if (toState == .finished) {
            MUXSDKStats.destroyPlayer(self.playerName!)
            self.playerBinding = nil
            self.playerName = nil
        }
    }
}
