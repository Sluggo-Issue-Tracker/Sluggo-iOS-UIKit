//
//  TeamTableViewContainer.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 5/3/21.
//

import UIKit

class TeamSelectorContainerViewController: UIViewController {
    private var identity: AppIdentity
    private var completion: (() -> Void)?
    
    init? (coder: NSCoder, identity: AppIdentity, completion: (() -> Void)?) {
        self.identity = identity
        self.completion = completion
        super.init(coder: coder)
    }
    
    required init? (coder: NSCoder) {
        fatalError("must init with identity")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    
    // MARK: - Navigation

//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//        if let vc = segue.destination as? TeamTableViewController {
//            vc.identity = self.identity
//            vc.completion = { team in
//                self.identity.team = team
//                self.dismiss(animated: true, completion: self.completion)
//            }
//        }
//    }
    
    @IBSegueAction func launchTeamSelect(_ coder: NSCoder) -> TeamTableViewController? {
        let vc = TeamTableViewController(coder: coder)
        vc?.identity = self.identity
        vc?.completion = { team in
            self.identity.team = team
            self.dismiss(animated: true, completion: self.completion)
        }
        
        return vc
    }
    

}
