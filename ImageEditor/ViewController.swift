//
//  ViewController.swift
//  ImageEditor
//
//  Created by Chaitra on 03/09/22.
//

import UIKit
import Photos

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIPopoverPresentationControllerDelegate, selectedImage {
   
    
    @IBOutlet var infoText: UILabel!
    
    @IBOutlet var infoText2: UILabel!
    
    @IBOutlet var imageView: UIImageView!
    let imagePicker = UIImagePickerController()
    
    func imageSelected(selected: UIImage) {
        imageView.image = selected
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
    }

    
    @IBAction func chooseImage(_ sender: UIButton) {
        showImagePicker()
    }
    
    func showImagePicker() {
        let alert = UIAlertController(title: "Pick a image", message: " ", preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Camera", style: .default) { action in
            let cameraPicker = self.imagePicker(sourceType: .camera)
            cameraPicker.delegate = self
            self.present(cameraPicker, animated: true)
        }
        let photo = UIAlertAction(title: "Photo Library", style: .default) { action in
            let photoPicker = self.imagePicker(sourceType: .photoLibrary)
            photoPicker.delegate = self
            self.present(photoPicker, animated: true)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(camera)
        alert.addAction(photo)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let chosenImage = info[.originalImage] as! UIImage
        imageView.contentMode = .scaleAspectFill
        imageView.image = chosenImage
        getPhotos()
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePicker(sourceType:UIImagePickerController.SourceType) -> UIImagePickerController {
        imagePicker.sourceType = sourceType
        return imagePicker
    }
    
    private func getPhotos() {
            let manager = PHImageManager.default()
            let requestOptions = PHImageRequestOptions()
            requestOptions.isSynchronous = true
            requestOptions.deliveryMode = .fastFormat
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

            let results: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            if results.count > 0 {
                for i in 0..<results.count {
                    let asset = results.object(at: i)
                    manager.requestImageDataAndOrientation(for: asset, options: requestOptions) { (data, fileName, orientation, info) in
                        if let data = data,
                           let cImage = CIImage(data: data) {
                            let exif = cImage.properties["{Exif}"]
                            print("EXIF Data: \(exif)")
                            
                            for i in exif as! NSDictionary{
//                                print(i)÷\
                                self.infoText.text = i.value as? String
                                self.infoText2.text = i.key as? String
                            }
//                            self.infoText.text = exif as? String
                        }
                    }
                }
            }
        }
    
    
    @IBAction func save(_ sender: Any) {
        let timestamp = DateFormatter.localizedString(from: NSDate() as Date, dateStyle: .long, timeStyle: .short)
         print(timestamp)
        saveImage(imageName: timestamp, image: imageView.image!)
    }
    
//    https://stackoverflow.com/questions/37344822/saving-image-and-then-loading-it-in-swift-ios
    func saveImage(imageName: String, image: UIImage) {
     guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }

        let fileName = imageName
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        guard let data = image.jpegData(compressionQuality: 1) else { return }

        //Checks if file exists, removes it if so.
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
                print("Removed old image")
            } catch let removeError {
                print("couldn't remove file at path", removeError)
            }
        }

        do {
            try data.write(to: fileURL)
            print("saved")
        } catch let error {
            print("error saving file with error", error)
        }
    }
    
    @IBAction func editPop(_ sender: UIBarButtonItem) {
        
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "edittedVal") as! EditViewController
        vc.modalPresentationStyle = UIModalPresentationStyle.popover
           let popover: UIPopoverPresentationController = vc.popoverPresentationController!
        vc.selectedImage = imageView.image
        vc.preferredContentSize.height = 200
        vc.preferredContentSize.width = 200
           popover.barButtonItem = sender
        vc.delegate = self
           popover.delegate = self
        present(vc, animated: true, completion:nil)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
            return UIModalPresentationStyle.none
        }
    
    
}

