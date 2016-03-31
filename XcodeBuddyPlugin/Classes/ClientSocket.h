//
//  ClientSocket.h
//  XcodeBuddy
//
//  Created by lizhen on 16/3/28.
//  Copyright © 2016年 craftman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "Singleton.h"

FOUNDATION_EXPORT NSString* strSocketOffLineByUser;
FOUNDATION_EXPORT NSString* strSocketOffLineByServer;

#define clientSocketObject [ClientSocket sharedClientSocket]


@interface ClientSocket : NSObject

DEFINE_SINGLETON_FOR_HEADER(ClientSocket);

@property (nonatomic,copy) NSString* hostIP;
@property (nonatomic,assign) UInt16 hostPort;
@property (nonatomic,strong) GCDAsyncSocket* clientSocket;

-(BOOL) connectToHost:(NSString*) IP andPort:(UInt16) Port;
-(void) disconnect;

@end
