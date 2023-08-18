//
//  NotesListViewController.swift
//  NotesModule
//
//  Created by PGK Shiva Kumar on 17/11/22.
//

import UIKit
import NixelQueue

public struct FilterActionSheetModel {
    public var key: String?
    public var value: String?
    public var colour: UIColor?
    public var isSelected: Bool?
}

class NotesListViewController: UIViewController {
    
    @IBOutlet weak var notesSearchBar: UISearchBar!
    @IBOutlet private weak var notesListTableView: UITableView!
    @IBOutlet private weak var noDataLabel: UILabel!
    
    let notesLogic : NotesLogic = NotesLogic()
    var selectedStatusId = "live"
    
    var filterStatusArray = [FilterActionSheetModel(key: "live", value: "Preview", colour: .clear, isSelected: true),
                             FilterActionSheetModel(key: "active", value: "Active", colour: .systemGreen, isSelected: false),
                             FilterActionSheetModel(key: "draft", value: "Draft", colour: .systemYellow, isSelected: false),
                             FilterActionSheetModel(key: "complete", value: "Complete", colour: .systemBlue, isSelected: false),
                             FilterActionSheetModel(key: "inactive", value: "Inactive", colour: .darkGray, isSelected: false)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationButtons()
        notesListTableView.reloadData()
        navigationItem.title = "Notes"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupUI() {
        notesSearchBar.delegate = self
        setupListTableView()
        getNotesListFromAPI()
    }
    
    private func getNotesListFromAPI() {
        notesLogic.delegate = self
        notesLogic.getNotesList(memberId: GlobalStrings.sharedInstance.memberId, status: selectedStatusId, text: "")
    }
    
    private func setupListTableView() {
        notesListTableView.register(UINib(nibName: "NoteTableViewCell", bundle: Bundle(for: NoteTableViewCell.self)), forCellReuseIdentifier: "NoteTableViewCell")
        notesListTableView.dataSource = self
        notesListTableView.delegate = self
        notesListTableView.separatorStyle = .none
    }
    
    func setNavigationButtons() {
        
        let plusButttonImage = UIImage(systemName: FunctionsHelper.sharedInstance.getCustomImage(customImage: .plus))
        let filterButtonImage = UIImage(systemName: FunctionsHelper.sharedInstance.getCustomImage(customImage: .sliderhorizontal3))
        
        let newNoteBarButtonItem = UIBarButtonItem(image: plusButttonImage, style: UIBarButtonItem.Style.plain, target: self, action: #selector(newNoteBarButtonTapped(_:)))
        let filterBarButtonItem = UIBarButtonItem(image: filterButtonImage, style: UIBarButtonItem.Style.plain, target: self, action: #selector(filterBarButtonTapped(_:)))
        
        navigationItem.rightBarButtonItems = [newNoteBarButtonItem , filterBarButtonItem]
    }
    
    @objc func newNoteBarButtonTapped(_ sender: UIButton) {
        let controller = AddAndEditNoteViewController(noteModel: nil, noteLogic: notesLogic, delegate: self)
        navigationController?.pushViewController(controller, animated: true)
    }
    @objc func filterBarButtonTapped(_ sender: UIButton){
        filterActionMenu()
    }
    
    private func filterActionMenu() {
        
        let alert = UIAlertController(title: "Select Filter", message: "Select any one status type", preferredStyle: .actionSheet)
        
        for (index , filter) in filterStatusArray.enumerated() {
            let action = UIAlertAction(title: filter.value, style: .default) { _ in
                self.selectedStatusId = filter.key ?? "live"
                self.filterStatusArray.indices.forEach({self.filterStatusArray[$0].isSelected = false})
                self.filterStatusArray[index].isSelected = true
                self.notesLogic.delegate = self
                self.notesLogic.getNotesList(memberId: GlobalStrings.sharedInstance.memberId, status: self.selectedStatusId, text: "")
            }
            action.setValue(filter.isSelected, forKey: "checked")
            alert.addAction(action)
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true )
    }
}

extension NotesListViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notesLogic.notesData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = notesListTableView.dequeueReusableCell(withIdentifier: "NoteTableViewCell", for: indexPath) as? NoteTableViewCell{
            cell.configureCell(note: notesLogic.notesData[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
}

extension NotesListViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = NoteDetailsViewController(nibName: "NoteDetailsViewController", bundle:nil)
        controller.delegate = self
        controller.noteLogic = self.notesLogic
        self.notesLogic.delegate = self
        notesLogic.getNoteDetails(noteId: notesLogic.notesData[indexPath.row].id)
    }
}

extension NotesListViewController : NotesLogicDelegate {
    
    func getNoteDetails(detailsStatus: Int?, noteModel: NoteModel?) {
        if detailsStatus == 1 {
            DispatchQueue.main.async {
                let controller = NoteDetailsViewController(nibName: "NoteDetailsViewController", bundle:nil)
                controller.noteModel = noteModel
                controller.delegate = self
                controller.noteLogic = self.notesLogic
                self.notesLogic.delegate = self
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }else{
            DispatchQueue.main.async {
                self.showAlert("There is no data to show")
            }
        }
    }
    
    func getNotesList(data: [NoteModel]) {
        DispatchQueue.main.async { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.noDataLabel.isHidden = !data.isEmpty
            weakSelf.notesListTableView.reloadData()
        }
    }
    
    func updateNoteStatusChange(id: String, dataStatus: String, status: Int) {
        guard let firstIndex = notesLogic.notesData.firstIndex(where: {$0.id == id}) else { return }
        DispatchQueue.main.async {
            _ = status == 1 ? dataStatus.lowercased() : "error"
            self.notesListTableView.reloadRows(at: [IndexPath(item: firstIndex, section: 0)], with: .automatic)
        }
    }
    
    func noteStatusChangeForQueue(id: String) {
        guard let firstIndex = notesLogic.notesData.firstIndex(where: {$0.id == id}) else { return }
        
        DispatchQueue.main.async {
            self.notesLogic.notesData[firstIndex].datastatus = "queue"
            self.notesListTableView.reloadRows(at: [IndexPath(item: firstIndex, section: 0)], with: .automatic)
        }
    }
    
    func addNewNoteInQueue(model: NoteModel?) {
        DispatchQueue.main.async {
            self.notesLogic.notesData.insert(model ?? NoteModel(), at: 0)
            let indexpath = IndexPath(item: 0, section: 0)
            self.notesListTableView.beginUpdates()
            self.notesListTableView.insertRows(at: [indexpath], with: .automatic)
            self.notesListTableView.endUpdates()
        }
    }
    
    func editNote(model: NoteModel?) {
        guard let firstIndex = notesLogic.notesData.firstIndex(where: {$0.id == model?.id}) else { return }
        DispatchQueue.main.async {
            self.notesLogic.notesData[firstIndex].name = model?.name
            self.notesLogic.notesData[firstIndex].created = model?.created
            self.notesLogic.notesData[firstIndex].datastatus = model?.datastatus
            self.notesListTableView.reloadRows(at: [IndexPath(item: firstIndex, section: 0)], with: .automatic)
        }
    }
    
    func updateAddNoteSuccess(id: String, datastatus: String, verifyId: String, status: Int) {
        guard let firstIndex = notesLogic.notesData.firstIndex(where: {$0.id == verifyId}) else { return }
        let indexpath = IndexPath(row: firstIndex, section: 0)
        DispatchQueue.main.async {
            if status == 1 {
                self.notesLogic.notesData[firstIndex].id = id
                self.notesLogic.notesData[firstIndex].datastatus = datastatus
                self.notesListTableView.reloadRows(at: [indexpath], with: .automatic)
            } else {
                self.notesLogic.notesData.remove(at: firstIndex)
                self.notesListTableView.deleteRows(at: [indexpath], with: .automatic)
            }
        }
    }
    
    func updateEditNoteSuccess(id: String, dataStatus: String, status: Int) {
        guard let firstIndex = notesLogic.notesData.firstIndex(where: {$0.id == id}) else { return }
        DispatchQueue.main.async {
            let updateStatus = status == 1 ? dataStatus.lowercased() : "error"
            self.notesLogic.notesData[firstIndex].datastatus = updateStatus
            self.notesListTableView.reloadRows(at: [IndexPath(item: firstIndex, section: 0)], with: .automatic)
        }
    }
    
    func updateDeleteNoteSuccess(id: String, dataStatus: String, status: Int) {
        guard let firstIndex = notesLogic.notesData.firstIndex(where: {$0.id == id}) else { return }
        let indexpath = IndexPath(row: firstIndex, section: 0)
        DispatchQueue.main.async {
            if status == 1{
                self.notesLogic.notesData.remove(at: firstIndex)
                self.notesListTableView.deleteRows(at: [indexpath], with: .automatic)
            } else {
                self.notesLogic.notesData[firstIndex].datastatus = "error"
                self.notesListTableView.reloadRows(at: [IndexPath(item: firstIndex, section: 0)], with: .automatic)
            }
        }
    }
}

extension NotesListViewController : UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.notesLogic.getNotesList(memberId: GlobalStrings.sharedInstance.memberId, status: self.selectedStatusId, text: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
