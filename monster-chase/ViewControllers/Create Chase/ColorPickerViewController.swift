//
//  ColorPickerViewController.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 2/5/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import UIKit
import FlexColorPicker

class ColorPickerViewController: CustomColorPickerViewController {
    @IBOutlet weak var monsterBackgroundColor: UIImageView!

    @IBOutlet weak var colorPickerView: RadialPaletteControl! {
        didSet {
            colorPicker.controlDidSet(newValue: colorPickerView, oldValue: oldValue)
        }
    }
    
    @IBOutlet weak var colorPreviewWithHex: ColorPreviewWithHex! {
        didSet {
            colorPicker.controlDidSet(newValue: colorPreviewWithHex, oldValue: oldValue)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        monsterBackgroundColor.backgroundColor = colorPicker.selectedColor
    }
    
    // MARK: View
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        monsterBackgroundColor.layer.cornerRadius = monsterBackgroundColor.frame.height / 2
    }
    
    override func refreshView() throws {
        //
    }
    
    // MARK: IBActions
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        backButtonPressed(sender)
    }
}
