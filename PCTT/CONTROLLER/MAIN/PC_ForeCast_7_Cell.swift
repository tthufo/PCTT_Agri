//
//  PC_ForeCast_7_Cell.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 8/11/19.
//  Copyright © 2019 Thanh Hai Tran. All rights reserved.
//

import UIKit

class PC_ForeCast_7_Cell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet var collectionView: UICollectionView!
    
    var dataList: NSMutableArray? = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.withCell("PC_Weather_Cell")
    }
    
    let strip: (String) -> String = {
        var mStringRef = NSMutableString(string: $0) as CFMutableString
        CFStringTransform(mStringRef, nil, kCFStringTransformStripCombiningMarks, Bool(truncating: 0))
        return String(mStringRef)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataList!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Int(140), height: Int(475))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PC_Weather_Cell", for: indexPath as IndexPath)
        
        let data = dataList![indexPath.item] as! NSDictionary
        
        let date = self.withView(cell, tag: 1) as! UILabel
        
        let dateTime = ((data.getValueFromKey("date")! as NSString).date(withFormat: "yyyy-MM-dd")! as NSDate).string(withFormat: "dd/MM")
        
        date.text = dateTime == NSDate().string(withFormat: "dd/MM") ? "HÔM NAY" : ((data.getValueFromKey("date")! as NSString).date(withFormat: "yyyy-MM-dd")! as NSDate).string(withFormat: "dd/MM")
        
        let image = self.withView(cell, tag: 2) as! UIImageView
        
        image.image = UIImage(named: "icon_%@".format(parameters: data.getValueFromKey("icon")))
        
        let max = self.withView(cell, tag: 3) as! UILabel
        
        max.text = "%@ °C".format(parameters: data.getValueFromKey("temperature_max"))
        
        let min = self.withView(cell, tag: 4) as! UILabel
        
        min.text = "%@ °C".format(parameters: data.getValueFromKey("temperature_min"))
        
        let des = self.withView(cell, tag: 5) as! UILabel
        
        des.text = data.getValueFromKey("summary")
                
        
        let rain = self.withView(cell, tag: 6) as! UILabel

        rain.text = "%.1f mm".format(parameters: Float(data.getValueFromKey("precipitation_sum")) as! CVarArg)
        
        let cloud = self.withView(cell, tag: 7) as! UILabel
        
        cloud.text = "%@ %@".format(parameters: data.getValueFromKey("probability_prec_max"), "%")

        let temp = self.withView(cell, tag: 8) as! UILabel
        
        temp.text = "%i %@".format(parameters: Int(ceil((data.getValueFromKey("humidity_aver") as! NSString).floatValue)), "%")

        let direction = self.withView(cell, tag: 9) as! UILabel

        direction.text = "%.1f km/h".format(parameters: Float(data.getValueFromKey("wind_speed_max")) as! CVarArg)
        
        
        let imageHumidity = self.withView(cell, tag: 18) as! UIImageView
        
        imageHumidity.imageColor(color: AVHexColor.color(withHexString:"#1DADE9"))
        
        let imageDirection = self.withView(cell, tag: 19) as! UIImageView

//        imageDirection.transform = CGAffineTransform(rotationAngle: CGFloat((data.getValueFromKey("wind_direction_value") as! NSString).floatValue));
        
        let windName = self.strip(data.getValueFromKey("wind_direction")).replacingOccurrences(of: " ", with: "").lowercased().replacingOccurrences(of: "đ", with: "d")
        
        imageDirection.image = UIImage(named: windName)
        
        return cell
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
}

