
import Foundation
import Firebase
import UIKit

class FUser: Equatable {
    static func == (lhs: FUser, rhs: FUser) -> Bool {
        lhs.objectId == rhs.objectId
    }

    let objectId: String
    var email: String
    var username: String
    var dateOfBirth: Date
    var isMale: Bool
    var avatar: UIImage?
    var about: String
    var city: String
    var country: String
    var lookingFor: String
    var avatarLink: String
    var weight: Double
    var height: Double
    var breed: String

    var likedIdArray: [String]?
    var imageLinks: [String]?
    let registeredDate = Date()
    var pushId: String?
    var age: Int

    var userDictionary: NSDictionary {
        return NSDictionary(objects: [
                                    self.objectId,
                                    self.email,
                                    self.username,
                                    self.dateOfBirth,
                                    self.isMale,
                                    self.about,
                                    self.city,
                                    self.country,
                                    self.lookingFor,
                                    self.avatarLink,
                                    self.weight,
                                    self.height,
                                    self.breed,
                                    self.likedIdArray ?? [],
                                    self.imageLinks ?? [],
                                    self.registeredDate,
                                    self.pushId ?? "",
                                    self.age
        ],

        forKeys: [kOBJECTID as NSCopying,
                  kEMAIL as NSCopying,
                  kUSERNAME as NSCopying,
                  kDATEOFBIRTH as NSCopying,
                  kISMALE as NSCopying,
                  kABOUT as NSCopying,
                  kCITY as NSCopying,
                  kCOUNTRY as NSCopying,
                  kLOOKINNGFOR as NSCopying,
                  kAVTAARLINK as NSCopying,
                  kWEIGHT as NSCopying,
                  kHEIGHT as NSCopying,
                  kBREED as NSCopying,
                  kLIKEDIDARRAY as NSCopying,
                  kIMAGELINKS as NSCopying,
                  kREGISTEREDDATE as NSCopying,
                  kPUSHID as NSCopying,
                  kAGE as NSCopying
        ])
    }

    //MARK: - Inits

    init(_objectId: String, _email: String, _username: String, _city: String, _dateOfBirth: Date, _isMale: Bool, _avatarLink: String = "") {
        objectId = _objectId
        email = _email
        username = _username
        dateOfBirth = _dateOfBirth
        isMale = _isMale
        about = ""
        city = _city
        country = ""
        lookingFor = ""
        avatarLink = _avatarLink
        weight = 0.0
        height = 0.0
        breed = ""
        likedIdArray = []
        imageLinks = []
        age = dateOfBirth.interval(ofComponnent: .year, fromDate: Date())
    }

    init(_dictionary: NSDictionary) {
        objectId = _dictionary[kOBJECTID] as? String ?? ""
        email = _dictionary[kEMAIL] as? String ?? ""
        username = _dictionary[kUSERNAME] as? String ?? ""
        isMale = _dictionary[kISMALE] as? Bool ?? true
        about = _dictionary[kABOUT] as? String ?? ""
        city = _dictionary[kCITY] as? String ?? ""
        country = _dictionary[kCOUNTRY] as? String ?? ""
        lookingFor = _dictionary[kLOOKINNGFOR] as? String ?? ""
        avatarLink = _dictionary[kAVTAARLINK] as? String ?? ""
        weight = _dictionary[kWEIGHT] as? Double ?? 0.0
        height = _dictionary[kHEIGHT] as? Double ?? 0.0
        breed = _dictionary[kBREED] as? String ?? ""
        likedIdArray = _dictionary[kLIKEDIDARRAY] as? [String]
        imageLinks = _dictionary[kIMAGELINKS] as? [String]
        pushId = _dictionary[kPUSHID] as? String ?? ""

        age = _dictionary[kAGE] as? Int ?? 0

        if let date = _dictionary[kDATEOFBIRTH] as? Timestamp {
            dateOfBirth = date.dateValue()
        } else {
            dateOfBirth = _dictionary[kDATEOFBIRTH] as? Date ?? Date()
        }

        let placeHolder = isMale ? "mPlaceholder" : "fPlaceholder"
        avatar =  UIImage(contentsOfFile: fileInDocumentsDirectory(filename: self.objectId)) ?? UIImage(named: placeHolder)

    }

    //MARK: - Returning current user

    class func currentId() -> String {
        return Auth.auth().currentUser!.uid
    }

    class func currentUser() -> FUser? {
        if Auth.auth().currentUser != nil {
            if let userDictionary = userDefaults.object(forKey: kCURRENTUSER) {
                return FUser(_dictionary: userDictionary as! NSDictionary)
            }
        }
        return nil
    }

