//
//  MFAOTPCodeImage.swift
//  Guard
//
//  Created by mm on 2019/1/12.
//


open class MFAOTPCodeImage: ImageView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.authViewController?.authFlow?.mfaFromViewControllerName == "BindingMfaViewController" {
            mfaBindOTP()
        } else {
            AuthClient().mfaAssociateByOTP { code, msg, data in
                if code == 200 {
                    if let qrcode = data?["qrcode_data_url"] as? String,
                       let recoveryCode = data?["recovery_code"] as? String {
                        
                        DispatchQueue.main.async() {
                            self.saveOTPData(recoveryCode: recoveryCode, qrcode: qrcode)
                        }
                    }
                } else {
                    Toast.show(text: msg ?? "")
                }
            }
        }
    }
    
    private func mfaBindOTP() {
        
        let body: NSDictionary = ["factorType" : "OTP"]
        
        AuthClient().post("/api/v3/send-enroll-factor-request", body) { code, msg, res in
            if  let data = res?["data"] as? NSDictionary,
                let statusCode = res?["statusCode"] as? Int,
                statusCode == 200 {
                if let enrollmentToken = data["enrollmentToken"] as? String,
                   let otpData = data["otpData"] as? NSDictionary,
                   let qrcode = otpData["qrCodeDataUrl"] as? String,
                   let recoveryCode = otpData["recoveryCode"] as? String {
  
                    DispatchQueue.main.async() {
                        self.authViewController?.authFlow?.enrollmentToken = enrollmentToken
                        self.saveOTPData(recoveryCode: recoveryCode, qrcode: qrcode)
                    }
                }
            } else {
                Toast.show(text: res?["message"] as? String ?? "")
            }
        }
    }
    
    private func saveOTPData(recoveryCode: String, qrcode: String){
        self.authViewController?.authFlow?.mfaRecoveryCode = recoveryCode
        
        if let url = URL(string: qrcode) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url as URL),
                   let image = UIImage(data: data) {
                    DispatchQueue.main.async() { [weak self] in
                        self?.image = image
                    }
                }
            }
        }
    }
}

