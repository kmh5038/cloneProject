//
//  writeDiaryViewController.swift
//  Diary2
//
//  Created by 김명현 on 2023/08/17.
//

import UIKit

enum DiaryEditorMode {
    case new
    case edit(IndexPath, Diary)
}

protocol WriteDiaryViewDelegate: AnyObject{
    func didSelectReigster(diary: Diary) // 일기가 작성된 diary객체 전달
}

class WriteDiaryViewController: UIViewController {
 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureContentsTextView()
        self.configureDatePicker()
        self.configureInputField()
        self.configureEditorMode()
        self.confirmButton.isEnabled = false
        
    }
    
    
    weak var delegate: WriteDiaryViewDelegate?
    var diaryEditorMode: DiaryEditorMode = .new
    
    

    
    private func configureEditorMode() {
        switch self.diaryEditorMode {
        case let .edit(_, diary):
            self.titleTextField.text = diary.title
            self.contentsTextView.text = diary.contents
            self.dateTextField.text = self.dateToString(date: diary.date)
            self.diaryDate = diary.date
            self.confirmButton.title = "수정"
            
        default:
            break
            
        }
    }
    
    
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    // contentsTextView의 layer 그려주기
    private func configureContentsTextView() {
        contentsTextView.layer.borderWidth = 1.0
       let borderColor = UIColor(displayP3Red: 230/255, green: 230/255, blue: 230/255, alpha: 1.0)
        contentsTextView.layer.borderColor = borderColor.cgColor
        contentsTextView.layer.cornerRadius = 5.0
    }
    
    // dateTextField에 datePicker 나타내기   1. 프로퍼티 잡아주기
    private let datePicker = UIDatePicker()
    private var diaryDate: Date? // datePicker에서 선택된 데이트 값
    
    //dateTextField에 datePicker 나타내기    2. 메서드 설정
    private func configureDatePicker() {
        self.datePicker.datePickerMode = .date
        self.datePicker.preferredDatePickerStyle = .wheels
        self.datePicker.addTarget(self, action: #selector(datePickerValueDidChange(_:)), for: .valueChanged) // datePicker값이 바뀔때마다 selector호출
        self.dateTextField.inputView = self.datePicker // textField에 datePicker 넣기
    }
    
    // dateTextField에 datePicker 나타내기   3. sellector 메서드 설정
    @objc private func datePickerValueDidChange(_ datePicker: UIDatePicker) {
        let formmater = DateFormatter() // Date 타입을 사람이 읽을 수 있도록 사람이 변환을 해주거나, 날짜와 해당 텍스트 표현 사이를 변환하는 포맷터
        formmater.dateFormat = "yyyy년 MM월 dd일(EEEEE)" // dateFormmat 형식 잡기
        formmater.locale = Locale(identifier: "ko_KR") // 한국어 표현
        self.diaryDate = datePicker.date // datePicker에서 선택된 date값 넘기기
        self.dateTextField.text = formmater.string(from: datePicker.date)
        self.dateTextField.sendActions(for: .editingChanged)
    }
    
    private func configureInputField() {
        self.contentsTextView.delegate = self
        // textField들이 변할때마다 validate 작동
        self.titleTextField.addTarget(self, action: #selector(titleTextFieldDidChange(_:)), for: .editingChanged)
        self.dateTextField.addTarget(self, action: #selector(dateTextFieldDidChange(_:)), for: .editingChanged)
    }
    
    
    @objc private func titleTextFieldDidChange(_ textField: UITextField) {
        self.validateInputField()
    }
    @objc private func dateTextFieldDidChange(_ textField: UITextField) {
        self.validateInputField()
    }
    
    
    
   
    
    @IBOutlet weak var titleTextField: UITextField!
    

    @IBOutlet weak var contentsTextView: UITextView!
    
    @IBOutlet weak var dateTextField: UITextField!
    
    @IBOutlet weak var confirmButton: UIBarButtonItem!
    
    @IBAction func tapConfirmButton(_ sender: UIBarButtonItem) {
        // title, contents, date에 입력된 값을 diaryList배열에 넘겨주기
        guard let title = self.titleTextField.text else { return }
        guard let contents = self.contentsTextView.text else { return }
        guard let date = self.diaryDate else { return }
       
        
        switch self.diaryEditorMode {
        case .new:
            let diary = Diary(uuidString: UUID().uuidString, title: title, contents: contents, date: date, isStar: false)
            self.delegate?.didSelectReigster(diary: diary)
            
        case let .edit(indexPath, diary):
            let diary = Diary(uuidString: diary.uuidString, title: title, contents: contents, date: date, isStar: diary.isStar)
            NotificationCenter.default.post(name: NSNotification.Name("editDiary"), object: diary, userInfo: nil)
        }
        self.navigationController?.popViewController(animated: true) // 돌아가기( 일기장화면으로 돌아간다)
        }
    
    // 화면 빈곳 터치하면 키보드 내려감
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }


    
    // title, contents, date 모두 다 비어있지 않다면 등록버튼 활성화 조건
    private func validateInputField() {
        self.confirmButton.isEnabled = !(self.titleTextField.text?.isEmpty ?? true) && !(self.dateTextField.text?.isEmpty ?? true) && !self.contentsTextView.text.isEmpty
    }
    
   
}

// contentsTextView가 변할때마다 validate 작동
extension WriteDiaryViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.validateInputField()
    }
}

