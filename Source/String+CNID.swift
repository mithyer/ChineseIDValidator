//
//  String+CNID.swift
//  ChineseIDValidator
//
//  Created by ray on 2017/12/29.
//  Copyright © 2017年 ray. All rights reserved.
//

import Foundation


extension String {
    
    // typeOption: 默认15和18位都验证
    // district: 默认地区验证只验证到一级行政区，最高到三级行政区
    // 这里只填写了一级和部分二三级，其他需自行填写: http://www.stats.gov.cn/tjsj/tjbz/xzqhdm/，一级填前2位，二级填前4位，三级填前6位， 此表最好从服务端获取
    public func CNIDValidator(withTypeOption typeOption: CNID.IDTypeOption = CNID.IDTypeOption.both,
                       toDistrict district: CNID.DistrictType = .district1,
                       withForm form: [String: [String: String]] = CNID.districtForm) -> CNID.Validator {
        return CNID.Validator.init(self, withTypeOption: typeOption, toDistrict: district, withForm: form)
    }
    
}


public class CNID {
    
    public enum IDType: Int {
        case old15 = 1
        case new18 = 2
    }
    
    public struct IDTypeOption : OptionSet {
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        public let rawValue: Int
        public static let old15 = IDTypeOption(rawValue: IDType.old15.rawValue)
        public static let new18 = IDTypeOption(rawValue: IDType.new18.rawValue)
        public static let both = IDTypeOption(rawValue: IDType.new18.rawValue | IDType.old15.rawValue)
    }
    
    public enum DistrictType: String {
        case district1 = "d1"
        case district2 = "d2"
        case district3 = "d3"
    }
    
    public enum Gender {
        case male, female
    }
    
    public struct Info {
        public let type: IDType
        public let districtInfo: [DistrictType : (code: String, name: String)]
        public let birthDayInfo: (dateString: String, date: Date)
        public let gender: Gender
        
        var sequenceCode: String
        init(type: IDType, districtInfo: [DistrictType : (code: String, name: String)], birthDayInfo: (dateString: String, date: Date), sequenceCode: String) {
            self.type = type
            self.districtInfo = districtInfo
            self.birthDayInfo = birthDayInfo
            self.sequenceCode = sequenceCode
            self.gender = Int(String(sequenceCode.last!))!%2 == 1 ? .male : .female
        }
    }
    
    public class Validator {
        
        let id: String
        private(set) var isValid: Bool = false
        private(set) var info: Info?
        
        init(_ id: String, withTypeOption typeOption: IDTypeOption = IDTypeOption.both, toDistrict district: CNID.DistrictType = .district1, withForm form: [String: [String: String]] = CNID.districtForm) {
            
            self.id = id
            guard let type = id.idType, typeOption.contains(IDTypeOption(rawValue: type.rawValue)) else {
                return
            }
            guard let districtInfo = id.districtInfo(withForm: form), districtInfo.keys.contains(district) else {
                return
            }
            guard let birthdayInfo = id.birthDayInfo(ofType: type) else {
                return
            }
            guard let sequenceCode = id.sequenceCode(ofType: type) else {
                return
            }
            if type == .old15 {
                self.isValid = true
                self.info = Info(type: type, districtInfo: districtInfo, birthDayInfo: birthdayInfo, sequenceCode: sequenceCode)
                return
            }
            guard let validateCode = id.validateCode(ofType: type) else {
                return
            }
            guard let validateRes = id.resCode(), validateCode == validateRes else {
                return
            }
            self.isValid = true
            self.info = Info(type: type, districtInfo: districtInfo, birthDayInfo: birthdayInfo, sequenceCode: sequenceCode)
        }
        
    }
    
    public class Faker {
        
