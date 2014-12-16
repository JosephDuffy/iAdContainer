//
//  AdvertContainerViewController.swift
//  Gathered
//
//  Created by Joseph Duffy on 16/12/2014.
//  Copyright (c) 2014 Yetii Ltd. All rights reserved.
//

import UIKit

class AdvertContainerViewController: UIViewController {
    var tableViewController: UITableViewController?
    var showingiAd = false
    var bannerBottomConstraint: NSLayoutConstraint?
	@IBOutlet weak var embeddingView: UIView?
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

    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.automaticallyAdjustsScrollViewInsets = false
		
		//Remove default constraints by IB because no constraints were defined in IB.
		view.removeConstraints(view.constraints())
		
		//Make sure embedding view is stretched to enclose entire view.
		view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[embeddingView]|", options: nil, metrics: nil, views: ["embeddingView": embeddingView!]))
		view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[embeddingView]|", options: nil, metrics: nil, views: ["embeddingView": embeddingView!]))

        if self.childViewControllers.count > 0 {
            if let tableViewController = self.childViewControllers[0] as? UITableViewController {
                self.tableViewController = tableViewController
                tableViewController.automaticallyAdjustsScrollViewInsets = false
                self.navigationItem.title = tableViewController.navigationItem.title
            }
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
	
	func recalcCorrectGuidesWithAdditionalBottomSpace(spaceHeight: CGFloat)
	{
		let bottomGuide = CGRectGetHeight(self.tabBarController!.tabBar.bounds);
		let topGuide = CGRectGetHeight(self.navigationController!.navigationBar.bounds) + CGRectGetHeight(UIApplication.sharedApplication().statusBarFrame);
		
		if let bottomConstraint = self.bannerBottomConstraint {
			let bannerTopOffset = bottomGuide + spaceHeight
			if bottomConstraint.constant != bannerTopOffset {
				println("Setting banner top offset to \(bannerTopOffset)")
				bottomConstraint.constant = -bannerTopOffset
			}
		}
		
		println("Bottom layout guide is \(bottomGuide)")
		let insets = UIEdgeInsetsMake(topGuide, 0, bottomGuide + spaceHeight, 0)
		self.updateTableViewInsetsIfRequired(insets)
	}

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        println("View did layout subviews")

        if self.showingiAd {
            if let bannerView = AppDelegate.instance.bannerView {
				
				bannerView.layoutIfNeeded()
				
                let bannerViewHeight = CGRectGetHeight(bannerView.frame)

				recalcCorrectGuidesWithAdditionalBottomSpace(bannerViewHeight)
				
				bannerView.superview?.setNeedsUpdateConstraints()
				bannerView.superview?.updateConstraintsIfNeeded()
            }
        }
		else {
			recalcCorrectGuidesWithAdditionalBottomSpace(0)
		}
    }

    private func updateTableViewInsetsIfRequired(insets: UIEdgeInsets) {
        if let tableView = self.tableViewController?.tableView {
            if !UIEdgeInsetsEqualToEdgeInsets(tableView.contentInset, insets) {
                println("Updating content insets to \(insets.top), \(insets.bottom)")
                tableView.contentInset = insets
            }
            if !UIEdgeInsetsEqualToEdgeInsets(tableView.scrollIndicatorInsets, insets) {
                println("Updating scroll insets to \(insets.top), \(insets.bottom)")
                tableView.scrollIndicatorInsets = insets
            }
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

                // Previously, this values was the height of the banner view, so that it starts off screen.
                // Setting this to 0 and then doing an animation makes it slide in from below
                bannerBottomConstraint.constant = self.bannerTopOffset
                bannersSuperview.setNeedsUpdateConstraints()
                UIView.animateWithDuration(animated ? 0.5 : 0, animations: { () -> Void in
                    // Calling layoutIfNeeded here will animate the layout constraint cosntant change made above
                    self.recalcCorrectGuidesWithAdditionalBottomSpace(CGRectGetHeight(bannerView.bounds))
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
