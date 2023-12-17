//
//  ExitBottomSheet.swift
//  LSLProject
//
//  Created by 백래훈 on 12/17/23.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources

final class ExitBottomSheet: BaseViewController {
    
    private let tableView = {
        let view = UITableView(frame: .zero, style: .insetGrouped)
        view.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.identifier)
        view.rowHeight = 50
        view.isScrollEnabled = false
        return view
    }()
    
    private var exit = [
        Header(header: nil,
               items: [
                Bottom(title: "로그아웃", color: .systemRed),
                Bottom(title: "회원탈퇴", color: .systemRed)
        ])
    ]
    
    private lazy var exits = BehaviorRelay<[Header]>(value: exit)
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        
    }
    
    private func bind() {
        let dataSource = RxTableViewSectionedReloadDataSource<Header> { dataSource, tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier, for: indexPath)
            
            cell.textLabel?.text = item.title
            cell.textLabel?.textColor = item.color
            cell.textLabel?.font = .systemFont(ofSize: 12.5, weight: .medium)
            cell.selectionStyle = .none
            cell.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1.0)
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            
            return cell
            
        }
        
        exits
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(Bottom.self)
            .filter { $0.title == "로그아웃" }
            .withUnretained(self)
            .bind { owner, _ in
                owner.presentLogoutViewController()
            }
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(Bottom.self)
            .filter { $0.title == "회원탈퇴" }
            .withUnretained(self)
            .bind { owner, _ in
                owner.presentWithdrawViewController()
            }
            .disposed(by: disposeBag)
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
    }
    
    override func configureView() {
        super.configureView()
        
        view.addSubview(tableView)
        
        view.backgroundColor = .systemBackground
        tableView.backgroundColor = .systemBackground
        
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        tableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
    }
    
    private func presentLogoutViewController() {
        let vc = LogoutViewController()
        
        guard let presentingViewController = self.presentingViewController else { return }
        
        vc.modalPresentationStyle = .overFullScreen

        self.dismiss(animated: true) {
            presentingViewController.present(vc, animated: false)
        }
    }
    
    private func presentWithdrawViewController() {
        let vc = WithdrawViewController()
        
        guard let presentingViewController = self.presentingViewController else { return }
        
        vc.modalPresentationStyle = .overFullScreen

        self.dismiss(animated: true) {
            presentingViewController.present(vc, animated: false)
        }
    }
    
}

extension ExitBottomSheet: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
}
