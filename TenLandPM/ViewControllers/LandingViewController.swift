//
//  LandingViewController.swift
//  tenlandpm
//
//  Created by Caleb Clegg on 25/01/2022.
//
//

import AVKit
import UIKit

class LandingViewController: UIViewController {
    
    
    //declare video player
    var videoPlayer:AVPlayer?
    
    //actual video player manages the visual output
    var videoPlayerLayer: AVPlayerLayer?
    
    var isloaded = false
    
    
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        //set up video in the background
        setUpVideo()
        setUpElements()
        isloaded=true
    }
    //restart video
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)

            if isloaded {
                
                NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: nil)
                
                videoPlayer?.play()
                
            }
    
        }
        
        //end infitite loop of video
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            
            videoPlayer?.pause()
            
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
            
        }

        @objc func playerItemDidReachEnd(notification: Notification) {
            guard let playerItem = videoPlayer?.currentItem else {return}
            playerItem.seek(to: CMTime.zero, completionHandler: nil)
            videoPlayer?.play()
        }

        
    func setUpElements(){

        //style the elements for curved button
        Utilities.styleFilledButton(emailButton)
        Utilities.styleFilledButton(createAccountButton)

    }
        
        func setUpVideo(){
            
            NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        
            //get the path to the resource in the bundle
            let bundlePath =  Bundle.main.path(forResource: "landingvid", ofType: "mp4" )
            
            guard bundlePath != nil else {
                print("no bundlepath")
                return
            }
                
                //create a url from it
                
                let url = URL(fileURLWithPath: bundlePath!)
                
                
                //Create the video player item
                
                let item = AVPlayerItem(url: url)
                
                //create the player
                videoPlayer = AVPlayer(playerItem: item)
                
                //create the layer
                videoPlayerLayer = AVPlayerLayer(player: videoPlayer!)
                
                
                
                //adjust size and frame
                
                videoPlayerLayer?.frame = CGRect(x:
                 -self.view.frame.size.width*1.5, y:0, width:
                     self.view.frame.size.width*4, height:
                     self.view.frame.size.height)
                view.layer.insertSublayer(videoPlayerLayer!, at: 0)
                                                
                
                
                
                // Add to view and Play
                videoPlayer?.playImmediately(atRate: 0.3)
                

            // Do any additional setup after loading the view.
        }
        
    


    @IBAction func emailTapped(_ sender: Any) {
        emailButton.animateButton { success in
            self.performSegue(withIdentifier: "EmailVcSegue", sender: nil)
        }
    }
    
    @IBAction func createAccountButtonTapped(_ sender: Any) {
        createAccountButton.animateButton { success in
            self.performSegue(withIdentifier: "CreateAccountSegue", sender: nil)
        }
    }

}
