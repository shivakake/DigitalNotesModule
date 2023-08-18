//
//  NoteDetailsViewController.swift
//  NotesModule
//
//  Created by PGK Shiva Kumar on 17/11/22.
//

import UIKit

class NoteDetailsViewController: UIViewController {
    
    @IBOutlet private weak var noteStatusImageView: UIImageView!
    @IBOutlet private weak var updatedDateLabel: UILabel!
    @IBOutlet private weak var noteNameLabel: UILabel!
    @IBOutlet private weak var noteTextLabel: UILabel!
    @IBOutlet private weak var noteView : UIView!
    @IBOutlet private var subTitlesLabels: [UILabel]!
    
    var noteLogic : NotesLogic?
    var noteModel : NoteModel?
    weak var delegate : NotesLogicDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyStylesToLabels()
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = ""
        noteLogic?.delegate = self
    }
    
    func updateUI() {
        updatedDateLabel.text = noteModel?.updated
        noteNameLabel.text = noteModel?.name
        let descriptionString = noteModel?.text ?? ""
        noteTextLabel.text = descriptionString
        noteView.isHidden = descriptionString.isEmpty
        setStatusNavigation(status: noteModel?.datastatus?.lowercased() ?? "active")
    }
    
    private func applyStylesToLabels() {
        
        noteNameLabel.showStyle(with: .largeTitle , weight: .medium)
        noteTextLabel.showStyle(with: .content)
        updatedDateLabel.showStyle(with: .content)
        for lable in subTitlesLabels{
            lable.showStyle(with: .small, weight: .regular, color: .darkGray)
        }
    }
    
    func goToEditPage() {
        let controller = AddAndEditNoteViewController(noteModel: noteModel, noteLogic: noteLogic, delegate: self)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func setStatusNavigation(status: String){
        
        var moreBarButtonItem = UIBarButtonItem()
        
        let moreImage = FunctionsHelper.sharedInstance.getCustomImage(customImage: .ellipsis)
        
        let editAction = UIAction(title: "Edit", image: UIImage(systemName: FunctionsHelper.sharedInstance.getCustomImage(customImage: .squareandpencil))) { [unowned self] _ in
            goToEditPage()
        }
        
        let draftAction = UIAction(title: "Draft", image: UIImage(systemName: FunctionsHelper.sharedInstance.getCustomImage(customImage: .envelopeopen))) { [unowned self] _ in
            noteLogic?.draftNote(memberId: GlobalStrings.sharedInstance.memberId, noteId: noteModel?.id ?? "")
        }
        
        let completeAction = UIAction(title: "Complete", image: UIImage(systemName: FunctionsHelper.sharedInstance.getCustomImage(customImage: .docbadgeellipsis))) { [unowned self] _ in
            noteLogic?.completeNote(memberId: GlobalStrings.sharedInstance.memberId, noteId: noteModel?.id ?? "")
        }
        
        let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: FunctionsHelper.sharedInstance.getCustomImage(customImage: .binxmark))) { [unowned self] _ in
            noteLogic?.delegate = delegate
            noteLogic?.deleteNote(memberId: GlobalStrings.sharedInstance.communityId, noteId: noteModel?.id ?? "")
            navigationController?.popViewController(animated: true)
        }
        
        let approveAction = UIAction(title: "Approve", image: UIImage(systemName: FunctionsHelper.sharedInstance.getCustomImage(customImage: .checkmarkcircle))) { [unowned self] _ in
            noteLogic?.approveNote(memberId: GlobalStrings.sharedInstance.communityId, noteId: noteModel?.id ?? "")
        }
        
        switch status.lowercased() {
        
        case "active" ,"live":
            noteStatusImageView.tintColor = .systemGreen
            moreBarButtonItem = UIBarButtonItem(title: "", image: UIImage(systemName: moreImage), primaryAction: nil, menu: UIMenu(title: "", children: [editAction , draftAction , completeAction , deleteAction]))
            
        case "draft" :
            noteStatusImageView.tintColor = .systemYellow
            moreBarButtonItem = UIBarButtonItem(title: "", image: UIImage(systemName: moreImage), primaryAction: nil, menu: UIMenu(title: "", children: [editAction , deleteAction , approveAction]))
            
        case "complete" :
            noteStatusImageView.tintColor = .systemBlue
            moreBarButtonItem = UIBarButtonItem(title: "", image: UIImage(systemName: moreImage), primaryAction: nil, menu: UIMenu(title: "", children: [approveAction]))
            
        case "inactive" :
            noteStatusImageView.tintColor = .systemGray
            
        case "error" :
            noteStatusImageView.tintColor = .systemRed
            
        case "queue" :
            noteStatusImageView.tintColor = .systemPurple
            
        default:
            break
        }
        navigationItem.rightBarButtonItems = [moreBarButtonItem]
    }
}

extension NoteDetailsViewController : NotesLogicDelegate {
    
    func getNoteDetails(detailsStatus: Int?, noteModel: NoteModel?) { }
    
    
    func getNotesList(data: [NoteModel]) { }
    
    func getNoteDetails(data: NoteModel?) {
        noteModel = data
        DispatchQueue.main.async { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.updateUI()
        }
    }
    
    func updateNoteStatusChange(id: String, dataStatus: String, status: Int) {
        DispatchQueue.main.async {
            let updateStatus = status == 1 ? dataStatus : "error"
            self.setStatusNavigation(status: updateStatus)
            self.delegate?.updateNoteStatusChange(id: id, dataStatus: dataStatus, status: status)
        }
    }
    
    func noteStatusChangeForQueue(id: String) {        
        DispatchQueue.main.async {
            self.setStatusNavigation(status: "queue")
            self.delegate?.noteStatusChangeForQueue(id: id)
        }
    }
    
    func addNewNoteInQueue(model: NoteModel?) { }
    
    func editNote(model: NoteModel?) {
        self.noteModel = model
        DispatchQueue.main.async {
            self.noteNameLabel.text = self.noteModel?.name
            self.noteTextLabel.text = self.noteModel?.text
            self.setStatusNavigation(status: "queue")
            self.delegate?.editNote(model: model)
        }
    }
    
    func updateAddNoteSuccess(id: String, datastatus: String, verifyId: String, status: Int) { }
    
    func updateEditNoteSuccess(id: String, dataStatus: String, status: Int) {
        DispatchQueue.main.async {
            let updateStatus = status == 1 ? dataStatus : "error"
            self.setStatusNavigation(status: updateStatus)
            self.delegate?.updateEditNoteSuccess(id: id, dataStatus: dataStatus, status: status)
        }
    }
    
    func updateDeleteNoteSuccess(id: String, dataStatus: String, status: Int) { }
}
