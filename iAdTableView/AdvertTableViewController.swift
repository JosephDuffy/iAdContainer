//
//  AdvertTableViewController.swift
//  iAdTableView
//
//  Created by Joseph Duffy on 16/12/2014.
//  Copyright (c) 2014 Yetii Ltd. All rights reserved.
//

import UIKit

class AdvertTableViewController: ExampleTableViewController {

    var showingiAd = false
    var bannerBottomConstraint: NSLayoutConstraint?
    private var bannerTopOffset: CGFloat {
        get {
            var offset: CGFloat = 0
            if let tabBar = self.tabBarController?.tabBar {
                offset -= CGRectGetHeight(tabBar.frame)
            }

            if let bannerView = AppDelegate.instance.bannerView {
                let bannerViewHeight = bannerView.frame.size.height
                offset -= bannerViewHeight
            }

            return offset
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if AppDelegate.instance.shouldShowBannerView {
            self.showiAds(false)
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        let delegate = AppDelegate.instance
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showiAds", name: "BannerViewDidLoadAd", object: delegate)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "hideiAds", name: "RemoveBannerAds", object: delegate)
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)

        if self.showingiAd {
            self.hideiAds()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        println("View did layout subviews")

        if self.showingiAd {
            if let bannerView = AppDelegate.instance.bannerView {
                let bannerViewHeight = CGRectGetHeight(bannerView.frame)

                if let bottomConstraint = self.bannerBottomConstraint {
                    let bannerTopOffset = self.bottomLayoutGuide.length + bannerViewHeight
                    if bottomConstraint.constant != bannerTopOffset {
                        println("Setting banner top offset to \(bannerTopOffset)")
                        bottomConstraint.constant = -bannerTopOffset
                        bannerView.superview?.setNeedsUpdateConstraints()
                        bannerView.superview?.updateConstraintsIfNeeded()
                    }
                }

                println("Bottom layout guide is \(self.bottomLayoutGuide.length)")
                let insets = UIEdgeInsetsMake(self.topLayoutGuide.length, 0, self.bottomLayoutGuide.length + bannerViewHeight, 0)
                self.updateTableViewInsetsIfRequired(insets)

            }
        }
    }

    private func updateTableViewInsetsIfRequired(insets: UIEdgeInsets) {
        if !UIEdgeInsetsEqualToEdgeInsets(self.tableView.contentInset, insets) {
            println("Updating content insets to \(insets.top), \(insets.bottom)")
            tableView.contentInset = insets
        }
        if !UIEdgeInsetsEqualToEdgeInsets(self.tableView.scrollIndicatorInsets, insets) {
            println("Updating scroll insets to \(insets.top), \(insets.bottom)")
            tableView.scrollIndicatorInsets = insets
        }
    }

    func showiAds() {
        self.showiAds(true)
    }

    func showiAds(animated: Bool) {
        if !self.showingiAd {
            let delegate = UIApplication.sharedApplication().delegate as AppDelegate
            if let bannerView = delegate.bannerView {
                println("Showing iAd")
                self.showingiAd = true

                if (bannerView.superview != self.view) {
                    bannerView.removeFromSuperview()
                }

                let bannersSuperview = self.view.superview!

                // Added the view and the left/right constraints allow for the proper height
                // to be returned when bannerView.frame.size.height is called (iOS 7 fix mainly)
                bannersSuperview.addSubview(bannerView)
                bannersSuperview.addConstraints([
                    NSLayoutConstraint(item: bannerView, attribute: .Left, relatedBy: .Equal, toItem: bannersSuperview, attribute: .Left, multiplier: 1, constant: 0),
                    NSLayoutConstraint(item: bannerView, attribute: .Right, relatedBy: .Equal, toItem: bannersSuperview, attribute: .Right, multiplier: 1, constant: 0),
                    ])
                bannersSuperview.layoutIfNeeded()

                let bannerBottomConstraint = NSLayoutConstraint(item: bannerView, attribute: .Top, relatedBy: .Equal, toItem: bannersSuperview, attribute: .Bottom, multiplier: 1, constant: 0)
                self.bannerBottomConstraint = bannerBottomConstraint
                bannersSuperview.addConstraint(bannerBottomConstraint)

                bannersSuperview.layoutSubviews()
                bannersSuperview.layoutIfNeeded()

                let topInset = self.navigationController?.navigationBar.frame.size.height ?? 0
                let insets = UIEdgeInsetsMake(topInset, 0, -self.bannerTopOffset, 0)

                // Previously, this values was the height of the banner view, so that it starts off screen.
                // Setting this to 0 and then doing an animation makes it slide in from below
                bannerBottomConstraint.constant = self.bannerTopOffset
                bannersSuperview.setNeedsUpdateConstraints()
                UIView.animateWithDuration(animated ? 0.5 : 0, animations: { () -> Void in
                    // Calling layoutIfNeeded here will animate the layout constraint cosntant change made above
                    self.updateTableViewInsetsIfRequired(insets)
                    bannersSuperview.layoutIfNeeded()
                })
            } else {
                println("Cannot show iAd when bannerView is nil")
            }
        }
    }

    func hideiAds() {
        if self.showingiAd {
            self.showingiAd = false
            let delegate = UIApplication.sharedApplication().delegate as AppDelegate
            if let bannerView = delegate.bannerView {
                if bannerView.superview == self.view {
                    bannerView.removeFromSuperview()
                }
            }
        }
    }

}
