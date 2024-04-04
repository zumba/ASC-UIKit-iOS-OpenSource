//
//  StoryPermissionManager.swift
//  AmityUIKit4
//
//  Created by Zay Yar Htun on 12/20/23.
//

import Foundation
import AmitySDK

// TEMP: Refactor this class
public class StoryPermissionChecker {
    
    public static func checkUserHasManagePermission(communityId: String) async -> Bool {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                AmityUIKitManagerInternal.shared.client.hasPermission(.manageStoryCommunity, forCommunity: communityId) { hasPermission in
                    continuation.resume(returning: hasPermission)
                }
            }
        }
    }
    
    
}