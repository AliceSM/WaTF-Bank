import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var bgState = false
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        bgState = false
        var from = ""
        var to = ""
        var amount = ""
        if !JailbreakDetection().isJail() {
            if url.scheme! == "watf" && url.host! == "transfer" {
                let q = url.query?.components(separatedBy: "&")
                if q?.count == 3 {
                    for i in q! {
                        let j = i.components(separatedBy: "=")
                        if j[0] == "fromAccount" {
                            from = j[1]
                        }
                        else if j[0] == "toAccount" {
                            to = j[1]
                        }
                        else if j[0] == "amount" {
                            amount = j[1]
                        }
                        else {
                            return false
                        }
                    }
                    if let token = KeyChain.load("token") {
                        let input = ["accountNo":from,"toAccountNo":to,"amount":amount,"token":token]
                        Http().post(input, "transfer", completionHandler: {(re: [String:Any]) in
                            var res = re as! [String:String]
                            let t = self.window?.rootViewController!.storyboard!.instantiateViewController(withIdentifier: "TransferResult") as! TransferResult
                            if res["message"] == "Success" {
                                t.labelV = "Transfer Succeeded"
                            }
                            else {
                                t.labelV = "Transfer Failed"
                            }
                            t.fromAccountV = "From : "+res["username"]!
                            t.toAccountV = "To : "+res["tel"]!
                            t.amountV = "Amount : "+res["amount"]!
                            self.window?.rootViewController!.present(t, animated: true, completion: nil)
                        })
                    }
                }
            }
        }
        else {
            Util.changeView((self.window?.rootViewController)!, "Jailbreak")
        }
        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if let ip = KeyChain.load("ip") {
            Http.setIp(ip)
        }
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        bgState = true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        if bgState {
            bgState = false
            if JailbreakDetection().isJail() {
                self.window?.rootViewController = self.window?.rootViewController!.storyboard!.instantiateViewController(withIdentifier: "Jailbreak")
            }
            else if KeyChain.load("token")==nil {
                self.window?.rootViewController = self.window?.rootViewController!.storyboard!.instantiateViewController(withIdentifier: "Login")
            }
            else {
                self.window?.rootViewController = self.window?.rootViewController!.storyboard!.instantiateViewController(withIdentifier: "Pin")
            }
        }
    }
}

