//
//  AmityFile.swift
//  AmityUIKit4
//
//  Created by Zay Yar Htun on 6/13/24.
//

import UIKit
import AmitySDK
import MobileCoreServices

extension AmityFileData {
    
    var fileName: String {
        return attributes["name"] as? String ?? "Unknown"
    }
    
}

enum AmityFileState {
    case local(document: AmityDocument)
    case uploading(progress: Double)
    case uploaded(data: AmityFileData)
    case downloadable(fileData: AmityFileData)
    case error(errorMessage: String)
}

public class AmityFile: Hashable, Equatable {
    let id = UUID().uuidString
    var state: AmityFileState {
        didSet {
            config()
        }
    }
    
    private(set) var fileName: String = "Unknown File"
    var fileExtension: String?
    var fileIcon: UIImage?
    var mimeType: String?
    var fileSize: Int64 = 0
    var fileURL: URL?
    
    // We need this file data for creating file post, for uploading state
    private var dataToUpload: AmityFileData?
    
    init(state: AmityFileState) {
        self.state = state
        config()
    }
    
    private func config() {
        switch state {
        case .local(let document):
            fileName = document.fileName
            fileSize = Int64(document.fileSize)
            fileIcon = getFileIcon(fileExtension: document.fileURL.pathExtension)
            fileURL = document.fileURL
            fileExtension = document.typeIdentifier
        case .uploaded(let fileData), .downloadable(let fileData):
            fileName = fileData.attributes["name"] as? String ?? "Unknown File"
            fileExtension = fileData.attributes["extension"] as? String
            fileIcon = getFileIcon(fileExtension: fileExtension ?? "")
            mimeType = fileData.attributes["mimeType"] as? String
            let size = fileData.attributes["size"] as? Int64 ?? 0
            fileSize = size
        case .error(let errorMessage):
            fileName = errorMessage
            fileSize = 0
            fileIcon = AmityIconSet.File.iconFileDefault
            fileURL = nil
        case .uploading:
            break
        }
    }
    
    func formattedFileSize() -> String {
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [ .useBytes, .useKB, .useMB, .useGB]
        bcf.countStyle = .file
        let string = bcf.string(fromByteCount: fileSize)
        return string
    }
    
    func getFileIcon(fileExtension: String) -> UIImage? {
        // For supported extension
        if let availableExtension = AmityFileExtension(rawValue: fileExtension) {
            return availableExtension.icon
        }
        
        // Support for UTType
        let cfExtension = fileExtension as CFString
        
        if let fileUti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, cfExtension, nil)?.takeUnretainedValue() {
            
            if UTTypeConformsTo(fileUti, kUTTypeImage) {
                return AmityIconSet.File.iconFileIMG
            } else if UTTypeConformsTo(fileUti, kUTTypeAudio) {
                return AmityIconSet.File.iconFileAudio
            } else if UTTypeConformsTo(fileUti, kUTTypeMovie) {
                return AmityIconSet.File.iconFileMOV
            } else if UTTypeConformsTo(fileUti, kUTTypeZipArchive) {
                return AmityIconSet.File.iconFileZIP
            } else {
                return AmityIconSet.File.iconFileDefault
            }
            
        } else {
            return AmityIconSet.File.iconFileDefault
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: AmityFile, rhs: AmityFile) -> Bool {
        return lhs.id == rhs.id
    }
    
}

public class AmityDocument: UIDocument {

    var data: Data?
    var fileSize: Int = 0
    var typeIdentifier: String = ""

    public override func contents(forType typeName: String) throws -> Any {
        guard let data = data else { return Data() }
        return try NSKeyedArchiver.archivedData(withRootObject:data,
                                                requiringSecureCoding: true)
    }

    public override func load(fromContents contents: Any, ofType typeName:
        String?) throws {
        guard let data = contents as? Data else { return }
        self.data = data
    }

    public override init(fileURL url: URL) {
        super.init(fileURL: url)
        let resources = try? url.resourceValues(forKeys:[.fileSizeKey, .typeIdentifierKey])
        fileSize = resources?.fileSize ?? 0
        typeIdentifier = resources?.typeIdentifier ?? ""
    }

