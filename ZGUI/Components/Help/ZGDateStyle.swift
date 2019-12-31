//
//  Corner.swift
//  cactus-teacher-ios
//
//  Created by zhaogang on 2018/4/9.
//

import UIKit

open class ZGDateStyle {
    
    /// 日期字符串转化为Date类型
    ///
    /// - Parameters:
    ///   - string: 日期字符串
    ///   - dateFormat: 格式化样式，默认为“yyyy-MM-dd HH:mm:ss”
    /// - Returns: Date类型
    open class func getTodayDateTime() -> String{
        let date = Date.init()
        let timeFormatter = DateFormatter.init()
        timeFormatter.dateFormat="yyyy-MM-dd"
        return timeFormatter.string(from: date)
    }
    
    open class func yearStringConvertDate(string:String, dateFormat:String="yyyy-MM-dd") -> Int {
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: string)
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year,.month,.day], from: date!)
        let newDate = dateComponents.year
        return newDate!
    }
    
    open class func monthStringConvertDate(string:String, dateFormat:String="yyyy-MM-dd") -> Int {
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let calendar = Calendar.current
        var newDate:Int?
        if  let date = dateFormatter.date(from: string)  {
            let dateComponents = calendar.dateComponents([.year,.month,.day], from: date)
            newDate = dateComponents.month
        }
        return newDate!
    }
    open class func monthStringConvertDate1(string:String, dateFormat:String="MM-dd") -> Int {
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "MM-dd"
        let calendar = Calendar.current
        var newDate:Int?
        if  let date = dateFormatter.date(from: string)  {
            let dateComponents = calendar.dateComponents([.month,.day], from: date)
            newDate = dateComponents.month
        }
        return newDate!
    }
    
    open class func dayStringConvertDate(string:String, dateFormat:String="yyyy-MM-dd") -> Int {
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let calendar = Calendar.current
        var newDate:Int?
        if  let date = dateFormatter.date(from: string)  {
            let dateComponents = calendar.dateComponents([.year,.month,.day], from: date)
            newDate = dateComponents.day
        }
        return newDate!
    }
    open class func dayStringConvertDate1(string:String, dateFormat:String="MM-dd") -> Int {
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "MM-dd"
        var newDate:Int?
        let calendar = Calendar.current
        if  let date = dateFormatter.date(from: string)  {
            let dateComponents = calendar.dateComponents([.month,.day], from: date)
            newDate = dateComponents.day
        }
        
        return newDate!
    }

}
