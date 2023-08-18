//
//  NotesLogic.swift
//  DigitalHorizonsTaskAPI
//
//  Created by PGK Shiva Kumar on 16/09/22.
//

import Foundation
import NixelQueue

enum NotesServiceAPIName : String {
    
    case noteListAPI = "notes"
    case notesDetailsAPI = "note"
    case newNoteAPI = "newnote"
    case editNoteAPI = "editnote"
    case approveNoteAPI = "approvenote"
    case draftNoteAPI = "draftnote"
    case completeNoteAPI = "completenote"
    case deleteNoteAPI = "deletenote"
}

protocol NotesLogicDelegate : AnyObject {
    
    func getNotesList(data : [NoteModel])
    func getNoteDetails(detailsStatus : Int? , noteModel : NoteModel?)
    func updateNoteStatusChange(id : String , dataStatus : String , status : Int)
    func noteStatusChangeForQueue(id: String)
    func addNewNoteInQueue(model: NoteModel?)
    func updateAddNoteSuccess(id: String, datastatus: String, verifyId: String, status: Int)
    func editNote(model : NoteModel?)
    func updateEditNoteSuccess(id : String, dataStatus : String , status : Int)
    func updateDeleteNoteSuccess(id : String , dataStatus : String , status : Int)
}

public class NotesLogic {
    
    public init() { }
    
    weak var delegate: NotesLogicDelegate? {
        didSet {
            ClsQueueManager.shared.setQueueManagerDelegate(to: self)
            ClsQueueManager.shared.setInternetValue(value: 1)
        }
    }
    
    var notesData : [NoteModel] = []
    var statusFilter = "live"
    var searchText = ""
    
