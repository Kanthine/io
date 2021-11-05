import Foundation
import UIKit



class YLPeople {
   static var name : String = "Hello"
   private var firstName : String {
       willSet {
           print("新姓氏为 \(newValue)")
       }
       didSet {
           print("从前的姓氏为 \(oldValue)")
       }
   }
   private var secondName : String
   lazy var fullName : String = {
       return "\(firstName) \(secondName)"
   }()
init(firstName : String, secondName : String) {
       self.firstName = firstName
       self.secondName = secondName
   }
   
   static func desInfo() {
       print("这是一个类方法")
   }
}
