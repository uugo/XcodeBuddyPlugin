//
//  ClientSocket.m
//  XcodeBuddy
//
//  Created by lizhen on 16/3/28.
//  Copyright © 2016年 craftman. All rights reserved.
//

#import "ClientSocket.h"
#import "CommContent.h"
#import "XcodeBuddyPlugin.h"
#import "XcodeTheme.h"

NSString* strSocketOffLineByUser=@"SocketOfflineByUser";
NSString* strSocketOffLineByServer=@"SocketOfflineByServer";

@interface ClientSocket()

@property (nonatomic,retain) NSTimer * connectTimer;

@end

@implementation ClientSocket

@synthesize clientSocket,hostIP,hostPort;

DEFINE_SINGLETON_FOR_CLASS(ClientSocket)

- (id) init {
    if (self=[super init]){
        self.clientSocket=[[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return self;
}

-(BOOL) connectToHost:(NSString*) IP andPort:(UInt16) Port{
    if (IP.length == 0 || Port == 0)
        return false;
    [self disconnect];
    if (self.clientSocket == nil) {
        self.clientSocket=[[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    NSError *err=nil;
    if ([self.clientSocket connectToHost:IP onPort:Port withTimeout:5 error:&err])
    {
        self.clientSocket.userData=strSocketOffLineByServer;
    }
    else {
        NSLog(@"clientSocket connectToHost failed:%@",err);
        return false;
    }
    self.hostIP=IP;
    self.hostPort=Port;
    return true;
}

-(void) disconnect {
    if (self.clientSocket != nil){
        self.clientSocket.userData=strSocketOffLineByUser;
        //        [self.connectTimer invalidate];
        [self.clientSocket disconnect];
    }
    //    self.clientSocket=nil;
}

#pragma mark - GCDAsyncSocket Delegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"didConnectToHost");
//    self.connectTimer=[NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(heartbeatToSocket) userInfo:nil repeats:YES];
//    [self.connectTimer fire];
    //TODO:update to using this plugin firstly,excute this
    [XcodeTheme synXcodeThemeFile:sock];
    [clientSocket readDataWithTimeout:-1 tag:0];
    [XcodeBuddyPlugin addToHostList:host port:port];
    [disconnectMenuItem setAction:@selector(disconnect)];
    if (connectAlert)
        [connectAlert alertUIChange];
}

-(void) heartbeatToSocket{
    //    NSString* longConnect=@"HeartBeat";
    CommContent* heart=[[CommContent alloc] init];
    heart.type=kHeartBeat;
    heart.str=@"HeartBeat";
    heart.data=nil;
    heart.length=0;
    [self.clientSocket writeData:[NSKeyedArchiver archivedDataWithRootObject:heart] withTimeout:-1 tag:0];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    NSLog(@"socketDidDisconnect:%@(%@:%d),error:%@",sock.userData,clientSocket.connectedHost,clientSocket.connectedPort,err);
    if (connectAlert)
        [connectAlert alertUIChange];
    if ((self.hostIP.length != 0) && (self.hostPort != 0)) {
        NSString* addStr=[[NSString alloc] initWithFormat:@"%@:%d" ,self.hostIP,self.hostPort];
        [XcodeBuddyPlugin updateHostListMenuItemState:addStr state:NO];
    }
    [disconnectMenuItem setAction:nil];
    if ([sock.userData isEqualToString: @"SocketOfflineByServer"]){
        //        [self linkServer:self.socketHost andPort:self.socketPort];
    }
    else if ([sock.userData isEqualToString: @"SocketOfflineByUser"]){
        //如果用户断开，不重连
        return;
    }
    
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSLog(@"didReadData,sock=%@,tag=%ld",sock,tag);
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    NSLog(@"didWriteDataWithTag,sock=%@,tag=%ld",sock,tag);
}



@end