    func getCurrentDate()-> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MMM-yy hh:mm"
        let currentDate = formatter.string(from: date)
        return currentDate
    }
    
    //MARK:- Notes List
    public func getNotesList(memberId : String? , status : String? , text : String?) {
        
        let timeStamp      = Int(NSDate().timeIntervalSince1970)
        let strId          = String(timeStamp)
        self.statusFilter = status ?? "live"
        self.searchText = text ?? ""
        
        let objectHashMapData = [
            "ref" : memberId ?? "",
            "type" : "member",
            "group" : GlobalStrings.sharedInstance.communityId,
            "texttype" : "short",
            "status" : self.statusFilter,
            "text" : self.searchText
        ] as NSDictionary
        
        let objHeaderQueue = ClsHeaderQueue(strObjectId: strId, strObjType: "note", strVerifyId: strId, strStatus: "queue", strOperation: "", strApiName: NotesServiceAPIName.noteListAPI.rawValue, isFileUploading: false, strFilePath: "", strFileName: "", objHashMapData: objectHashMapData, objHashMapExtra: [:], arrFiles: [], blIsDirect: true, blEncrypt: false, strEncryptionKey: "")
        
        ClsQueueManager.shared.doDirectOperation(headerQueue: objHeaderQueue)
    }
    
    //MARK:- Notes Details
    public func getNoteDetails(noteId : String?) {
        
        let timeStamp      = Int(NSDate().timeIntervalSince1970)
        let strId          = String(timeStamp)
        
        let objectHashMapData = [
            "ref" : noteId ?? ""
        ] as NSDictionary
        
        let objHeaderQueue = ClsHeaderQueue(strObjectId: strId, strObjType: "note", strVerifyId: strId, strStatus: "queue", strOperation: "", strApiName: NotesServiceAPIName.notesDetailsAPI.rawValue, isFileUploading: false, strFilePath: "", strFileName: "", objHashMapData: objectHashMapData, objHashMapExtra: [:], arrFiles: [], blIsDirect: true, blEncrypt: false, strEncryptionKey: "")
        
        ClsQueueManager.shared.doDirectOperation(headerQueue: objHeaderQueue)
    }
    
    //MARK:- Draft Notes
    public func draftNote(memberId : String? , noteId : String) {
        
        let timeStamp      = Int(NSDate().timeIntervalSince1970)
        let strId          = String(timeStamp)
        
        let objectHashMapData = [
            "ref" : memberId ?? "",
            "type" : "member",
            "item" : noteId
        ] as NSDictionary
        
        let objHeaderQueue = ClsHeaderQueue(strObjectId: strId, strObjType: "note", strVerifyId: strId, strStatus: "queue", strOperation: "draft", strApiName: NotesServiceAPIName.draftNoteAPI.rawValue, isFileUploading: false, strFilePath: "", strFileName: "", objHashMapData: objectHashMapData, objHashMapExtra: [:], arrFiles: [], blIsDirect: false, blEncrypt: false, strEncryptionKey: "")
        
        delegate?.noteStatusChangeForQueue(id: noteId)
        ClsQueueManager.shared.handleObject(headerQueue: objHeaderQueue)
    }
    
    public func approveNote(memberId : String? , noteId : String) {
        
        let timeStamp      = Int(NSDate().timeIntervalSince1970)
        let strId          = String(timeStamp)
        
        let objectHashMapData = [
            "ref" : memberId ?? "",
            "type" : "member",
            "item" : noteId
        ] as NSDictionary
        
        let objHeaderQueue = ClsHeaderQueue(strObjectId: strId, strObjType: "note", strVerifyId: strId, strStatus: "queue", strOperation: "approve", strApiName: NotesServiceAPIName.approveNoteAPI.rawValue, isFileUploading: false, strFilePath: "", strFileName: "", objHashMapData: objectHashMapData, objHashMapExtra: [:], arrFiles: [], blIsDirect: false, blEncrypt: false, strEncryptionKey: "")
        
        delegate?.noteStatusChangeForQueue(id: noteId)
        ClsQueueManager.shared.handleObject(headerQueue: objHeaderQueue)
    }
    
    public func completeNote(memberId : String? , noteId : String) {
        
        let timeStamp      = Int(NSDate().timeIntervalSince1970)
        let strId          = String(timeStamp)
        
        let objectHashMapData = [
            "ref" : memberId ?? "",
            "type" : "member",
            "item" : noteId
        ] as NSDictionary
        
        let objHeaderQueue = ClsHeaderQueue(strObjectId: strId, strObjType: "note", strVerifyId: strId, strStatus: "queue", strOperation: "complete", strApiName: NotesServiceAPIName.completeNoteAPI.rawValue, isFileUploading: false, strFilePath: "", strFileName: "", objHashMapData: objectHashMapData, objHashMapExtra: [:], arrFiles: [], blIsDirect: false, blEncrypt: false, strEncryptionKey: "")
        
        delegate?.noteStatusChangeForQueue(id: noteId)
        ClsQueueManager.shared.handleObject(headerQueue: objHeaderQueue)
    }
    
    public func addNewNote(name : String? , description : String?) {
        
        let timeStamp      = Int(NSDate().timeIntervalSince1970)
        let strId          = String(timeStamp)
        
        let objectHashMapData = [
            "name" : name ?? "",
            "ref" : GlobalStrings.sharedInstance.memberId,
            "type" : "member",
            "group" : GlobalStrings.sharedInstance.communityId,
            "text" : description ?? ""
        ] as NSDictionary
        
        let objHeaderQueue = ClsHeaderQueue(strObjectId: strId, strObjType: "note", strVerifyId: strId, strStatus: "queue", strOperation: "addNewNote", strApiName: NotesServiceAPIName.newNoteAPI.rawValue, isFileUploading: false, strFilePath: "", strFileName: "", objHashMapData: objectHashMapData, objHashMapExtra: [:], arrFiles: [], blIsDirect: false, blEncrypt: false, strEncryptionKey: "")
        
        delegate?.addNewNoteInQueue(model: NoteModel(created: getCurrentDate(), datastatus: "queue", id: strId, name: name, text: description))
        ClsQueueManager.shared.handleObject(headerQueue: objHeaderQueue)
    }
    
    public func editNoteDetails(noteId: String?, name: String?, description: String?) {
        
        let timeStamp      = Int(NSDate().timeIntervalSince1970)
        let strId          = String(timeStamp)
        
        let objectHashMapData = [
            "name" : name ?? "",
            "ref" : GlobalStrings.sharedInstance.memberId,
            "type" : "member",
            "item" : noteId ?? "",
            "text" : description ?? ""
        ] as NSDictionary
        
        let objHeaderQueue = ClsHeaderQueue(strObjectId: noteId ?? "" , strObjType: "note", strVerifyId: strId, strStatus: "queue", strOperation: "editNote", strApiName: NotesServiceAPIName.editNoteAPI.rawValue, isFileUploading: false, strFilePath: "", strFileName: "", objHashMapData: objectHashMapData, objHashMapExtra: [:], arrFiles: [], blIsDirect: true, blEncrypt: false, strEncryptionKey: "")
        
        delegate?.editNote(model: NoteModel(created: getCurrentDate(), datastatus: "queue", id: noteId, name: name, text: description))
        ClsQueueManager.shared.doDirectOperation(headerQueue: objHeaderQueue)
    }
    
    public func deleteNote(memberId : String? , noteId : String) {
        
        let timeStamp      = Int(NSDate().timeIntervalSince1970)
        let strId          = String(timeStamp)
        
        let objectHashMapData = [
            "ref" : memberId ?? "",
            "type" : "member",
            "item" : noteId
        ] as NSDictionary
        
        let objHeaderQueue = ClsHeaderQueue(strObjectId: strId, strObjType: "note", strVerifyId: strId, strStatus: "queue", strOperation: "deleteNote", strApiName: NotesServiceAPIName.deleteNoteAPI.rawValue, isFileUploading: false, strFilePath: "", strFileName: "", objHashMapData: objectHashMapData, objHashMapExtra: [:], arrFiles: [], blIsDirect: false, blEncrypt: false, strEncryptionKey: "")
        
        delegate?.noteStatusChangeForQueue(id: noteId)
        ClsQueueManager.shared.handleObject(headerQueue: objHeaderQueue)
    }
}

