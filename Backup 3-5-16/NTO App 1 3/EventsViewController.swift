//
//  EventsViewController.swift
//  NTO App 1
//
//  Created by Michael Zetune on 1/21/15.
//  Copyright (c) 2015 Michael Zetune. All rights reserved.
//

import UIKit

class EventsViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    
    var site = "https://www.google.com/calendar/embed?src=22vc46ct8lqo3v5h9mdi8s5h8o@group.calendar.google.com&ctz=America/Chicago&mode=AGENDA"
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.sendRequest()
        
        }
    
        
    func sendRequest() {
        
        let url = NSURL(string: site)
        let request = NSURLRequest(URL: url!)
        webView.loadRequest(request)
    }
        
        
    @IBAction func backButtonPressed(sender: AnyObject) {
        
        sendRequest()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
