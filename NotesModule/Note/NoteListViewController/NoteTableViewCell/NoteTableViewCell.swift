//
//  NoteTableViewCell.swift
//  NotesModule
//
//  Created by PGK Shiva Kumar on 17/11/22.
//

import UIKit

class NoteTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var noteCellBackGround: UIView?
    @IBOutlet weak private var noteTitleLabel: UILabel?
    @IBOutlet weak private var noteStatusImage: UIImageView?
    @IBOutlet weak private var noteDateAndTime: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func setupCell() {
        
        if let backGround = noteCellBackGround {
            self.customView(incomingView: backGround) { (backGround) in
                backGround.styleWithShadow()
            }
        }
        if let status = noteStatusImage {
            status.layer.cornerRadius = status.layer.frame.size.height / 2
        }
        applyTextStyle()
        self.selectionStyle = .none
    }
    
    private func applyTextStyle() {
        
        if let title = noteTitleLabel {
            self.customView(incomingView: title) { (titleLabel) in
                if let titleLabelText = titleLabel as? UILabel{
                    titleLabelText.showStyle(with: .content, weight: .medium, color: .black)
                }else{
                    title.showStyle(with: .content, weight: .medium, color: .black)
                }
            }
        }
        if let dateAndTime = noteDateAndTime {
            dateAndTime.showStyle(with: .meta, weight: .regular, color: .darkGray)
        }
    }
    
    func configureCell(note: NoteModel) {
        
        if let title = noteTitleLabel {
            title.text = note.name ?? "Not Available"
        }
        if let dateAndTime = noteDateAndTime {
            dateAndTime.text = note.created ?? "Not Available"
        }
        if let statusImage = noteStatusImage {
            statusImage.image = UIImage(systemName: FunctionsHelper.sharedInstance.getCustomImage(customImage: .circlefill)) ?? UIImage()
            if let statusString = note.datastatus?.lowercased(){
                switch statusString {
                case "active" , "live":
                    statusImage.tintColor = .systemGreen
                case "complete":
                    statusImage.tintColor = .systemBlue
                case "draft":
                    statusImage.tintColor = .systemYellow
                case "error":
                    statusImage.tintColor = .systemRed
                case "inactive":
                    statusImage.tintColor = .systemGray
                case "queue":
                    statusImage.tintColor = .systemPurple
                default:
                    break
                }
            }else{
                statusImage.tintColor = .systemTeal
            }
        }
    }
}

private extension NoteTableViewCell {
    
    private func customView(incomingView: UIView , completionHandler: (UIView) -> Void){
        completionHandler(incomingView)
    }
}
