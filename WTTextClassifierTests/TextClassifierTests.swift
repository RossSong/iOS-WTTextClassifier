//
//  TextClassifierTests.swift
//  testBrainCore
//
//  Created by RossSong on 2017. 9. 1..
//  Copyright © 2017년 wanted. All rights reserved.
//

import XCTest
@testable import WTTextClassifier

class TotalTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testPredict() {
        let company = "(주) (주)가 (주)가나 (주)가나다 (주)가나다라 (주)엠피알디 (주)교보정보시스템(일본) BBDOkorea BNCS CDR Associates Capital CJ 오쇼핑 Wantedlab wantedlab 원티드 Google google 중공업(주) 삼성전자 구글 선데이토즈 레스토랑 센터 (주)투비소프트 (주)뱅크타운 (사)대한전자공학회 공병단 휴맥스 비행단 여단 부대 사무소 법인 연구소 대대 연대 연합 흥국화재 삼성화재 현대카드 삼성카드 Co,.Ltd (주)디자인 (주)더블유 (주)디파이 (주)한글 금고 은행"
        
        let duty = "Developer developer Designer designer QA qa Manager manager 개발자 디자이너 영업 기획 iOS ios Android android Backend backend"
        
        let tel = "123 - 010 2279 2279"
        let email = "@ .COM .com .CO .co .CO.KR .co.kr"
        let address = "서울특별시 서초구 Building building 빌딩 Tower tower 타워 Floor floor 층"
    
        let dictTrain = ["company" : company,
                         "tel" : tel,
                         "email": email,
                         "duty": duty,
                         "address": address]
        
        let classifier = TextClassifier()
        classifier.train(dictTrain)

        let dictTest = ["company" : "현대중공업", "tel" : "010-6554", "email": "test@gmail.com", "duty": "Designer"]
        
        XCTAssert("company" == classifier.predict(dictTest["company"]!))
        XCTAssert("tel" == classifier.predict(dictTest["tel"]!))
        XCTAssert("email" == classifier.predict(dictTest["email"]!))
        XCTAssert("duty" == classifier.predict(dictTest["duty"]!))
        XCTAssert("company" == classifier.predict("새마을금고"))
        XCTAssert("company" == classifier.predict("국민은행"))
        XCTAssert("email" == classifier.predict("hgsong@wantedlab.com"))
        
        debugPrint(classifier.predict("02 032"))
        debugPrint(classifier.predict("abc@abc.com"))
        debugPrint(classifier.predict("hgsong@wantedlab.com"))
    }
}
