//
//  ContentView.swift
//  jskrv
//
//  Created by Adarsh Ranjan on 06/09/23.
//

import SwiftUI
import SendbirdChatSDK
import UIKit

struct ContentView: View {
    @State var text = ""
    var body: some View {
        
        TextField("Enter mesage", text: $text)
        Button {
            let APP_ID = "F72CD449-DFEB-446B-A48F-370F53B0A457"
            let initParams = InitParams(
                applicationId: APP_ID,
                isLocalCachingEnabled: true,
                logLevel: .info
            )
            SendbirdChat.initialize(params: initParams, migrationStartHandler: {
                
            }, completionHandler: { error in
                
            })
            let USER_ID = "adarsh_roro_123"
            SendbirdChat.connect(userId: USER_ID) { user, error in
                guard let _ = user, error == nil else {
                    print("ContentView: init: Sendbird connect: ERROR: \(String(describing: error)). Check applicationId")
                    // Handle error.
                    return
                }
                // The user is connected to the Sendbird server.
            }
            
            let params = GroupChannelCreateParams()
            params.name = "dummy channel"
            params.isDistinct = true
            params.userIds = ["alok_roro_123", "adarsh_roro_123"]
            
            
            GroupChannel.createChannel(params: params) { channel, error in
                guard error == nil else {
                    print("some wrong with  creating channel \(String(describing: error?.localizedDescription))")
                    return
                }
                guard let channel = channel else {
                    print("channel not found")
                    return
                }
                channel.sendUserMessage(text) { message, error in
                    guard let message = message, error == nil else {
                        // Handle error.
                        return
                    }
                    print("message sent \(message.message)")
                }
                
                let mparams = MessageListParams()
                mparams.reverse = false
                mparams.isInclusive = false
                mparams.messageTypeFilter = .all
                mparams.includeMetaArray = false
                mparams.includeReactions = false
                let collection  = SendbirdChat.createMessageCollection(channel: channel, startingPoint: 0, params: mparams)
                print("collection.pendingMessages.count\(collection.pendingMessages.count)")
                print("collection.succeededMessages.count\(collection.succeededMessages.count)")
                print("collection.failedMessages.count\(collection.failedMessages.count)")
                if collection.hasNext {
                    collection.loadNext { messages, error in
                        guard error == nil else {
                            // Handle error.
                            return
                        }
                        print("loadNext mesasge count \(String(describing: messages?.count))")
                        // Add messages to your data source.
                    }
                }
                
                if collection.hasPrevious {
                    collection.loadPrevious { messages, error in
                        guard error == nil else {
                            // Handle error.
                            return
                        }
                        // Add messages to your data source.
                        print("loadPrevious mesasge count \(String(describing: messages?.count))")
                    }
                    
                    
                }
                
                let qParams = GroupChannelListQueryParams()
                qParams.includeEmptyChannel = false
                qParams.order = .chronological
                let query = GroupChannel.createMyGroupChannelListQuery(params: qParams)
                let collection1 = SendbirdChat.createGroupChannelCollection(query: query)
                // Call hasNext first to check if there are more channels to load.
                if collection1?.hasNext == true {
                    collection1?.loadMore(completionHandler: { channels, error in
                        guard error == nil else {
                            // Handle error.
                            return
                        }
                        print("channels--- \(String(describing: channels))")
                        var index = 0
                        if let channelsList = channels {
                            while index < channelsList.count {
                                let channel = channelsList[index]
                                print("channels---channel--\(channel.name) \(channel.members)")
                                var index1 = 0
                                    while index1 < channel.members.count {
                                        print("channels---channel---member---\(channel.members[index1].nickname) \(String(describing: channel.members[index1].profileURL)) \(channel.members[index1].userId)")
                                        index1 += 1
                                    }
                                let params = MessageListParams()
                                params.previousResultSize = 100
                              //  params.nextResultSize = 0
                                params.replyType = .all
                                params.includeThreadInfo = true
                                let timestamp = Date().timeIntervalSince1970 * 1000
                                channel.getMessagesByTimestamp(Int64(timestamp), params: params) { messages, error in
                                    guard error == nil else {
                                        // Handle error.
                                        return
                                    }
                                    var indexMessage = 0
                                    if let messagesArray = messages {
                                        while indexMessage < messagesArray.count {
                                            print("channels---channel---message \(indexMessage)---\(messagesArray[indexMessage].message)")
                                            indexMessage += 1
                                        }
                                    }
                                    // A list of previous and next messages of a specified timestamp is successfully retrieved.
                                    // Through the messages parameter of the callback handler,
                                    // you can access and display the data of each message from the result list
                                    // that the Sendbird server has passed to the callback method.
                                }
                                print("channels---channel2--\(String(describing: channel.lastMessage?.message))")
                                index += 1
                            }
                        }
                        // Add channels to your data source.
                    })
                }
            }
        } label: {
            VStack {
                Text("Send And Recieve Message")
            }
        }
        
        //          Button {
        //              let APP_ID = "F72CD449-DFEB-446B-A48F-370F53B0A457"
        //              let initParams = InitParams(
        //                  applicationId: APP_ID,
        //                  isLocalCachingEnabled: true,
        //                  logLevel: .info
        //              )
        //              SendbirdChat.initialize(params: initParams, migrationStartHandler: {
        //
        //              }, completionHandler: { error in
        //
        //              })
        //              let USER_ID = "alok_roro_123"
        //              SendbirdChat.connect(userId: USER_ID) { user, error in
        //                  guard let _ = user, error == nil else {
        //                      print("ContentView: init: Sendbird connect: ERROR: \(String(describing: error)). Check applicationId")
        //                      // Handle error.
        //                      return
        //                  }
        //                  // The user is connected to the Sendbird server.
        //              }
        //
        //              let params = GroupChannelCreateParams()
        //              params.name = "dummy channel"
        //              params.isDistinct = true
        //              params.userIds = ["alok_roro_123", "adarsh_roro_123"]
        //
        //              GroupChannel.createChannel(params: params) { channel, error in
        //                  guard error == nil else {
        //
        //                      print("some wrong with  craeting channel \(error?.localizedDescription)")
        //                      return
        //                  }
        //                  guard let channel = channel else {
        //                      print("chanel not found")
        //                      return
        //                  }
        //                  Channel = channel
        //                  CHANNEL_URL = channel.channelURL
        //                  CHANNEL_TYPE = channel.channelType
        //
        //              }
        //
        //          } label: {
        //              Text("get message")
        //          }
        
    }
}

