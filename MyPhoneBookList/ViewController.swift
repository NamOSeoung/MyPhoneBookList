//
//  ViewController.swift
//  MyPhoneBookList
//
//  Created by 남오승 on 2020/03/26.
//  Copyright © 2020 남오승. All rights reserved.
//

import UIKit
import Contacts //연락처 데이터 Class모음
import ContactsUI //이미 구현된 연락처 UI 수록

//ios8 까지는 AddressBook 프레임워크를 이용해서 시스템의 주소록 데이터베이스에 액세스 할 수 있었는데, ios9에서는 이 프레임워크 자체가 deprecated되었다.
//대신 연락처를 액세스하는 별도의 프레임워크인 Contacts가 신설되어서 해당 프레임워크를 사용해야 한다.

class ViewController: UIViewController {
    let store = CNContactStore()
    //CNContactStore인스턴스 : 연락처 저상소에 액세스 할 수 있는 추상화 된 인터페이스를 제공한다. (객체 생성시에는 별도의 파라메터가 필요하지 않다.)
    
    var contacts = [CNContact]()
    
    override func viewDidLoad() {
        super.viewDidLoad() //--> viewDidLoad()함수는 뷰가 메모리에 올라갔을때, 1번 호출된다.
        
        // viewDidLoad상태(뷰의 화면이 로드되었을 때 )에는 모달뷰(Aleat, Toast등)를 띄울 수 없다.
        // 이 시점에서 인스턴스 변수를 인스턴스화 하고 뷰 컨트롤러의 전체 수명주기 동안 존재할 뷰를 빌드하려고 한다.
        // --> 즉, 이 시점에서는 뷰 컨트롤러가 완성되지 않았다는 뜻이다.
        // 그렇기에 뷰 컨트롤러가 완성되지 않은 시점이기에 Modal(Toast, Alert)을 띄울래야 띄울 수가 없다.
        // 뷰가 생성될 때 Modal(Toast, Alert) 을 띄워주고 싶으면 override func viewDidAppear(_ animated: Bool){} 함수를 이곳에 작성하면 된다.
        //
        
        //viewDidAppear() 함수는 뷰가 실제로 표시될 때마다 호출된다.
        //따라서 이 함수가 호출 된 시점의 뷰 컨트롤러는 완성 된 상태이다. 따라서 Modal(Toast, Alert)의 호출이 가능 해 진다.
        //하지만, 이 함수는 뷰가 표시될때마다 호출되기 때문에, 뷰가 시작되고 최초 1번만 실행해야하는 코드는 별도의 처리가 필요하다.
        //쉽게말해, Modal을 호출하고, 해당 모달뷰가 사라진 후 다시 원래의 뷰로 돌아오면, 뷰가 다시 표시되기 때문에 viewDidAppear이 한번 더 호출될 수 있다.
        
        //결론적으로 Modal을 호출하는 코드가 아니며, 최초 1번만 실행해야 할 코드라면 viewDidLoad()함수 내부에 작성하는것이 옳다.
    }
    
    @IBAction func getPhoneNumberAccess(_ sender: Any) {
                //연락처를 불러오기 위한 가장 좋은 방법은
                //'enumerateContactsWithFetchRequest:error:usingBlock:' 을 쓰는 것이다.
                //이를위해서는 'NSContactFetchRequest' 객체가 필요한데, 별다른 옵션이 없으면 전체 연락처를 가져온다.
                //대신, 모든 연락처의 모든 키를 가져오는 것은 아니며, 사용을 원하는 모든 키를 명시해야 한다.
        
                let keys = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactPhoneNumbersKey as CNKeyDescriptor]
                let request = CNContactFetchRequest(keysToFetch: keys)
                        
        //         var numbers:Array<String> = Array<String>()
                
                store.requestAccess(for: .contacts) { (granted, err) in //requestAccess 자체가 해당 권한에 접근하기 위하여 사용함. (store는 권한 체크를 위한 객체)
                    // 권한 허용시                                         //request()안에 파라메터는 어떤 권한테 접근 할 것인지 상세 권한을 표기해 주는 듯하다.
                    if granted {                         //contact = 연락처이고 예를들어 카메라 권한의 경우 requestAccess(forMediaType: AVMediaTypeVideo)이다.
                        do {
                            try self.store.enumerateContacts(with: request, usingBlock: { (contact, stop) in
                                // 이름은 있으나 폰번호가 없는 경우
                                if !contact.phoneNumbers.isEmpty {
                                    self.contacts.append(contact)
                                }
                            })
                            for info in self.contacts {
                                guard let phone = info.phoneNumbers[0].value.value(forKey: "digits") else {
                                    return
                                }
                                let name = info.familyName + " " + info.givenName
                                // 불러와진 이름과 전화번호
                                // 앞서 선언한 numbers 배열에 넣어서 추후 사용을 한다
                                print(phone)
                                print(name)
                                //self.numbers.append("\(phone)")
                            }
                            
                             let toast = UIAlertController(title: "알림111", message: "완료", preferredStyle: .alert)
                                                                  toast.addAction(UIAlertAction(title: "확인", style: .default, handler: {
                                                                      (Action) -> Void in
                                                                    let settingsURL = NSURL(string: UIApplication.openSettingsURLString)! as URL
                                                                  //    UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                                                                  }))
                                                                  self.present(toast, animated: true, completion: nil)

                            // call number finder
                            // 전화번호를 통한 어떤 것을 할 것인지, 마쳐진 이후 사용하면 된다.
                            //friendFindByNumber(numbers: self.numbers)
                        } catch {
                            print("unable to fetch contacts")
                        }
                    } else {
                        print("거부")
//                        let toast = UIAlertController(title: "알림", message: "주소록 권한이 필요합니다.", preferredStyle: .alert)
//                                      toast.addAction(UIAlertAction(title: "확인", style: .default, handler: {
//                                          (Action) -> Void in
//                                        let settingsURL = NSURL(string: UIApplication.openSettingsURLString)! as URL
//                                          UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
//                                      }))
//                                      self.present(toast, animated: true, completion: nil)
                         //권한 비허용 시
                        let alert = UIAlertController(title: "친구를 찾아드립니다", message: "전화번호부 접근 허용을 해주시면 전화번호부에 등록된 친구를 폴리텔리에서 찾아드립니다.", preferredStyle: .alert)
                        let actionL = UIAlertAction(title: "허용", style: .default) { (action) in
                            alert.dismiss(animated: true, completion: nil)
                            let settingsURL = NSURL(string: UIApplication.openSettingsURLString)! as URL
                            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                        }
                        let actionC = UIAlertAction(title: "취소", style: .cancel) { (action) in
                            alert.dismiss(animated: true, completion: nil)
                        }
                        alert.addAction(actionC)
                        alert.addAction(actionL)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                
    }
    

}

