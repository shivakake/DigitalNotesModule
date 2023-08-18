//
//  AddAndEditNoteViewController.swift
//  NotesModule
//
//  Created by PGK Shiva Kumar on 18/11/22.
//

import UIKit

class AddAndEditNoteViewController: UIViewController {
    
    @IBOutlet weak private var titleTextField: UITextField!
    @IBOutlet weak private var descriptionTextView: UITextView!
    @IBOutlet weak private var doneButton: UIButton!
    @IBOutlet private var subTitlesLabels: [UILabel]!
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    var noteModel : NoteModel?
    var noteLogic : NotesLogic?
    weak var delegate : NotesLogicDelegate?
    
    init(noteModel : NoteModel? , noteLogic : NotesLogic? , delegate :NotesLogicDelegate?) {
        self.noteModel = noteModel
        self.noteLogic = noteLogic
        self.delegate = delegate
        super.init(nibName: "AddAndEditNoteViewController", bundle: Bundle(for: AddAndEditNoteViewController.self))
    }
    
    required init?(coder: NSCoder) {
        super.init(nibName: "AddAndEditNoteViewController", bundle: Bundle(for: AddAndEditNoteViewController.self))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        titleTextField.resignFirstResponder()
        descriptionTextView.resignFirstResponder()
    }
    
    func setupUI() {
        assignValueToUI()
        applyStylesToLabels()
        hideKeyBoardTappedAround()
        configureKeyBoardNotifications()
        configureTextFields()
    }
    
    private func assignValueToUI(){
        if noteModel != nil{
            navigationItem.title = "Edit"
            titleTextField.text = noteModel?.name
            descriptionTextView.text = noteModel?.text
        }else{
            navigationItem.title = "Add"
        }
    }
    
    private func configureKeyBoardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func configureTextFields(){
        titleTextField.delegate = self
        descriptionTextView.delegate = self
    }
    
    private func applyStylesToLabels() {
        
        titleTextField.showStyle(with: .content)
        descriptionTextView.showStyle(with: .content)
        
        for lable in subTitlesLabels{
            lable.showStyle(with: .small, color: .darkGray)
        }
        doneButton.showStyle(with: .subtitle, textColor: .white, bgColor: .black, needCircularCorners: true)
    }
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        
        let name = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let descriptionString = descriptionTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        noteLogic?.delegate = delegate
        
        if noteModel != nil {
            noteLogic?.editNoteDetails(noteId: noteModel?.id, name: name, description: descriptionString)
        } else {
            if name.count == 0{
                showAlert("Enter Note Name.")
            }else{
                noteLogic?.addNewNote(name: name, description: descriptionString)
            }
        }
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func keyBoardWillShow(notification : Notification) {
        
        if let keyBoardFrame : NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyBoardHeight = keyBoardFrame.cgRectValue.height
            self.scrollViewBottomConstraint.constant = keyBoardHeight
        }
    }
    
    @objc private func keyBoardWillHide() {
        scrollViewBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

extension AddAndEditNoteViewController : UITextViewDelegate , UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return range.location <= 100
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return range.location <= 10000
    }
}
