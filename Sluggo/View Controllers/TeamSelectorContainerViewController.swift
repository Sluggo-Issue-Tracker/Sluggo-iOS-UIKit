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
    private var failure: (() -> Void)?
    @IBOutlet var cancelButton: UIButton!

    init? (coder: NSCoder, identity: AppIdentity, completion: (() -> Void)?, failure: (() -> Void)?) {
        self.identity = identity
        self.completion = completion
        self.failure = failure
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

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let view = segue.destination as? TeamTableViewController {
            view.identity = self.identity
            view.completion = { team in
                self.identity.team = team
                self.dismiss(animated: true, completion: self.completion)
            }
        }
    }
    @IBAction func showPendingInvites(_ sender: Any) {
        if let view = storyboard?.instantiateViewController(identifier: "pendingInvites") {
            if let child = view.children[0] as? PendingInvitesViewController {
                child.identity = self.identity
            }
            self.present(view, animated: true, completion: nil)
        }
    }
    @IBAction func didCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: self.failure)
    }

}
