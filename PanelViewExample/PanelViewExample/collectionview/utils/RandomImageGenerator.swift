// Adapted from https://github.com/wvabrinskas/Avatar under MIT License

import UIKit

/// You use RandomImageGenerator to create pixelated images to represent users who haven't provided an image in their profile section
protocol RandomImageGenerator {
    
    /// generates a random avatar at 48x48 pt size
    func generate() -> UIImage
    
    /// generates a random avatar for the provided size
    func generate(for size: CGSize) -> UIImage
}

class RandomImageGeneratorImpl: RandomImageGenerator {
    func generate() -> UIImage {
        return generate(for: CGSize(width: 48, height: 48))
    }
    
    func generate(for size: CGSize) -> UIImage {
        let avatarSize = size
        let generatedAvatar = RandomImage.generateRandom(for: avatarSize, scale: 8)
        if let validAvatar = generatedAvatar {
            return validAvatar
        } else {
            return UIImage(imageLiteralResourceName: "icon_undefined_icon2")
        }
    }
            
    private func firstColorComponent(with seedHash: Int) -> UIColor {
        let normalizer = 256
        let rgbMaxValue = CGFloat(255)
        let redValue = (seedHash % 1511) % normalizer
        let greenValue = (seedHash % 6529) % normalizer
        let blueValue = (seedHash % 8009) % normalizer
        
        let red = CGFloat(redValue) / rgbMaxValue
        let green = CGFloat(greenValue) / rgbMaxValue
        let blue =  CGFloat(blueValue) / rgbMaxValue
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    private func secondColorComponent(with seedHash: Int) -> UIColor {
        let normalizer = 256
        let rgbMaxValue = CGFloat(255)
        let redValue = (seedHash % 2053) % normalizer
        let greenValue = (seedHash % 9277) % normalizer
        let blueValue = (seedHash % 3673) % normalizer
        
        let red = CGFloat(redValue) / rgbMaxValue
        let green = CGFloat(greenValue) / rgbMaxValue
        let blue =  CGFloat(blueValue) / rgbMaxValue
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    private func thirdColorComponent(with seedHash: Int) -> UIColor {
        let normalizer = 256
        let rgbMaxValue = CGFloat(255)
        let redValue = (seedHash % 4363) % normalizer
        let greenValue = (seedHash % 1171) % normalizer
        let blueValue = (seedHash % 7621) % normalizer
        
        let red = CGFloat(redValue) / rgbMaxValue
        let green = CGFloat(greenValue) / rgbMaxValue
        let blue =  CGFloat(blueValue) / rgbMaxValue
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
