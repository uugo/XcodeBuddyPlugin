//
//  IDEStructureNavigator+XcodeBuddy.m
//  XcodeBuddyPlugin
//
//  Created by lizhen on 16/3/20.
//  Copyright © 2016年 craftman. All rights reserved.
//

#import "IDEStructureNavigator+XcodeBuddy.h"
#import "JRSwizzle.h"
#import "XcodeBuddy.h"
#import "CommContent.h"
#import "ConnectAlert.h"


@implementation IDEStructureNavigator (XcodeBuddy)



+ (void) load {
    [self jr_swizzleMethod:@selector(viewDidLoad) withMethod:@selector(XcodeBuddy_viewDidLoad) error:NULL];
    [self jr_swizzleMethod:@selector(menuNeedsUpdate:) withMethod:@selector(XcodeBuddy_menuNeedsUpdate:) error:NULL];
}

- (void) XcodeBuddy_viewDidLoad {
    [self XcodeBuddy_viewDidLoad];
    
}

- (void) XcodeBuddy_menuNeedsUpdate:(NSMenu *)menu{
    [self XcodeBuddy_menuNeedsUpdate:menu];
    __block BOOL canShowMenu=NO;
    __block IDENavigableItem* item;
    NSIndexSet *indexSet=[[self outlineView] contextMenuSelectedRowIndexes];
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        item=[[self outlineView] itemAtRow:idx];
        if ([item isKindOfClass:[IDEFileNavigableItem class]]) {
            canShowMenu=YES;
            NSLog(@"name:%@,is IDEFileNavigableItem",item.name);
        }
        else if ([item isKindOfClass:[IDEGroupNavigableItem class]]) {
//            canShowMenu=YES;
            NSLog(@"name:%@, is IDEGroupNavigableItem",item.name);
        }
       
    }];
    if (canShowMenu) {
        NSMenuItem* showInxcBuddyMenu=nil;
        showInxcBuddyMenu=[menu itemWithTitle:MenuItemTitleOpenWithxcBuddy];
        if (showInxcBuddyMenu == nil){
            NSMenuItem* menuItemOpenWithEE=[menu  itemWithTitle:MenuItemTitleOpenWithExternalEditor];
            NSUInteger index=[menu  indexOfItem:menuItemOpenWithEE];
            showInxcBuddyMenu=[[NSMenuItem alloc] initWithTitle:MenuItemTitleOpenWithxcBuddy action:@selector(doOpenWithXcBuddyMenuAction) keyEquivalent:@""];
            showInxcBuddyMenu.target=self;
            [menu insertItem:showInxcBuddyMenu atIndex:index+1];
        }
        showInxcBuddyMenu.action=@selector(doOpenWithXcBuddyMenuAction);
        showInxcBuddyMenu.enabled= YES;
    }
}

#pragma mark - menu item's selector

- (void)doOpenWithXcBuddyMenuAction{
    if (clientSocketObject.clientSocket != nil && [clientSocket isConnected]) {
        NSIndexSet *indexSet = [[self outlineView] contextMenuSelectedRowIndexes];
       [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
           IDENavigableItem* item=[[self outlineView] itemAtRow:idx];
           if ([item isKindOfClass:[IDEFileNavigableItem class]]) {
//               NSURL *currentFileURL = ((IDEFileNavigableItem*)item).fileURL;
               NSLog(@"doShowInXcBuddyMenuAction:%@",self.currentFileURL);
               if (currentFileURL != nil){
                   //FIXME:文件过大的处理和测试
                   //发送文件路径（包含文件名）
                   NSString* FileRelativePath=sharedPlugin.WorkSpaceFilePath.stringByDeletingLastPathComponent;
                   NSString* ProjectName=[FileRelativePath lastPathComponent];
                   NSString* RelativePath=[ProjectName stringByAppendingPathComponent: [currentFileURL.path stringByReplacingOccurrencesOfString:FileRelativePath withString:@""]];
                   //                NSLog(@"tag=0,RelativePath:%@,filePath:%@",RelativePath,currentFileURL.absoluteString);
                   CommContent* commContent=[[CommContent alloc] init];
                   commContent.type=kFileContent;
                   commContent.str=RelativePath;
                   commContent.data=[[NSData alloc] initWithContentsOfFile:currentFileURL.path];
                   commContent.length=commContent.data.length;
                   [clientSocket writeData:[NSKeyedArchiver archivedDataWithRootObject:commContent] withTimeout:-1 tag:0];
               }
       }
    }];
    } else {
        
        BOOL isConnected=NO;
        if (clientSocket != nil && clientSocket.isConnected)
            isConnected=YES;
        ConnectAlert* connectAlert =[[ConnectAlert alloc] init:isConnected];
        [connectAlert runModal];
    }
}





@end
