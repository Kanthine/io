//
//  OCP_Scene.swift
//  DesignPattern
//
//  Created by 苏沫离 on 2018/11/13.
//
// 开闭原则

import Foundation

/// 抽象书籍的基本属性
protocol IBaseBook {
    func getName() -> String
    func getPrice() -> Float
    func getAuthor() -> String
}

protocol IComputerBook : IBaseBook {
    func getScope() -> String
}

class BaseBook: IBaseBook {
    private let name : String
    private let author : String
    private let price : Float
    
    init(name:String, author:String, price:Float) {
        self.name = name
        self.price = price
        self.author = author
    }
    
    func getName() -> String {
        return name
    }
    
    func getPrice() -> Float {
        return price
    }
    
    func getAuthor() -> String {
        return author
    }
}

class ComputerBook: BaseBook, IComputerBook  {
    private let scope : String
    
    init(name: String, author: String, price: Float, scope: String) {
        self.scope = scope
        super.init(name: name, author: author, price: price)
    }
    
    func getScope() -> String {
        return self.scope
    }
}


class NovelBook_Promotion: BaseBook {
    override func getPrice() -> Float {
        return super.getPrice() * 0.6
    }
}



/// 持久层：书库
class BookStorage  {
    static func getBookList() -> [BaseBook] {
        var list : [BaseBook] = Array()
        for index in 1..<100 {
            let book = BaseBook(name: "name_\(index)" , author: "author_\(index)", price: Float(arc4random() % 999))
            list.append(book)
        }
        return list
    }
    static func getPromotionBookList() -> [NovelBook_Promotion] {
        var list : [NovelBook_Promotion] = Array()
        for index in 1..<100 {
            let book = NovelBook_Promotion(name: "name_\(index)" , author: "author_\(index)", price: Float(arc4random() % 999))
            list.append(book)
        }
        return list
    }
}

/// 业务层：书店
class Library {
    private let bookList = BookStorage.getPromotionBookList()
    func lookBooksInfo() {
        for book in bookList {
            print("\(book.getAuthor()) 撰写的 \(book.getName()) 售价为 \(book.getPrice())")
        }
    }
}

func OCP_Scene_Test() {
    let xinhua = Library()
    xinhua.lookBooksInfo()
}
