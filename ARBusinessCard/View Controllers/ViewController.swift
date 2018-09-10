//
//  ViewController.swift
//  ARBusinessCard
//
//  Created by Josh Robbins on 10/08/2018.
//  Copyright © 2018 BlackMirrorz. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import MessageUI
import WebKit
import SideMenu
import Contacts

class ViewController: UIViewController {
 
    @IBOutlet var augmentedRealityView: ARSCNView!
    let augmentedRealitySession = ARSession()
    let configuration = ARImageTrackingConfiguration()
    var targetAnchor: ARImageAnchor?
    
    var businessCardPlaced = false
    var businessCard: BusinessCard!
    var socialLinkData: SocialLinkData?
    
    var menuShown = false
    
    //----------------------
    //MARK: - View LifeCycle
    //----------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //1. Format The SideMenu Which Will Be Used To Display The Associates WebSites
        SideMenuManager.default.menuWidth = self.view.bounds.width * 0.5
        SideMenuManager.default.menuPresentMode = .menuSlideIn
        SideMenuManager.default.menuFadeStatusBar = false
        
        //2. Setup The Business Card
        setupBusinessCard()
   
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !menuShown { setupARSession() }
        socialLinkData = nil
    }
    
    //---------------
    //MARK: - ARSetup
    //---------------
    
    /// Configures & Runs The ARSession
    func setupARSession(){
        
        //1. Setup Our Tracking Images
        guard let trackingImages =  ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else { return }
        configuration.trackingImages = trackingImages
        configuration.maximumNumberOfTrackedImages = 1
        
        //2. Configure & Run Our ARSession
        augmentedRealityView.session = augmentedRealitySession
        augmentedRealitySession.delegate = self
        augmentedRealityView.delegate = self
        augmentedRealitySession.run(configuration, options: [.resetTracking, .removeExistingAnchors])
      
    }
    
    /// Create A Business Card
    func setupBusinessCard(){
        
        //1. Create Our Business Card
        let businessCardData = BusinessCardData(firstName: "Kenta",
                                                surname: "Urata",
                                                position: "Software Engineer",
                                                company: "Yamanashi Chuo Bank",
                                                address: BusinessAddress(street: "2-11,chuou",
                                                                         city: "Kofu", state: "Yamanashi", postalCode: "4000032",
                                                                         coordinates: (latittude: 35.662446, longtitude: 138.573786)),
                                                website: SocialLinkData(link: "https://www.blackmirrorz.tech", type: .Website),
                                                phoneNumber: "+81552268212",
                                                email: "y169540@yamanashichuobank.co.jp",
                                                stackOverflowAccount: SocialLinkData(link: "https://stackoverflow.com/users/8816868/josh-robbins", type: .StackOverFlow),
                                                githubAccount: SocialLinkData(link: "https://github.com/quomob", type: .GitHub))

        //2. Assign It To The Business Card Node
        businessCard = BusinessCard(data: businessCardData, cardType: .noProfileImage)
       
    }
    
    //------------------
    //MARK: - Navigation
    //------------------
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "webViewer",
            let sideMenu = segue.destination as? UISideMenuNavigationController,
            let mapWebView = sideMenu.children.first as? MapWebViewController{
            
            sideMenu.sideMenuDelegate = self
            
            if let validLink = socialLinkData{
         
                switch validLink.type{
                    
                case .Website:
                    mapWebView.webAddress = businessCard.cardData.website.link
                    mapWebView.navigationItem.title = "YamanashiChuoBank"
                case .StackOverFlow:
                    mapWebView.webAddress = businessCard.cardData.stackOverflowAccount.link
                    mapWebView.navigationItem.title = businessCard.cardData.stackOverflowAccount.type.rawValue
                case .GitHub:
                    mapWebView.webAddress = businessCard.cardData.githubAccount.link
                    mapWebView.navigationItem.title = businessCard.cardData.githubAccount.type.rawValue
                }
                
            }else{
               
                mapWebView.navigationItem.title = "Location"
                mapWebView.isWebsite = false
                mapWebView.latittude = businessCard.cardData.address.coordinates.latittude
                mapWebView.longtitude = businessCard.cardData.address.coordinates.longtitude
            }

        }
    }
}