extension NotesLogic : QueueManagerDelegate {
    
    public func onOperationResult(objResponseDict: NSDictionary, objHeaderQueue: ClsHeaderQueue, blIsVerify: Bool) {
        
        switch objHeaderQueue.strApiName {
        
        case NotesServiceAPIName.noteListAPI.rawValue:
            handleResponseForNotesList(responseDict: objResponseDict)
            
        case NotesServiceAPIName.notesDetailsAPI.rawValue:
            handleResponseForNoteDetails(responseDict: objResponseDict, objHeaderQueue: objHeaderQueue)
            
        case NotesServiceAPIName.approveNoteAPI.rawValue , NotesServiceAPIName.draftNoteAPI.rawValue , NotesServiceAPIName.completeNoteAPI.rawValue:
            handleResponseForChangingNotesStatus(responseDict: objResponseDict, objHeaderQueue: objHeaderQueue)
            
        case NotesServiceAPIName.newNoteAPI.rawValue:
            handleResponseForNewNote(responseDict: objResponseDict, objHeaderQueue: objHeaderQueue)
            
        case NotesServiceAPIName.editNoteAPI.rawValue:
            handleResponseForEditNote(responseDict: objResponseDict, objHeaderQueue: objHeaderQueue)
            
        case NotesServiceAPIName.deleteNoteAPI.rawValue:
            handleResponseForDeleteNote(responseDict: objResponseDict, objHeaderQueue: objHeaderQueue)
            
        default:
            break
        }
    }
    
    //MARK:- API Response
    