import SendbirdChatSDK

class CustomViewController:  MessageCollectionDelegate {
    // The following properties should be initialized before using them.
    var collection: MessageCollection?
    var channel: GroupChannel?
    var startingPoint: Int64!
    
    func createMessageCollection() {
        // You can use a MessageListParams instance for MessageCollection.
        let params = MessageListParams()
        params.reverse = false
        params.isInclusive = false
        params.messageTypeFilter = .all
        params.includeMetaArray = false
        params.includeReactions = false
        // You can add other params setters.
        // ...
        
        guard let channel = self.channel else {
            return
        }
        
        self.collection = SendbirdChat.createMessageCollection(channel: channel, startingPoint: self.startingPoint, params: params)
        self.collection?.delegate = self
    }
    
    // Initialize messages from startingPoint.
    func initialize() {
        guard let collection = self.collection else {
            return
        }
        
        collection.startCollection(initPolicy: .cacheAndReplaceByApi, cacheResultHandler: { messages, error in
            // Messages are retrieved from the local cache.
            // They might be too outdated compared to startingPoint.
        }, apiResultHandler: { messages, error in
            // Messages are retrieved from the Sendbird server through the API.
            // According to MessageCollectionInitPolicy.cacheAndReplaceByApi,
            // the existing data source needs to be cleared
            // before adding retrieved messages to the local cache.
        })
    }
}