        let id: String
        init(_ typeOption: CNID.IDTypeOption = .both, withForm form: [String: [String: String]] = CNID.districtForm) {
            let type: CNID.IDType = {
                switch typeOption {
                case .old15: return CNID.IDType.old15
                case .new18: return CNID.IDType.new18
                default: return arc4random()%2 == 0 ? .old15 : .new18
                }
            }()
            let codes = form[CNID.DistrictType.district3.rawValue]!.keys
            let idx: Int = Int(arc4random()%UInt32(codes.count))
            let districtCode = codes[codes.index(codes.startIndex, offsetBy: idx)]
            let date = Date.init(timeIntervalSinceNow: -Double(arc4random()%(100 * 365 * 24 * 3600)))
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd"
            let dateStr = formatter.string(from: date)
            let sequence = String.init(format: "%.3d", arc4random()%999)
            if type == .old15 {
                self.id = districtCode + dateStr.subString(ofRange: NSRange(location: 2, length: 6))! + sequence
                return
            }
            var digits = districtCode + dateStr + sequence
            let last = digits.resCode()!
            digits += last
            self.id = digits
        }
        
    }
    
    public static let districtForm = [
        "d1":
            ["11": "北京", "12": "天津", "13": "", "14": "", "15": "",
             "21": "", "22": "", "23": "",
             "31": "", "32": "", "33": "", "34": "", "35": "", "36": "", "37": "",
             "41": "", "42": "", "43": "", "44": "", "45": "", "46": "",
             "50": "", "51": "", "52": "", "53": "", "54": "",
             "61": "", "62": "", "63": "", "64": "", "65": "",
             "71": "",
             "81": "", "82": "",
             "91": ""],
        "d2":
            ["1101": "市辖区", "1201": "市辖区"],
        "d3":
            ["110101": "东城区", "120101": "和平区"]
    ]
}


extension String {
    
    func subString(ofRange range: NSRange) -> String? {
        if range.location + range.length > self.count {
            return nil
        }
        let startIdx = self.index(self.startIndex, offsetBy: range.location)
        let endIdx = self.index(startIdx, offsetBy: range.length)
        return String(self[startIdx..<endIdx])
    }
    
    var idType: CNID.IDType? {
        switch self.count {
        case 15:
            return .old15
        case 18:
            return .new18
        default:
            return nil
        }
    }

    
    func districtInfo(withForm form: [String: [String: String]] = CNID.districtForm) -> [CNID.DistrictType : (code: String, name: String)]? {
        let range = NSRange(location: 0, length: 6)
        guard let districtCode = self.subString(ofRange: range) else {
            return nil
        }
        var districtInfo = [CNID.DistrictType : (code: String, name: String)]()

        for (district, dic) in form {
            for (code, name) in dic {
                if districtCode.hasPrefix(code) {
                    districtInfo[CNID.DistrictType(rawValue: district)!] = (code, name)
                    break
                }
            }
        }
        return districtInfo.count > 0 ? districtInfo : nil
    }
    
    func birthDayInfo(ofType type: CNID.IDType) -> (dateString: String, date: Date)? {
        let range = NSRange(location: 6, length: type == .old15 ? 6 : 8)
        guard var dateStr = self.subString(ofRange: range) else {
            return nil
        }
        if type == .old15 {
            dateStr = "19" + dateStr
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        formatter.locale = Locale(identifier: "zh_Hans")
        let date = formatter.date(from: dateStr)
        return nil != date ? (dateStr, date!) : nil
    }
    
    func sequenceCode(ofType type: CNID.IDType) -> String? {
        let range = NSRange(location: type == .old15 ? 12 : 14, length: 3)
        return self.subString(ofRange: range)
    }
    
    func validateCode(ofType type: CNID.IDType) -> String? {
        guard let range = type == .new18 ? NSRange(location: 17, length: 1) : nil else {
            return nil
        }
        return self.subString(ofRange: range)
    }
    
    func resCode() -> String? {
        let weight = [7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2]
        guard let str = self.subString(ofRange: NSRange(location: 0, length: weight.count)) else {
            return nil
        }
        let validateForm = ["1", "0", "X", "9", "8", "7", "6", "5", "4", "3", "2"]
        var sum = 0
        for (idx, value) in str.enumerated() {
            sum += Int(String(value))! * weight[idx]
        }
        return validateForm[sum%validateForm.count]
    }
    
}