    func handleResponseForNotesList(responseDict: NSDictionary) {
        notesData.removeAll()
        if responseDict.count > 0 {
            let status = responseDict["status"] as? Int
            if status == 1 {
                let dataList = responseDict["list"] as? NSArray
                for data in dataList ?? [] {
                    let list = data as? NSDictionary
                    let id = list?["id"] as? String
                    let created = list?["created"] as? String
                    let updated = list?["updated"] as? String
                    let name = list?["name"] as? String
                    let datastatus = list?["datastatus"] as? String
                    let text = list?["text"] as? String
                    
                    notesData.append(NoteModel(created: created, datastatus: datastatus, id: id, name: name, text: text, updated: updated))
                }
                delegate?.getNotesList(data: notesData)
            } else {
                delegate?.getNotesList(data: notesData)
            }
        } else {
            print("Error")
        }
    }
    
    func handleResponseForNoteDetails(responseDict: NSDictionary , objHeaderQueue: ClsHeaderQueue) {
        
        if responseDict.count > 0 {
            var noteData : NoteModel?
            if responseDict["status"] as? Int == 1 {
                let created = responseDict["created"] as? String
                let datastatus = responseDict["datastatus"] as? String
                let messages = responseDict["messages"] as? String
                let name = responseDict["name"] as? String
                let status = responseDict["status"] as? Int
                let text = responseDict["text"] as? String
                let updated = responseDict["updated"] as? String
                
                noteData = NoteModel(created: created, datastatus: datastatus, messages: messages, id: objHeaderQueue.objHashMapData?["ref"] as? String, name: name , status: status, text: text, updated: updated)
                delegate?.getNoteDetails(detailsStatus: status, noteModel: noteData)
            } else {
                delegate?.getNoteDetails(detailsStatus: responseDict["status"] as? Int, noteModel: nil)
            }
        } else {
            print("Error")
        }
    }
    
    func handleResponseForChangingNotesStatus(responseDict: NSDictionary , objHeaderQueue : ClsHeaderQueue) {
        
        let status = responseDict["status"] as? Int ?? 0
        let datastatus = responseDict["datastatus"] as? String
        
        var noteStatus : NoteModel?
        var noteIndex = -1
        for obNote in self.notesData {
            noteIndex += 1
            if obNote.id == objHeaderQueue.objHashMapData?["item"] as? String ?? ""{
                noteStatus = obNote
                break
            }
        }
        if datastatus?.lowercased() == self.statusFilter || ( (datastatus == "Draft" || datastatus == "Active") && self.statusFilter == "live") {
            notesData[noteIndex].datastatus = datastatus
        }else{
            self.notesData.remove(at: noteIndex)
        }
        delegate?.updateNoteStatusChange(id: objHeaderQueue.strObjectId ?? "", dataStatus: datastatus ?? "", status: status)
    }
    
    func handleResponseForNewNote(responseDict: NSDictionary , objHeaderQueue : ClsHeaderQueue) {
        print("Response :" , responseDict)
        let status = responseDict["status"] as? Int ?? 0
        let id = responseDict["id"] as? String
        let dataStatus = responseDict["datastatus"] as? String
        
        delegate?.updateAddNoteSuccess(id: id ?? "", datastatus: dataStatus ?? "", verifyId: objHeaderQueue.strObjectId ?? "", status: status)
    }
    
    func handleResponseForEditNote(responseDict: NSDictionary , objHeaderQueue: ClsHeaderQueue) {
        print("Response :" , responseDict)
        let status = responseDict["status"] as? Int ?? 0
        let datastatus = responseDict["datastatus"] as? String
        delegate?.updateEditNoteSuccess(id: objHeaderQueue.objHashMapData?["item"] as! String, dataStatus: datastatus ?? "", status: status)
    }
    func handleResponseForDeleteNote(responseDict: NSDictionary , objHeaderQueue : ClsHeaderQueue) {
        print("Response :" , responseDict)
        let status = responseDict["status"] as? Int ?? 0
        let datastatus = responseDict["datastatus"] as? String
        delegate?.updateDeleteNoteSuccess(id: objHeaderQueue.objHashMapData?["item"] as! String , dataStatus: datastatus ?? "", status: status)
    }
}
