//
//  ConnectAlert.h
//  XcodeBuddyPlugin
//
//  Created by lizhen on 16/3/23.
//  Copyright © 2016年 craftman. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ConnectAlert : NSAlert


@property (nonatomic, strong) NSTextField* IPInputTextField;
@property (nonatomic, strong) NSTextField* PortInputTextField;
@property (nonatomic, strong) NSButton* linkButton;

- (id) init:(BOOL) isConnected;
- (void) alertUIChange;

@end
