//
//  EditViewController.swift
//  ImageEditor
//
//  Created by Chaitra on 03/09/22.
//

import UIKit
import Photos

protocol selectedImage {
    func imageSelected(selected:UIImage)
}

class EditViewController: UIViewController, UITableViewDataSource,UITableViewDelegate {
    
    let editArray = ["Crop", "Flip Horizontal", "Flip Vertical"]
    
    var selectedImage:UIImage?
    var croppedImage:UIImage?
    var delegate:selectedImage?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return editArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = editArray[indexPath.row]
        return cell!
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            croppedImage = cropToBounds(image: selectedImage!, width: 200, height: 200)
            delegate?.imageSelected(selected: croppedImage!)
            dismiss(animated: true, completion: nil)
        case 1:
            let flipHorizontal = (selectedImage?.withHorizontallyFlippedOrientation())!
            delegate?.imageSelected(selected: flipHorizontal)
            dismiss(animated: true, completion: nil)
            break
        case 2:
//        https://stackoverflow.com/questions/40882487/how-to-rotate-image-in-swift
            let flipVertical = (selectedImage?.rotateImage(orientation: .right))!
            delegate?.imageSelected(selected: flipVertical)
            dismiss(animated: true, completion: nil)
            break
        default:
            print("Other")
            break
        }
    }
   
//    https://stackoverflow.com/questions/32041420/cropping-image-with-swift-and-put-it-on-center-position
    func cropToBounds(image: UIImage, width: Double, height: Double) -> UIImage {

            let cgimage = image.cgImage!
            let contextImage: UIImage = UIImage(cgImage: cgimage)
            let contextSize: CGSize = contextImage.size
            var posX: CGFloat = 0.0
            var posY: CGFloat = 0.0
            var cgwidth: CGFloat = CGFloat(width)
            var cgheight: CGFloat = CGFloat(height)

            // See what size is longer and create the center off of that
            if contextSize.width > contextSize.height {
                posX = ((contextSize.width - contextSize.height) / 2)
                posY = 0
                cgwidth = contextSize.height
                cgheight = contextSize.height
            } else {
                posX = 0
                posY = ((contextSize.height - contextSize.width) / 2)
                cgwidth = contextSize.width
                cgheight = contextSize.width
            }

            let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)

            // Create bitmap image from context using the rect
            let imageRef: CGImage = cgimage.cropping(to: rect)!

            // Create a new image based on the imageRef and rotate back to the original orientation
            let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)

            return image
        }

}

extension UIImage {
 
    /// Rotate the UIImage
    /// - Parameter orientation: Define the rotation orientation
    /// - Returns: Get the rotated image
   func rotateImage(orientation: UIImage.Orientation) -> UIImage {
      guard let cgImage = self.cgImage else { return UIImage() }
      switch orientation {
           case .right:
               return UIImage(cgImage: cgImage, scale: 1.0, orientation: .up)
           case .down:
               return UIImage(cgImage: cgImage, scale: 1.0, orientation: .right)
           case .left:
               return UIImage(cgImage: cgImage, scale: 1.0, orientation: .down)
           default:
               return UIImage(cgImage: cgImage, scale: 1.0, orientation: .left)
       }
   }
}