    func getUserAvatarFromFirestore(completion: @escaping (_ didset: Bool) -> Void) {
        FileStorage.donwloadImage(imageUrl: self.avatarLink) { (profileImage) in

            let placeholder = self.isMale ? "mPlaceholder" : "fPlaceholder"
            self.avatar = profileImage ?? UIImage(named: placeholder)
            completion(true)
        }
    }



    //MARK: - Login
    class func loginUserWith(email: String, password: String, completion: @escaping (_ error: Error?, _ isEmailVerified: Bool) -> Void) {

        Auth.auth().signIn(withEmail: email, password: password) {
            (authDataResult, error ) in

            if error == nil {
                if authDataResult!.user.isEmailVerified {
                    //check is user exists in fb
                    FirebaseListener.shared.downloadCurrentUserFromFirebase(userId: authDataResult!.user.uid, email: email)
                    completion(error, true)
                } else {
                    print("Email not Verified")
                    completion(error, false)
                }
            } else {
                completion(error, false)
            }
        }
    }

    //MARK: - Register

    class func registerUserWith(email: String, passsword: String, userName: String, city: String,
                                isMale: Bool, dateOfBirth: Date, completion: @escaping (_ error: Error?) -> Void) {

        Auth.auth().createUser(withEmail: email, password: passsword) { (authData, error) in
             
            completion(error)
            if error == nil {
                authData!.user.sendEmailVerification { (error) in
                    print("auth email verification sent",
                          error?.localizedDescription)
                }
                if authData?.user != nil {
                    let user = FUser(_objectId: authData!.user.uid, _email: email, _username: userName, _city: city, _dateOfBirth: dateOfBirth, _isMale: isMale)

                    user.saveUserLocally()
                }
            }
        }
    }

    //MARK: -  Edit User Profile

    func updateUserEmail(newEmail: String, completion: @escaping (_ error: Error?) -> Void) {
        Auth.auth().currentUser?.updateEmail(to: newEmail, completion: { error in
            FUser.resendVerificationEmail(email: newEmail) { (error) in

            }
            completion(error)
        })
    }

    //MARK: - Resend Links

    class func resendVerificationEmail(email: String, completion: @escaping (_ error: Error?) -> Void) {
        Auth.auth().currentUser?.reload(completion: { (error) in
            Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                completion(error)
            })
        })
    }
    class func resetPassword(email: String, completion: @escaping (_ error: Error?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            completion(error)
        }
    }

    //MARK: - LogOut user

    class func logOutCurrentUser(completion: @escaping(_ error: Error?) -> Void) {
        do {
            try Auth.auth().signOut()
            userDefaults.removeObject(forKey:kCURRENTUSER)
            userDefaults.synchronize()
            completion(nil)

        } catch let error as NSError {
            completion(error)
        }
    }

    //MARK: - Save user funcs
    
    func saveUserLocally() {

        userDefaults.setValue(self.userDictionary as! [String : Any], forKey: kCURRENTUSER)
        userDefaults.synchronize()
    }

    func saveUserToFireStore() {
        FirebaseReference(.User).document(self.objectId).setData(self.userDictionary as! [String: Any ]) { (error) in
            if error != nil {
                print(error!.localizedDescription)
            }
        }
    }

    //MARK: - Update user funcs
    func updateCurrentUserInFireStore(withValues: [String : Any], completion: @escaping (_ error: Error?) -> Void) {

        if let dictionary = userDefaults.object(forKey: kCURRENTUSER) {
            let userObject = (dictionary as! NSDictionary).mutableCopy() as! NSMutableDictionary
            userObject.setValuesForKeys(withValues)

            FirebaseReference(.User).document(FUser.currentId()).updateData(withValues) {
                error in
                completion(error)
                if error == nil {
                    FUser(_dictionary: userObject).saveUserLocally()
                }
            }
        }
    }
}

func createUsers() {
    let names = ["Toby", "Jack", "Coco", "Charlie", "Lucy", "Buddy", "Niky", "Joly", "Bimy", "Kiki", "Rexy","Zuky"]
    var imageIndex = 1
    var userIndex = 1
    var isMale = true

    for i in 0..<11 {
        let id  = UUID().uuidString
        let fileDirectory = "Avatar/_" + id + ".jpg"

        FileStorage.uploadImage(UIImage(named: "user\(imageIndex)")!, directory: fileDirectory) { (avatarLink) in
            let user = FUser(_objectId: id, _email: "user\(userIndex)@gmail.com", _username: names[i], _city: "No City", _dateOfBirth: Date(), _isMale: isMale, _avatarLink: avatarLink ?? "")

            isMale.toggle()
            userIndex += 1
            user.saveUserToFireStore()
        }
        imageIndex += 1
        if imageIndex == 16 {
            imageIndex = 1
        }
    }
}
