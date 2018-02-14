//
//  ViewController.swift
//  CLibdillExample
//
//  Created by Max Desiatov on 13/02/2018.
//

import Darwin
import UIKit

class ViewController: UIViewController {
  @IBOutlet weak var pressed: UILabel!

  var future: Future<()>?

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  @IBAction func test(_ sender: UIButton) {
    pressed.text = "pressed"

    let future = try! Future<Int> {
      try Coroutine.wakeUp(5.second.fromNow())
      return 42
    }

    let gen = Generator<Int> { yield in
      var i = 0
      var flag = true

      future.then({
        print("result is \($0)")
        flag = false
      }, failure: {
        print($0)
      })

      while flag {
        yield(i)
        i += 1
      }
    }

    for i in gen {
      print(i)

      try! Coroutine.wakeUp(1.second.fromNow())
    }

    pressed.text = "generator finished"
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}

