//
//  TextClassifier.swift
//  testBrainCore
//
//  Created by RossSong on 2017. 9. 2..
//  Copyright © 2017년 wanted. All rights reserved.
//

import Foundation

class TextClassifier {
    var model: SVMModel?
    var arrayClass: Array<String>?
    var arrayTotalGram = Array<String>()
    var arrayIDF: Array<Int>?
    
    init() {
        //  Create an SVM classifier and train
        model = SVMModel(problemType: .C_SVM_Classification, kernelSettings:
            KernelParameters(type: .RadialBasisFunction, degree: 0, gamma: 0.5, coef0: 0.0))
    }
    
    func getF(_ frequency:Int, countOfGramInDocument: Int) -> Double {
        //단어내에 term(한글자, 두글자)가 찾아진 확률??
        //return log( Double(frequency)/Double(countOfGramInDocument) + 1)
        //return Double(frequency)/Double(countOfGramInDocument)
        
        //일단 Boolean Frequency 로 변경해봄.
        if frequency > 0 {
            return 1.0
        }
        
        return 0.0
    }
    
    func getTF(_ frequency:Int, countOfGramInDocument: Int, maxFrequency: Int) -> Double {
        return 0.5 + 0.5 * getF(frequency, countOfGramInDocument: countOfGramInDocument) / Double(maxFrequency)
    }
    
    func getIDF(_ index: Int) -> Double {
        //해당 term 이 해당 class 에서 발견된 횟수
        guard let count = arrayClass?.count, let idf = arrayIDF else { return 0.0 }
        guard idf.count > index else { return 0.0 }
        let termWithWord = Double(idf[index])
        
        //Log(전체 class 수 / term 발생한 문서 수) 
        return log(Double(count)/termWithWord)
    }
    
//    func normalize(_ value: Double) -> Double {
//        
//        return value / norm
//    }
    
    func getTFIDF(_ frequency:Int, countOfGramInDocument: Int, index: Int, maxFrequency: Int) -> Double {
        //return getTF(frequency, hits: hits) * getIDF(index)
        let tf = getTF(frequency, countOfGramInDocument: countOfGramInDocument, maxFrequency: maxFrequency)
        let idf = getIDF(index)
//        return normalize(tf * idf)
        return tf * idf
    }
    
    func getArrayGram(_ value: String) -> Array<String> {
        var arrayUni = ngram(value, type: .Unigram)
        let arrayBi = ngram(value)
        var arrayGram = Array<String>()
        
        if let index = arrayUni.index(of:" ") {
            arrayUni.remove(at: index)
        }
        
        arrayGram.append(contentsOf: arrayUni)
        arrayGram.append(contentsOf: arrayBi)
        
        return arrayGram
    }
    
    func getMaxFrequency(_ arrayOcurrs:Array<Int>) -> Int {
        var maxFrequency: Int = 0
        for frequncency in arrayOcurrs {
            if frequncency > maxFrequency {
                maxFrequency = frequncency
            }
        }
        
        return maxFrequency
    }
    
    func getArrayFrequency(_ arrayValueGram: Array<String>) -> Array<Int> {
        var arrayFrequency = Array<Int>(repeating: 0, count: arrayTotalGram.count)
        
        for gram in arrayValueGram {
            let indexGram = arrayTotalGram.index(of: gram)
            
            if let indexGram = indexGram {
                arrayFrequency[indexGram] = arrayFrequency[indexGram] + 1
            }
        }
        
        return arrayFrequency
    }
    
    func getArrayProb(_ value: String) -> Array<Double> {
        let arrayValueGram = getArrayGram(value)
        var arrayFrequency = getArrayFrequency(arrayValueGram)
        let maxFrequency = getMaxFrequency(arrayFrequency)
        
        var indexForFrequency = 0
        var arrayProb = Array<Double>(repeating: 0, count: arrayTotalGram.count)
        for _ in arrayFrequency {
            arrayProb[indexForFrequency] = getTFIDF(arrayFrequency[indexForFrequency], countOfGramInDocument: arrayValueGram.count, index: indexForFrequency, maxFrequency: maxFrequency)
            indexForFrequency = indexForFrequency + 1
        }
        
        return arrayProb
    }
    
    func buildIDF(_ dict: Dictionary<String,String>) {
        var array = Array<Int>(repeating: 0, count: arrayTotalGram.count)
        var indexBi = 0
        for bi in arrayTotalGram {
            for item in dict {
                if item.value.contains(bi) {
                    array[indexBi] = array[indexBi] + 1
                }
            }
            indexBi += 1
        }
        
        self.arrayIDF = array
    }
    
    func buildClassAndNGram(_ dict: Dictionary<String, String>) {
        //전체 클래스에 대한 bigram 을 구함.
        arrayClass = Array<String>()
        for item in dict {
            arrayClass?.append(item.key)
            var arrayUni = ngram(item.value, type:.Unigram)
            let arrayBi = ngram(item.value)
            
            if let index = arrayUni.index(of:" ") {
                arrayUni.remove(at: index)
            }
            
            arrayTotalGram.append(contentsOf: arrayUni)
            
            for bi in arrayBi {
                let index = arrayTotalGram.index(of: bi)
                
                if nil == index {
                    arrayTotalGram.append(bi)
                }
            }
        }
    }
    
    func train(_ dict: Dictionary<String,String>) {
        buildClassAndNGram(dict)
        buildIDF(dict)
        
        var arrayDataArrayProb = Array<[Double]>(repeating:Array<Double>(), count: dict.count)
        
        var index = 0
        for item in dict {
            let arrayProb = getArrayProb(item.value)
            arrayDataArrayProb[index] = arrayProb
            index = index + 1
        }
        
        //  Create a data set
        let data = DataSet(dataType: .Classification, inputDimension: arrayTotalGram.count, outputDimension: 1)
        do {
            var index = 0
            
            for item in arrayDataArrayProb {
                try data.addDataPoint(input: item, output:index)
                index = index + 1
            }
        }
        catch {
            print("Invalid data set created")
        }
        
        model?.train(data: data)
    }
    
    func getClassLabelString(_ classLabel: Int) -> String {
        guard let ret = arrayClass?[classLabel] else { return "" }
        return ret
    }
    
    func predict(_ text: String) -> String {
        //  Create a test dataset
        let testData = DataSet(dataType: .Classification, inputDimension: arrayTotalGram.count, outputDimension: 1)
        do {
            let arrayProb = getArrayProb(text)
            try testData.addTestDataPoint(input: arrayProb)
        }
        catch {
            debugPrint("Invalid data set created")
        }
        
        model?.predictValues(data: testData)
        
        //  See if we matched
        var classLabel : Int
        
        do {
            try classLabel = testData.getClass(index: 0)
            return getClassLabelString(classLabel)
        }
        catch {
            debugPrint("Error in prediction")
        }
        
        return ""
    }
    
    func predictProb(_ text:String) -> Double {
        let arrayProb = getArrayProb(text)
        if let ret = model?.predictProbability(inputs: arrayProb) {
            return ret
        }
        
        return 0.0
    }
}
