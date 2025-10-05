//
//  MoreViewController.swift
//  CurtainCall
//
//  Created by 서준일 on 10/1/25.
//

import UIKit
import RxSwift
import RxCocoa
import SafariServices
import MessageUI

final class MoreViewController: BaseViewController {
    
    // MARK: - Properties
    private let moreView = MoreView()
    private let viewModel: MoreViewModel
    private let viewWillAppearSubject = PublishSubject<Void>()
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    init(viewModel: MoreViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func loadView() {
        view = moreView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewWillAppearSubject.onNext(())
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        navigationItem.title = CCStrings.Title.moreName
    }
    
    override func setupBind() {
        super.setupBind()
        
        let input = MoreViewModel.Input(
            viewWillAppear: viewWillAppearSubject.asObservable(),
            profileViewTapped: moreView.profileTapped,
            menuItemSelected: moreView.menuItemSelected
        )
        
        let output = viewModel.transform(input: input)
        
        // 프로필 데이터 바인딩
        output.userProfile
            .drive(with: self) { owner, profile in
                guard let profile = profile else { return }
                owner.moreView.configure(
                    nickname: profile.nickname,
                    profileImageURL: profile.profileImageURL
                )
            }
            .disposed(by: disposeBag)
        
        // 프로필 편집 화면으로 이동
        output.navigateToProfileEdit
            .emit(with: self) { owner, _ in
                owner.navigateToProfileEdit()
            }
            .disposed(by: disposeBag)
        
        // 메뉴 액션 처리
        output.handleMenuAction
            .emit(with: self) { owner, action in
                owner.handleMenuAction(action)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Private Methods
    
    private func navigateToProfileEdit() {
        let repository = UserRepository()
        let getUserProfileUseCase = GetUserProfileUseCase(repository: repository)
        let updateProfileImageUseCase = UpdateProfileImageUseCase(repository: repository)
        let updateNicknameUseCase = UpdateNicknameUseCase(repository: repository)
        
        let viewModel = ProfileEditViewModel(
            getUserProfileUseCase: getUserProfileUseCase,
            updateProfileImageUseCase: updateProfileImageUseCase,
            updateNicknameUseCase: updateNicknameUseCase
        )
        
        let viewController = ProfileEditViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func handleMenuAction(_ action: MoreViewModel.MenuAction) {
        switch action {
        case .showPrivacyPolicy:
            openPrivacyPolicy()
            
        case .showOpenSourceLicense:
            openOpenSourceLicense()
            
        case .openContact:
            openContact()
            
        case .openAppStoreReview:
            break
        }
    }
    
    private func openPrivacyPolicy() {
        guard let url = URL(string: "https://joonil.notion.site/27eca62c738f80a59a75f8c4bcb74ce2?source=copy_link") else {
            return
        }
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true)
    }
    
    private func openOpenSourceLicense() {
        let viewController = OpenSourceLicenseViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func openContact() {
        guard MFMailComposeViewController.canSendMail() else {
            showMailErrorAlert()
            return
        }
        
        let mailSettings = getMailSettings()
        let mailVC = MFMailComposeViewController()
        mailVC.mailComposeDelegate = self
        mailVC.setToRecipients(mailSettings.recipients)
        mailVC.setSubject(mailSettings.subject)
        mailVC.setMessageBody(mailSettings.body, isHTML: false)
        
        present(mailVC, animated: true)
    }
    
    private func getMailSettings() -> (recipients: [String], subject: String, body: String) {
        let bodyString = """
        문의 사항 및 의견을 작성해주세요.
        
        
        -------------------
        Device Model : \(DeviceInfo.getDeviceModelName())
        Device OS : \(DeviceInfo.getDeviceOS())
        App Version : \(DeviceInfo.getAppVersion())
        
        -------------------
        """
        
        return (["dccrdseo@naver.com"], "[CurtainCall] 문의", bodyString)
    }
    
    private func showMailErrorAlert() {
        let alert = UIAlertController(
            title: "메일 전송 실패",
            message: "메일 앱을 사용할 수 없습니다. 기기의 메일 설정을 확인해주세요.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

extension MoreViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?
    ) {
        controller.dismiss(animated: true)
    }
}
