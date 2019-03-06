//
//  Test.swift
//  RxSwift-D1
//
//  Created by screson on 2019/3/6.
//  Copyright © 2019 screson. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct Test {
    let disposeBag = DisposeBag()
    func test() {
        do {
            let one = 1
            let two = 2
            let three = 3
            //Observable<Int>
            let observable: Observable<Int> = Observable.just(one)
            //Observable<Int>
            let observable2 = Observable.of(one, two, three)
            //Observable<[Int]>
            let observable3 = Observable.of([one, two, three])
            //Observable<Int>
            let observable4 = Observable.from([one, two, three])
            
            observable3.subscribe(onNext: { value in
                print(value.count)
            }).disposed(by: disposeBag)
            
            observable4.subscribe(onNext: { value in
                print(value)
            }).disposed(by: disposeBag)
            
        }
        
        do {
            let subject = PublishSubject<String>()
            subject.onNext("Is anyone listening?")
            
            let subscriptionOne = subject.subscribe(onNext: { string in
                print(string)
            })
            subscriptionOne.disposed(by: disposeBag)
            subject.onNext("A")
        }
        
        //Subjects act as both an observable and observer
        
        do {
            let variable = Variable(2)
            variable.value = 3
            variable.asObservable().subscribe { (event) in
                print(event, event.element ?? "")
                }.disposed(by: disposeBag)
            
            print("- BehaviorReplay ❤️")
            let behaviorReplay = BehaviorRelay(value: "Initial value")//in RxCocoa
            behaviorReplay.subscribe(onNext: { value in
                print(value)
            }).disposed(by: disposeBag)
            
            behaviorReplay.accept("Copy value")
            
            behaviorReplay.subscribe(onNext: { value in
                print("Subscribe 2:", value)
            }).disposed(by: disposeBag)
            
            print("- BehaviorReplay<[Int]> ❤️")
            
            let bReplay = BehaviorRelay<[Int]>(value: [1,2,3,4,5])
            bReplay.subscribe(onNext: { values in
                print(values)
            }).disposed(by: disposeBag)
            
            bReplay.accept(bReplay.value + [6,7,8,9,10])
            print(bReplay.value)
        }

    }
}
