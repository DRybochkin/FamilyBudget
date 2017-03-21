//
//  StatisticPageViewController.swift
//  FamilyBudget
//
//  Created by Dmitry Rybochkin on 27.01.17.
//  Copyright © 2017 Dmitry Rybochkin. All rights reserved.
//

import UIKit
import os.log

class StatisticPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    var statistic: DOStatisticData!
    var pageControl: UIPageControl!
    private var pages: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()
        
        dataSource = self
        delegate = self

        /*Init pageControl in navigation bar*/
        if (navigationController != nil) {
            //navigationItem.title = "Семейный бюджет"
            let navController: UINavigationController = navigationController!
            
            let views = navController.navigationBar.subviews.filter { el in el is UIPageControl}
            
            if (views.count > 0) {
                pageControl = views[0] as! UIPageControl
            } else {
                let navBarSize: CGSize = navController.navigationBar.bounds.size
                let origin: CGPoint = CGPoint(x: navBarSize.width/2, y: navBarSize.height/2 )
                pageControl = UIPageControl(frame: CGRect(x: origin.x, y: origin.y, width: 0, height: 0))
                pageControl.pageIndicatorTintColor = UIColor.white
                pageControl.currentPageIndicatorTintColor = UIColor.red
                pageControl.hidesForSinglePage = true
                navController.navigationBar.addSubview(pageControl)
            }
        }
        setViewControllers([pages[0]], direction: .forward, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if (pageControl != nil) {
            pageControl.numberOfPages = pages.count

            guard let viewControllerIndex = pages.index(of: (viewControllers?.first)!) else {
                print("didFinishAnimating viewControllerIndex = nil")
                return
            }
            pageControl.currentPage = viewControllerIndex
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData() {
        pages = StatisticHelpers.createControllers(statistic, pageController: self)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.index(of: viewController) else {
            print("Before viewControllerIndex = nil")
            return nil
        }
        print("Before viewControllerIndex = %d", viewControllerIndex)
        let previousIndex = viewControllerIndex - 1

        guard previousIndex >= 0 else {
            return pages[pages.count-1]
        }
        
        guard pages.count > previousIndex else {
            return nil
        }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.index(of: viewController) else {
            print("After viewControllerIndex = nil")
            return nil
        }
        print("After viewControllerIndex = %d", viewControllerIndex)
        
        let nextIndex = viewControllerIndex + 1

        let orderedViewControllersCount = pages.count
        
        guard orderedViewControllersCount != nextIndex else {
            return pages[0]
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return pages[nextIndex]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        print("presentationCount")
        return pages.count
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed else { return }
        guard let viewControllerIndex = pages.index(of: (pageViewController.viewControllers?.first)!) else {
            print("didFinishAnimating viewControllerIndex = nil")
            return
        }
        pageControl.currentPage = viewControllerIndex
    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    //override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //    super.prepare(for: segue, sender: sender)
    //}
}
