//
//  AppDelegate.swift
//  iAdTableView
//
//  Created by Joseph Duffy on 16/12/2014.
//  Copyright (c) 2014 Yetii Ltd. All rights reserved.
//

import UIKit
import iAd

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ADBannerViewDelegate {

    class var instance: AppDelegate {
        return UIApplication.sharedApplication().delegate as AppDelegate
    }

    var window: UIWindow?
    private(set) var bannerView: ADBannerView?
    var shouldShowBannerView: Bool {
        get {
            return self.bannerView != nil && self.bannerView!.bannerLoaded
        }
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.loadAdBannerView()

        return true
    }

    private func loadAdBannerView() {
        let bannerView = ADBannerView(adType: ADAdType.Banner)
        bannerView.delegate = self
        bannerView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.bannerView = bannerView
    }

    //MARK:- ADBannerViewDelegate methods

    func bannerViewDidLoadAd(banner: ADBannerView!) {
        NSNotificationCenter.defaultCenter().postNotificationName("BannerViewDidLoadAd", object: self)
    }

    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        NSNotificationCenter.defaultCenter().postNotificationName("BannerViewActionWillBegin", object: self)
        return true
    }

    func bannerViewActionDidFinish(banner: ADBannerView!) {
        NSNotificationCenter.defaultCenter().postNotificationName("BannerViewActionDidFinish", object: self)
    }

    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        println("Failed to get an iAd: \(error)")
    }

}

