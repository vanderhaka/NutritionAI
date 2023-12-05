import SwiftUI
import Firebase
import FirebaseStorage

struct ContentView: View {
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var analysisResult: String? // To store the result from OpenAI
    
    var body: some View {
        NavigationView {
            VStack {
                // Display the selected image (if any)
                inputImage.map {
                    Image(uiImage: $0)
                        .resizable()
                        .scaledToFit()
                }
                
                // Display the analysis result from OpenAI
                if let result = analysisResult {
                    Text(result)
                }
                
                // Button to open the image picker
                Button("Select Image") {
                    showingImagePicker = true
                }
            }
            .sheet(isPresented: $showingImagePicker, onDismiss: uploadImage) {
                ImagePicker(image: $inputImage)
            }
        }
    }
    
    // Function to convert UIImage to JPEG
    func convertImageToJPEG(image: UIImage) -> Data? {
        return image.jpegData(compressionQuality: 0.8)
    }
    
    // Function to upload the image after selection
    func uploadImage() {
        guard let inputImage = inputImage, let imageData = convertImageToJPEG(image: inputImage) else { return }
        
        uploadImageToFirebase(imageData: imageData) { result in
            switch result {
            case .success(let url):
                print("Image uploaded successfully: \(url)")
                analyzeImageWithOpenAI(using: url)
            case .failure(let error):
                print("Error uploading image: \(error.localizedDescription)")
                // Handle upload error in UI
                analysisResult = "Upload Failed: \(error.localizedDescription)"
            }
        }
    }
    
    // Function to upload image to Firebase Storage
    func uploadImageToFirebase(imageData: Data, completion: @escaping (Result<URL, Error>) -> Void) {
        let storageRef = Storage.storage().reference() // Ensure Storage is properly initialized
        let imageRef = storageRef.child("images/\(UUID().uuidString).jpg")
        
        imageRef.putData(imageData, metadata: nil) { metadata, error in
            guard metadata != nil else {
                // Safely unwrap error or create a new error
                let uploadError = error ?? NSError(domain: "FirebaseUploadError", code: -1, userInfo: ["ErrorInfo": "Firebase upload failed"])
                completion(.failure(uploadError))
                return
            }

            imageRef.downloadURL { url, error in
                // Safely unwrap URL
                if let url = url {
                    completion(.success(url))
                } else {
                    // Safely unwrap error or create a new error
                    let downloadURLError = error ?? NSError(domain: "FirebaseDownloadURLError", code: -1, userInfo: ["ErrorInfo": "Failed to get download URL"])
                    completion(.failure(downloadURLError))
                }
            }
        }
    }

    
    // Function to analyze the image using OpenAI Vision API
    func analyzeImageWithOpenAI(using imageUrl: URL) {
        OpenAIService().analyzeImage(with: imageUrl) { result in
            DispatchQueue.main.async { // Ensure UI update on main thread
                switch result {
                case .success(let result):
                    print("OpenAI Analysis Result: \(result)")
                    self.analysisResult = result // Update the @State variable
                case .failure(let error):
                    print("Error in OpenAI Analysis: \(error.localizedDescription)")
                    self.analysisResult = "Analysis Failed: \(error.localizedDescription)" // Update the @State variable
                }
            }
        }
    }
}

// ImagePicker component and UIImagePickerControllerDelegate methods
struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss
    @Binding var image: UIImage?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }

            parent.dismiss()
        }
    }
}