    var fileName: String {
        return fileURL.lastPathComponent
    }

}

enum AmityFileExtension: String {
    
    case doc
    case docx
    case xls
    case xlsx
    case ppt
    case pptx
    case csv
    case txt
    case pdf
    case html
    case mpeg
    case avi
    case mp3
    case mp4
    
    // Extensions for files in Post
    var uti: String {
        switch self {
        case .doc:
            return "com.microsoft.word.doc"
        case .docx:
            return "org.openxmlformats.wordprocessingml.document"
        case .xls:
            return "com.microsoft.excel.xls"
        case .xlsx:
            return "org.openxmlformats.spreadsheetml.sheet"
        case .ppt:
            return "com.microsoft.powerpoint.​ppt"
        case .pptx:
            return "org.openxmlformats.presentationml.presentation"
        case .csv:
            return "public.comma-separated-values-text"
        case .txt:
            return "public.plain-text" // kUTTypePlainText
        case .pdf:
            return "com.adobe.pdf" // kUTTypePDF
        case .html:
            return "public.html" // kUTTypeHTML
        case .mpeg:
            return "public.mpeg" // kUTTypeMPEG
        case .avi:
            return "public.avi" // kUTTypeAVIMovie
        case .mp3:
            return "public.mp3" // kUTTypeMP3
        case .mp4:
            return "public.mpeg-4" // kUTTypeMPEG4
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .doc, .docx:
            return AmityIconSet.File.iconFileDoc
        case .xls, .xlsx:
            return AmityIconSet.File.iconFileXLS
        case .ppt, .pptx:
            return AmityIconSet.File.iconFilePPT
        case .csv:
            return AmityIconSet.File.iconFileCSV
        case .txt:
            return AmityIconSet.File.iconFileTXT
        case .pdf:
            return AmityIconSet.File.iconFilePDF
        case .html:
            return AmityIconSet.File.iconFileHTML
        case .mpeg:
            return AmityIconSet.File.iconFileMPEG
        case .avi:
            return AmityIconSet.File.iconFileAVI
        case .mp3:
            return AmityIconSet.File.iconFileMP3
        case .mp4:
            return AmityIconSet.File.iconFileMP4
        }
    }
}

// Note
// See more: https://docs.sendbird.com/ios/ui_kit_common_components#3_iconset
/// The `AmityIconSet` contains the icons that are used to compose the screen. The following table shows all the elements of the `AmityIconSet`
/// # Note:
/// You should modify the iconSet values in advance if you want to use different icons.
/// # Customize the IconSet
/// ```
/// AmityIconSet.iconChat = {CUSTOM_IMAGE}
/// ```
public struct AmityIconSet {
    
    private init() { }
    
