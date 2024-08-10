//
//  Extensions+Picker.swift
//  CameraApp
//
//  Created by Ozgun Dogus on 5.08.2024.
//

import Foundation
import UIKit

extension CameraViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == isoPicker {
            return isoSettings.count
        } else if pickerView == shutterSpeedPicker {
            return shutterSpeedSettings.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == isoPicker {
            return "\(isoSettings[row])"
        } else if pickerView == shutterSpeedPicker {
            return "1/\(Int(1/shutterSpeedSettings[row]))"
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        if pickerView == isoPicker {
            label.text = "\(isoSettings[row])"
        } else if pickerView == shutterSpeedPicker {
            label.text = String(format: "1/%.0f", 1/shutterSpeedSettings[row])
        }
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        updateCameraSettings()
    }
}
