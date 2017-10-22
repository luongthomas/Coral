//
//  ViewController.swift
//  Coral
//
//  Created by Puroof on 10/21/17.
//  Copyright © 2017 ModalApps. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner
import LBTAComponents

class ViewController: UIViewController {
    var arrRes = [[String:AnyObject]]()
    
    var transactionId = ""
    let headers: HTTPHeaders = [
        "Authorization": "Basic ODAxMDg4Nzo4MUNMZzUwL1VWOEw=",
        "Accept": "application/json"
    ]
    
    let payButton: UIButton = {
        let button = UIButton(type: .system)
        button.sizeThatFits(CGSize(width: 200, height: 50))
        button.backgroundColor = .blue
        button.titleLabel?.text = "PAY"
        button.addTarget(self, action: #selector(showSpinner), for: UIControlEvents.touchUpInside)
        button.layer.zPosition = 1
        return button
    }()
    let fullImageView: UIImageView = {
        let image = UIImage(named: "cardBG.jpeg")
        let iv = UIImageView(image: image!)
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true

        return iv
        
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        view.backgroundColor = .red
        view.addSubview(fullImageView)
        fullImageView.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        
        view.addSubview(payButton)
        payButton.anchor(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 100, leftConstant: 50, bottomConstant: 20, rightConstant: 50, widthConstant: 0, heightConstant: 0)
        
        let myGroup = DispatchGroup()
        myGroup.enter()
        // avoid deadlocks by not using .main queue here
        DispatchQueue.global().async(group: myGroup, qos: DispatchQoS.background) {
            self.doAuth()
            myGroup.leave()
        }
        myGroup.wait()
        self.doCapture(transactionId: self.transactionId)

        
        
        
        
        print("Done")
    }
    
    func delay(seconds: Double, completion: @escaping () -> ()) {
        let popTime = DispatchTime.now() + Double(Int64( Double(NSEC_PER_SEC) * seconds )) / Double(NSEC_PER_SEC)
        
        DispatchQueue.main.asyncAfter(deadline: popTime) {
            completion()
        }
    }
    
    @objc func showSpinner() {
//        payButton.backgroundColor = .blue
//        payButton.isEnabled = false
        let spinnerView: UIView = {
            let v = UIView()
            v.frame = self.view.frame
            v.layer.zPosition = 2
            v.layoutMargins = UIEdgeInsetsMake(0, 0, 20, 0)
            return v
        }()
        
        self.view.addSubview(spinnerView)
        SwiftSpinner.useContainerView(spinnerView)
        
        
        
        // do something time consuming here
        SwiftSpinner.show("Processing your payment...")
        
        delay(seconds: 2.0, completion: {
            SwiftSpinner.show("Enjoying the weather..")
            
            
            self.delay(seconds: 2.0, completion: {
                SwiftSpinner.show("Listening to the song in the store..")
                
                self.delay(seconds: 2.0, completion: {
                    SwiftSpinner.show("Did you know there's events happening nearby?..")
                    
                    self.delay(seconds: 2.0, completion: {
                        SwiftSpinner.show("There's quite a lot of people walking nearby..")
                        
                        self.delay(seconds: 2.0, completion: {
                            SwiftSpinner.show("Listening to the song in the store..")
                          
                            self.delay(seconds: 2.0, completion: {
                                SwiftSpinner.sharedInstance.outerColor = UIColor.green.withAlphaComponent(0.5)
                                SwiftSpinner.show(progress: 100, title: "Thanks for waiting\n Payment Complete!").addTapHandler({
                                    print("tapped")
                                    SwiftSpinner.hide()
                                }, subtitle: "Tap to dismiss")
 
                            })
                        })
                    })
                })
            })
        })
        //payButton.layer.isHidden = true
//        payButton.isEnabled = true
//        payButton.backgroundColor = .green
//        spinnerView.removeFromSuperview()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func doAuth() {
        print("DoAuth")
        let parameters: Parameters = [
            "amount": 101.00,
            "card": [
                "number": "4444 3333 2222 1111",
                "cvv": "999",
                "expirationDate": "04/2019",
                "address": [
                    "line1": "123 Main St.",
                    "city": "Austin",
                    "state": "TX",
                    "zip": "78759"
                ]
            ],
            "developerApplication": [
                "developerId": 12345678,
                "Version": "1.2"
            ]
        ]
        
        let myGroup = DispatchGroup()
        myGroup.enter()
        Alamofire.request("https://gwapi.demo.securenet.com/api/Payments/Authorize", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if((response.result.value) != nil) {
                //print(response.result.value!)
                let swiftyJsonVar = JSON(response.result.value!)
                print(swiftyJsonVar)
                
                let transaction = swiftyJsonVar["transaction"] as JSON
                if let transactionId = transaction["transactionId"].rawString() {
                    //print("TransactionID: \(transactionId)")
                    self.transactionId = transactionId
                } else {
                    print("We can't get the transaction Id")
                }
            }
            print("Hello")
            //            let json = JSON(data: response.result.value as! Data)
            //            let transactionId = json[0].stringValue
            //            print("Transaction HERE!!: \(transactionId)")
            //            print("Request: \(String(describing: response.request))")   // original url request
            //            print("Response: \(String(describing: response.response))") // http url response
            //            print("Result: \(response.result)")                         // response serialization result
            //
            //            if let json = response.result.value {
            //                print("JSON: \(json)") // serialized json response
            //
            //            }
            
            //            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
            //                print("Data: \(utf8Text)") // original server data as UTF8 string
            //
            //
            //            }
            
            
//            self.view.backgroundColor = .blue
        }
    }
    
    
    
    func doCapture(transactionId: String) {
        // Everything is an array of arrays
        print("\n\nDo Capture\n\n")
        print(transactionId)
        let priorAuthParams: Parameters = [
            "transactionId": transactionId,
            "developerId": 12345678,
            "Version": "1.2",
            "extendedInformation": [
                "userDefinedFields": [
                    [
                        "udfName": "weather",
                        "udfValue": "sunny"
                    ],
                    [
                        "udfName": "currently playing song",
                        "udfValue": "Never Gunna Give You Up - Rick"
                    ],
                    [
                        "udfName": "temperature outside",
                        "udfValue": "72"
                    ],
                    [
                        "udfName": "temperature inside",
                        "udfValue": "68"
                    ],
                    [
                        "udfName": "nearest event",
                        "udfValue": "farmer's market"
                    ],
                    [
                        "udfName": "music volume",
                        "udfValue": "15db"
                    ],
                    [
                        "udfName": "current playing song genre",
                        "udfValue": "pop"
                    ],
                    [
                        "udfName": "number of foot traffic within the hour",
                        "udfValue": "45"
                    ],
                    [
                        "udfName": "current store scent",
                        "udfValue": "lavander"
                    ],
                    [
                        "udfName": "number of currently working employees in store",
                        "udfValue": "5"
                    ],
                    [
                        "udfName": "time spent in store before purchase",
                        "udfValue": "10 minutes"
                    ],
                ],
            ],
        ]
        
        Alamofire.request("https://gwapi.demo.securenet.com/api/Payments/Capture", method: .post, parameters: priorAuthParams, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result
            
            if let json = response.result.value {
                print("JSON: \(json)") // serialized json response
                
            }
            
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)") // original server data as UTF8 string
                
                
            }
            
//            self.view.backgroundColor = .yellow
        }
    }
}