    public static var iconBack = UIImage(named: "icon_back", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var iconClose = UIImage(named: "icon_close", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var iconMessage = UIImage(named: "icon_message", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var iconCreate = UIImage(named: "icon_create", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var iconSearch = UIImage(named: "icon_search", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var iconCamera = UIImage(named: "icon_camera", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var iconCameraSmall = UIImage(named: "icon_camera_small", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var iconCommunity = UIImage(named: "icon_community", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var iconPrivateSmall = UIImage(named: "icon_private_small", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var iconLike = UIImage(named: "icon_like", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var iconLikeFill = UIImage(named: "icon_like_fill", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var iconComment = UIImage(named: "icon_comment", in: AmityUIKit4Manager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
    public static var iconShare = UIImage(named: "icon_share", in: AmityUIKit4Manager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
    public static var iconPhoto = UIImage(named: "icon_photo", in: AmityUIKit4Manager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
    public static var iconAttach = UIImage(named: "icon_attach", in: AmityUIKit4Manager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
    public static var iconOption = UIImage(named: "icon_option", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var iconCreatePost = UIImage(named: "icon_create_post", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var iconBadgeCheckmark = UIImage(named: "icon_badge_checkmark", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var iconBadgeModerator = UIImage(named: "icon_badge_moderator", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var iconReply = UIImage(named: "icon_reply", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var iconReplyInverse = UIImage(named: "icon_reply_inverse", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var iconExpand = UIImage(named: "icon_expand", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var iconCheckMark =  UIImage(named: "icon_checkmark", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var iconExclamation =  UIImage(named: "icon_exclamation", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var iconAdd = UIImage(named: "icon_add", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var iconChat = UIImage(named: "icon_chat", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var iconEdit = UIImage(named: "icon_edit", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var iconMember = UIImage(named: "icon_members", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var iconCameraFill = UIImage(named: "icon_camera_fill", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var iconAlbumFill = UIImage(named: "icon_album_fill", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var iconFileFill = UIImage(named: "icon_file_fill", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var iconLocationFill = UIImage(named: "icon_location_fill", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var iconMagicWand = UIImage(named: "icon_magic_wand", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var iconCloseWithBackground = UIImage(named: "icon_close_with_background", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var iconNext = UIImage(named: "icon_next", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var iconArrowRight = UIImage(named: "icon_arrow_right", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var iconPublic = UIImage(named: "icon_public", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var iconPrivate = UIImage(named: "icon_private", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var iconRadioOn = UIImage(named: "icon_radio_on", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var iconRadioOff = UIImage(named: "icon_radio_off", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var iconRadioCheck = UIImage(named: "icon_radio_check", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var iconPollOptionAdd = UIImage(named: "icon_poll_option_add", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var iconDropdown = UIImage(named: "icon_dropdown", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var iconDownChevron = UIImage(named: "Icon_down_chevron", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var iconPlayVideo = UIImage(named: "icon_play_video", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    
    public struct File {
        public static var iconFileAudio = UIImage(named: "icon_file_audio", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
        public static var iconFileAVI = UIImage(named: "icon_file_avi", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
        public static var iconFileCSV = UIImage(named: "icon_file_csv", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
        public static var iconFileDefault = UIImage(named: "icon_file_default", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
        public static var iconFileDoc = UIImage(named: "icon_file_doc", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
        public static var iconFileEXE = UIImage(named: "icon_file_exe", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
        public static var iconFileHTML = UIImage(named: "icon_file_html", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
        public static var iconFileMOV = UIImage(named: "icon_file_mov", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
        public static var iconFileMP3 = UIImage(named: "icon_file_mp3", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
        public static var iconFileMP4 = UIImage(named: "icon_file_mp4", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
        public static var iconFileMPEG = UIImage(named: "icon_file_mpeg", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
        public static var iconFilePDF = UIImage(named: "icon_file_pdf", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
        public static var iconFilePPT = UIImage(named: "icon_file_ppt", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
        public static var iconFilePPX = UIImage(named: "icon_file_ppx", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
        public static var iconFileRAR = UIImage(named: "icon_file_rar", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
        public static var iconFileTXT = UIImage(named: "icon_file_txt", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
        public static var iconFileXLS = UIImage(named: "icon_file_xls", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
        public static var iconFileIMG = UIImage(named: "icon_file_img", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
        public static var iconFileZIP = UIImage(named: "icon_file_zip", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    }
    
    public static var emptyReaction = UIImage(named: "empty_reactions", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var noInternetConnection = UIImage(named: "no_internet_connection", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var emptyChat = UIImage(named: "empty_chat", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var iconSendMessage = UIImage(named: "icon_send_message", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var defaultPrivateCommunityChat = UIImage(named: "default_private_community_chat", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var defaultPublicCommunityChat = UIImage(named: "default_public_community_chat", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var defaultAvatar = UIImage(named: "default_direct_chat", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var defaultGroupChat = UIImage(named: "default_group_chat", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var defaultCategory = UIImage(named: "default_category", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var videoThumbnailPlaceholder = UIImage(named: "video_thumbnail_placeholder", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var iconSetting = UIImage(named: "icon_setting", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var iconDeleteMessage = UIImage(named: "icon_delete_message", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    
    // MARK: - Empty Newsfeed
    public static var emptyNewsfeed = UIImage(named: "empty_newsfeed", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var emptyNoPosts = UIImage(named: "empty_no_posts", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    
    // MARK: - User Feed
    public static var privateUserFeed = UIImage(named: "private_user_feed", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var defaultCommunity = AmityIconSet.getColorImage(color: AmityColorSet.primary.blend(.shade2))
    public static var defaultCommunityAvatar = UIImage(named: "default_community_avatar", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    
    // MARK: - Message
    public static var defaultMessageImage = UIImage(named: "default_message_image", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    public static var iconMessageFailed = UIImage(named: "icon_message_failed", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    
    enum Chat {
        public static var iconKeyboard = UIImage(named: "icon_keyboard", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
        public static var iconMic = UIImage(named: "icon_mic", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
        public static var iconPause = UIImage(named: "icon_pause", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
        public static var iconPlay = UIImage(named: "icon_play", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
        public static var iconVoiceMessageGrey = UIImage(named: "icon_voice_message_grey", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
        public static var iconVoiceMessageWhite = UIImage(named: "icon_voice_message_white", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
        public static var iconDelete1 = UIImage(named: "icon_delete_1", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
        public static var iconDelete2 = UIImage(named: "icon_delete_2", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
        public static var iconDelete3 = UIImage(named: "icon_delete_3", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
        public static var iconSetting = UIImage(named: "icon_chat_setting", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    }
    
    enum Post {
        public static var like = UIImage(named: "icon_post_like", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
        public static var liked = UIImage(named: "icon_post_liked", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
        public static var emptyPreviewLinkImage = UIImage(named: "empty_preview_link_image", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
        public static var brokenPreviewLinkImage = UIImage(named: "empty_preview_link_broken_image", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    }
    
    enum CommunitySettings {
        public static var iconItemEditProfile = UIImage(named: "icon_item_edit_profile", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
        public static var iconItemMembers = UIImage(named: "icon_item_members", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
        public static var iconItemNotification = UIImage(named: "icon_item_notification", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
        public static var iconItemPostReview = UIImage(named: "icon_item_post_review", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
        public static var iconCommentSetting = UIImage(named: "icon_community_setting_comment", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
        public static var iconPostSetting = UIImage(named: "icon_community_setting_post", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
        public static var iconStorySetting = UIImage(named: "icon_community_setting_story", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
        public static var iconCommunitySettingBanned = UIImage(named: "icon_community_setting_banned", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    }
        
    enum CommunityNotificationSettings {
        public static var iconComments = UIImage(named: "icon_comments", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
        public static var iconNewPosts = UIImage(named: "icon_new_posts", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
        public static var iconReacts = UIImage(named: "icon_reacts", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
        public static var iconReplies = UIImage(named: "icon_replies", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
        public static var iconNotificationSettings = UIImage(named: "icon_notification_settings", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    }
    
    enum UserSettings {
        public static var iconItemUnfollowUser = UIImage(named: "icon_item_unfollow_user", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
        public static var iconItemReportUser = UIImage(named: "icon_item_report_user", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
        public static var iconItemEditProfile = UIImage(named: "icon_item_edit_profile", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
        public static var iconItemBlockUser = UIImage(named: "icon_item_block_unblock", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    }
    
    enum Follow {
        public static var iconFollowPendingRequest = UIImage(named: "icon_follow_pending_request", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
        public static var iconUnblockUser = UIImage(named: "icon_user_unblock_button", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    }
    
    enum CreatePost {
        public static var iconPost = UIImage(named: "icon_post", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
        public static var iconPoll = UIImage(named: "icon_poll", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
        public static var iconStory = UIImage(named: "icon_story", in: AmityUIKit4Manager.bundle, compatibleWith: nil)
    }
    
    static func getColorImage(color: UIColor) -> UIImage? {
        let rect = CGRect(origin: .zero, size: CGSize(width: 100, height: 100))
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
