//
//  iAdContainerViewController.swift
//  iAdContainer
//
//  Created by Joseph Duffy on 16/12/2014.
//  Copyright (c) 2014 Yetii Ltd. All rights reserved.
//

import UIKit

class iAdContainerViewController: UIViewController {
    var scrollView: UIScrollView?
    var showingiAd = false
    var bannerTopConstraint: NSLayoutConstraint?
    private var _navigationController: UINavigationController?
    override var navigationController: UINavigationController? {
        get {
            return self._navigationController
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.automaticallyAdjustsScrollViewInsets = false

        if let childViewControllers = self.childViewControllers as? [UIViewController] {
            self.traverseViewControllersToFindScrollView(childViewControllers)
        }

        self.recalculateTopInset(false)
        let bottomInset = self.recalculateBottomInset(false)
        self.adjustBottomInsetIfRequired(bottomInset)
    }

    private func traverseViewControllersToFindScrollView(viewControllers: [UIViewController]) {
        for viewController in viewControllers {
            if self.scrollView == nil {
                if let viewControllerAsNavigationController = viewController as? UINavigationController {
                    self._navigationController = viewControllerAsNavigationController
                }
                if let scrollView = viewController.view as? UIScrollView {
                    self.scrollView = scrollView
                    viewController.automaticallyAdjustsScrollViewInsets = false
                    self.title = viewController.title
                    self.navigationItem.title = viewController.navigationItem.title
                    self.navigationItem.leftBarButtonItems = viewController.navigationItem.leftBarButtonItems
                    self.navigationItem.rightBarButtonItems = viewController.navigationItem.rightBarButtonItems

                    // Exit the for loop
                    break
                } else if let childViewControllers = viewController.childViewControllers as? [UIViewController] {
                    self.traverseViewControllersToFindScrollView(childViewControllers)
                }
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

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showiAds", name: "BannerViewDidLoadAd", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "hideiAds", name: "RemoveBannerAds", object: nil)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)

        NSNotificationCenter.defaultCenter().removeObserver(self)

        if self.showingiAd {
            self.hideiAds()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.recalculateTopInset(true)
        let bottomInset = self.recalculateBottomInset(false)
        self.adjustBottomInsetIfRequired(bottomInset)
    }

    func showiAds() {
        self.showiAds(true)
    }

    func showiAds(animated: Bool) {
        if !self.showingiAd {
            let delegate = UIApplication.sharedApplication().delegate as AppDelegate
            if let bannerView = delegate.bannerView {
                self.showingiAd = true

                if bannerView.superview != self.view.superview {
                    bannerView.removeFromSuperview()
                }

                if let bannersSuperview = self.view.superview {
                    // Added the view and the left/right constraints allow for the proper height
                    // to be returned when bannerView.frame.size.height is called (iOS 7 fix mainly)
                    bannersSuperview.addSubview(bannerView)
                    bannersSuperview.addConstraints([
                        NSLayoutConstraint(item: bannerView, attribute: .Left, relatedBy: .Equal, toItem: bannersSuperview, attribute: .Left, multiplier: 1, constant: 0),
                        NSLayoutConstraint(item: bannerView, attribute: .Right, relatedBy: .Equal, toItem: bannersSuperview, attribute: .Right, multiplier: 1, constant: 0),
                        ])
                    bannersSuperview.layoutIfNeeded()

                    let bannerTopConstraint = NSLayoutConstraint(item: bannerView, attribute: .Top, relatedBy: .Equal, toItem: bannersSuperview, attribute: .Bottom, multiplier: 1, constant: 0)
                    self.bannerTopConstraint = bannerTopConstraint
                    bannersSuperview.addConstraint(bannerTopConstraint)

                    bannersSuperview.layoutSubviews()
                    bannersSuperview.layoutIfNeeded()

                    // Previously, this values was the height of the banner view, so that it starts off screen.
                    // Setting this to 0 and then doing an animation makes it slide in from below
                    let bottomInset = self.recalculateBottomInset(false)
                    bannerTopConstraint.constant = bottomInset
                    bannersSuperview.setNeedsUpdateConstraints()
                    UIView.animateWithDuration(animated ? 0.5 : 0, animations: { () -> Void in
                        // Calling layoutIfNeeded here will animate the layout constraint cosntant change made above
                        self.adjustBottomInsetIfRequired(bottomInset)
                        bannersSuperview.layoutIfNeeded()
                    })
                } else {
                    println("self.view does not have a superview to add the ADBannerView to")
                }
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
                if bannerView.superview == self.view.superview {
                    bannerView.removeFromSuperview()
                }

                self.bannerTopConstraint = nil
                let bottomInset = self.recalculateBottomInset(false)
                self.adjustBottomInsetIfRequired(bottomInset)
            }
        }
    }

    private func recalculateTopInset(canUseTopLayoutGuide: Bool) {
        var topGuide: CGFloat = 0

        let statusBarHeight: CGFloat = min(CGRectGetHeight(UIApplication.sharedApplication().statusBarFrame), CGRectGetWidth(UIApplication.sharedApplication().statusBarFrame))
        topGuide += statusBarHeight

        if let navigationController = self.navigationController {
            let navigationBarHeight = CGRectGetHeight(navigationController.navigationBar.bounds)
            topGuide += navigationBarHeight
        }

        self.adjustTopInsetIfRequired(topGuide)
    }

    private func adjustTopInsetIfRequired(topInset: CGFloat) {
        if let scrollView = self.scrollView {
            var contentInsets = scrollView.contentInset
            contentInsets.top = topInset
            if !UIEdgeInsetsEqualToEdgeInsets(scrollView.contentInset, contentInsets) {
                scrollView.contentInset = contentInsets
            }

            var scrollIndicatorInsets = scrollView.scrollIndicatorInsets
            scrollIndicatorInsets.top = topInset
            if !UIEdgeInsetsEqualToEdgeInsets(scrollView.scrollIndicatorInsets, scrollIndicatorInsets) {
                scrollView.scrollIndicatorInsets = scrollIndicatorInsets
            }
        }
    }

    private func recalculateBottomInset(canUseBottomLayoutGuide: Bool) -> CGFloat {
        var bottomInset: CGFloat = 0

        if canUseBottomLayoutGuide {
            bottomInset = self.bottomLayoutGuide.length
        } else if let tabBarBounds = self.tabBarController?.tabBar.bounds {
            bottomInset = CGRectGetHeight(tabBarBounds)
        }

        if self.showingiAd {
            if let bannerView = AppDelegate.instance.bannerView {

                bannerView.layoutIfNeeded()

                let bannerViewHeight = CGRectGetHeight(bannerView.frame)

                bottomInset += bannerViewHeight
            }
        }

        return bottomInset
    }

    private func adjustBottomInsetIfRequired(bottomInset: CGFloat) {
        if let scrollView = self.scrollView {
            var contentInsets = scrollView.contentInset
            contentInsets.bottom = bottomInset
            if !UIEdgeInsetsEqualToEdgeInsets(scrollView.contentInset, contentInsets) {
                scrollView.contentInset = contentInsets
            }

            var scrollIndicatorInsets = scrollView.scrollIndicatorInsets
            scrollIndicatorInsets.bottom = bottomInset
            if !UIEdgeInsetsEqualToEdgeInsets(scrollView.scrollIndicatorInsets, scrollIndicatorInsets) {
                scrollView.scrollIndicatorInsets = scrollIndicatorInsets
            }
        }

        if let bottomConstraint = self.bannerTopConstraint {
            if bottomConstraint.constant != -bottomInset {
                bottomConstraint.constant = -bottomInset
            }
        }
    }

    private func updateTableViewInsetsIfRequired(insets: UIEdgeInsets) {
        if let scrollView = self.scrollView {
            if !UIEdgeInsetsEqualToEdgeInsets(scrollView.contentInset, insets) {
                scrollView.contentInset = insets
            }
            if !UIEdgeInsetsEqualToEdgeInsets(scrollView.scrollIndicatorInsets, insets) {
                scrollView.scrollIndicatorInsets = insets
            }
        }
    }
    
}
