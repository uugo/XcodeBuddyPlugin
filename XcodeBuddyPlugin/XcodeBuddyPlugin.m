//
//  XcodeBuddyPlugin.m
//  XcodeBuddyPlugin
//
//  Created by lizhen on 16/3/31.
//  Copyright © 2016年 crafthm. All rights reserved.
//

#import <objc/runtime.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <string.h>
#import "XcodeBuddyPlugin.h"
#import "XcodePrivate.h"
#import "CommContent.h"
#import "XcodeTheme.h"
#import "ConnectAlert.h"
#import "ClientSocket.h"
#import "SendProjectFilesWindowController.h"

static void *XcodeBuddyMenuObserver = &XcodeBuddyMenuObserver;

//plist key
static NSString *const kHostAddressList= @"HostAddressList";

//Xcode UI String
NSString *const MenuItemTitleOpenWithxcBuddy = @"Open with xcBuddy";
NSString *const MenuItemTitleOpenWithExternalEditor= @"Open with External Editor";
NSString *const MenuItemTitleEdit=@"Edit";
NSString *const MenuItemTitleXcodeBuddy=@"XcodeBuddy";
NSString *const MenuItemTitleConnect=@"Connect...";
NSString *const MenuItemTitleDisconnect=@"Disconnect";
NSString *const MenuItemTitleSendProjectFiles=@"Send All Project Files...";


NSString *const ProjectNavigatorContextualMenu = @"Project navigator contextual menu";
//常连ip列表的最大菜单项个数
NSUInteger const MaxCountOfHostArray=5;
ConnectAlert* connectAlert;

@interface XcodeBuddyPlugin()

@property (nonatomic, assign) BOOL projectNavigatorContextualMenuIsOpened;

@property (nonatomic, strong) NSMutableSet *notificationSet;
@property (nonatomic, strong, readwrite) NSBundle *bundle;
@property (nonatomic,copy) NSURL *currentFileURL;
@property (nonatomic,strong) SendProjectFilesWindowController* sendProjectFilesWindowController;
@end

@implementation XcodeBuddyPlugin

@synthesize WorkSpaceFilePath;

ConnectAlert *connectAlert ;

NSMutableArray *hostarray;

NSMenuItem *XcodeBuddyMenuItem;
NSMenuItem *disconnectMenuItem;

NSArray*  CanSendedFileExtension;
NSArray* IgnordDirectoryName;

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}


- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource access
        self.bundle = plugin;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didNSMenuDidChangeItemNotification:)
                                                     name:NSMenuDidChangeItemNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didApplicationFinishLaunchingNotification:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
        CanSendedFileExtension=@[@"h",@"m",@"swift",@"xcworkspace",@"pbxproj",@"xcscheme",@"xcbkptlist",@"plist"];
        IgnordDirectoryName=@[@"Frameworks",@"Resources"];
        
    }
    return self;
}

- (void)didApplicationFinishLaunchingNotification:(NSNotification*)noti
{
    //removeObserver
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    
    [self updateMainMenuItems];
}

#pragma mark - main menu and context menu

-(void)updateMainMenuItems
{
    // Create menu items, initialize UI, etc.
    // Sample Menu Item:
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:MenuItemTitleEdit] ;
    if (menuItem) {
        [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
        XcodeBuddyMenuItem = [[menuItem submenu] itemWithTitle:MenuItemTitleXcodeBuddy];
        if (XcodeBuddyMenuItem != nil) {
            [[XcodeBuddyMenuItem submenu] removeAllItems];
        } else {
            XcodeBuddyMenuItem = [[NSMenuItem alloc] initWithTitle:MenuItemTitleXcodeBuddy action:nil keyEquivalent:@""];
            NSMenu *subMenu=[[NSMenu alloc] init];
            XcodeBuddyMenuItem.submenu=subMenu;
            [[menuItem submenu] addItem:XcodeBuddyMenuItem];
        }
        //[actionMenuItem setKeyEquivalentModifierMask:NSAlphaShiftKeyMask | NSControlKeyMask];
        //        [mainMenuItem setTarget:self];
        
        //connect
        NSMenuItem *linkMenuItem=[[NSMenuItem alloc] initWithTitle:MenuItemTitleConnect action:@selector(doConnectMenuAction) keyEquivalent:@""];
        [linkMenuItem setTarget:self];
        [XcodeBuddyMenuItem.submenu addItem:linkMenuItem];
        //Send All Project Files
        NSMenuItem *sendMenuItem=[[NSMenuItem alloc] initWithTitle:MenuItemTitleSendProjectFiles action:@selector(doClickSendAllProjectFileMenu) keyEquivalent:@""];
        [sendMenuItem setTarget:self];
        [XcodeBuddyMenuItem.submenu addItem:sendMenuItem];
        //disconnect
        disconnectMenuItem=[[NSMenuItem alloc] initWithTitle:MenuItemTitleDisconnect action:@selector(doClickDisconnect) keyEquivalent:@""];
        [disconnectMenuItem setTarget:self];
        [disconnectMenuItem setAction:nil];
        [XcodeBuddyMenuItem.submenu addItem:disconnectMenuItem];
#ifdef DEBUG
        //clear menu
        NSMenuItem *cleartMenuItem=[[NSMenuItem alloc] initWithTitle:@"Clear Menu..." action:@selector(doClickClearMenuItem) keyEquivalent:@""];
        [cleartMenuItem setTarget:self];
        [XcodeBuddyMenuItem.submenu addItem:cleartMenuItem];
#endif
        
        
        //添加曾经连接过的IP
        [[XcodeBuddyMenuItem submenu] addItem:[NSMenuItem separatorItem]];
        
        hostarray=[[NSUserDefaults standardUserDefaults] objectForKey:kHostAddressList];
        if (hostarray != nil) {
            for (NSString *parray in hostarray){
                NSMenuItem *mitem=[[NSMenuItem alloc] initWithTitle:parray action:@selector(doClickHostAddrList:) keyEquivalent:@""];
                [mitem setTarget:self];
                [[XcodeBuddyMenuItem submenu] addItem:mitem];
            }
        }
        
    }
    menuItem = [[NSApp mainMenu] itemWithTitle:@"File"];
    if (menuItem) {
        NSMenuItem* menuItemOpenWithEE=[[menuItem submenu] itemWithTitle:MenuItemTitleOpenWithExternalEditor];
        NSUInteger index=[[menuItem submenu] indexOfItem:menuItemOpenWithEE];
        if (menuItemOpenWithEE) {
            NSMenuItem* menuItemOpenWithxcBuddy=[[NSMenuItem alloc] initWithTitle:MenuItemTitleOpenWithxcBuddy action: @selector(doOpenWithXcBuddyMenuAction) keyEquivalent:@""];
            [menuItemOpenWithxcBuddy setTarget:self];
            [[menuItem submenu] insertItem:menuItemOpenWithxcBuddy atIndex:index+1];
        }
    }
}

+ (void) updateHostListMenuItemState:(NSString*) ipAndPort state:(BOOL) state{
    NSMenuItem* item=[[XcodeBuddyMenuItem submenu] itemWithTitle:ipAndPort];
    if (item == nil) {
        item=[[NSMenuItem alloc] initWithTitle:ipAndPort action:@selector(doClickHostAddrList:) keyEquivalent:@""];
        [item setTarget:self];
        [[XcodeBuddyMenuItem submenu] addItem:item];
    }
    if (state == YES)
        [item setState:NSOnState];
    else
        [item setState:NSOffState];
}


//初始化右键菜单
- (void) didNSMenuDidChangeItemNotification:(NSNotification *) notification {
    if ([notification.name isEqualToString:@"NSMenuDidChangeItemNotification"]){
        
        NSMenu* mainMenu=(NSMenu*)notification.object;
        NSMenuItem* showInxcBuddyMenu=nil;
        if ([mainMenu.title isEqualToString:ProjectNavigatorContextualMenu]) {
            self.currentFileURL = [self currentContextNavigableItemURL];
            if (self.currentFileURL == nil)
                return ;
            showInxcBuddyMenu=[mainMenu itemWithTitle:MenuItemTitleOpenWithxcBuddy];
            if (showInxcBuddyMenu == nil){
                NSMenuItem* menuItemOpenWithEE=[mainMenu  itemWithTitle:MenuItemTitleOpenWithExternalEditor];
                NSUInteger index=[mainMenu  indexOfItem:menuItemOpenWithEE];
                showInxcBuddyMenu=[[NSMenuItem alloc] initWithTitle:MenuItemTitleOpenWithxcBuddy action:@selector(doOpenWithXcBuddyMenuAction) keyEquivalent:@""];
                showInxcBuddyMenu.target=self;
                //                [mainMenu addItem:[NSMenuItem separatorItem]];
                //                [mainMenu addItem:showInxcBuddyMenu];
                [mainMenu insertItem:showInxcBuddyMenu atIndex:index+1];
            }
            showInxcBuddyMenu.enabled= YES;
        }
    }
}


- (NSURL *)currentSelectedNavigableItemURL {
    IDEFileNavigableItem *item = [[self  selectedSourceCodeFileNavigableItems] firstObject];
    return [item fileURL];
}

- (NSURL *)currentContextNavigableItemURL{
    IDENavigableItem *item = [self contextSourceCodeFileNavigableItems ];
    if ([item isKindOfClass:[IDEFileNavigableItem class]]){
        return ((IDEFileNavigableItem*) item).fileURL;
    }
    return nil;
}


#pragma mark - menu item's selector

- (void)doOpenWithXcBuddyMenuAction{
    if (clientSocketObject.clientSocket != nil && [clientSocketObject.clientSocket isConnected]) {
        NSURL *currentFileURL = [self currentContextNavigableItemURL];

        if (currentFileURL != nil){
            //FIXME:文件过大的处理和测试
            //发送文件路径（包含文件名）
            [self sendFile:currentFileURL Type:kFileContent];
        }
    }
    else {
        [self doConnectMenuAction];
        //            [self doShowInXcBuddyMenuAction];
    }
}

- (BOOL) sendFile:(NSURL*)filePath Type:(NSInteger) type{
    NSString* workspacePath=self.WorkSpaceFilePath;
    if(workspacePath == nil)
        return NO;
    NSString* FileRelativePath=self.WorkSpaceFilePath.stringByDeletingLastPathComponent;
    NSString* ProjectName=[FileRelativePath lastPathComponent];
    NSString* RelativePath=[ProjectName stringByAppendingPathComponent: [filePath.path stringByReplacingOccurrencesOfString:FileRelativePath withString:@""]];

    CommContent* commContent=[[CommContent alloc] init];
    commContent.type=type;
    commContent.str=RelativePath;
    commContent.data=[[NSData alloc] initWithContentsOfFile:filePath.path];
    commContent.length=commContent.data.length;
    [clientSocketObject.clientSocket writeData:[NSKeyedArchiver archivedDataWithRootObject:commContent] withTimeout:-1 tag:0];
    return YES;
}

- (void)doConnectMenuAction
{
    BOOL isConnected=NO;
    if (clientSocketObject.clientSocket != nil && clientSocketObject.clientSocket.isConnected)
        isConnected=YES;
    connectAlert =[[ConnectAlert alloc] init:isConnected];
    [connectAlert runModal];
}

- (void)doClickSendAllProjectFileMenu
{
    NSLog(@"doClickSendAllProjectFileMenu");
      NSString *path=self.WorkSpaceFilePath;
    if (path != nil) {
        if (clientSocketObject.clientSocket.isDisconnected) {
            [self doConnectMenuAction];
        }
        if(self.sendProjectFilesWindowController == nil) {
            self.sendProjectFilesWindowController=[[SendProjectFilesWindowController alloc] initWithWindowNibName:@"SendProjectFilesWindowController"];
        }
        self.sendProjectFilesWindowController.window.title=@"XcodeBuddy";
        [self.sendProjectFilesWindowController.window makeKeyAndOrderFront:nil];
        //send files
        [self.sendProjectFilesWindowController startSending];
        [self sendDirectory:path];
        [self.sendProjectFilesWindowController completeSending:fileIndex];
    }
}
/**
 *  send files and directories in the dirPath
 *
 *  @param dirPath dir path
 *
 *  @return file number in the dir path
 */
static NSInteger fileIndex=0;
- (void) sendDirectory:(NSString *)dirPath {
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSError *err=nil;
    NSArray *fileList=[fileManager contentsOfDirectoryAtPath:dirPath error:&err];
    NSString* workSpacePath=self.WorkSpaceFilePath;
    if (workSpacePath == nil)
        return ;
    for (NSString* fileName in fileList) {
        //ignore hidden file
        if ([[fileName substringToIndex:1] isEqualToString:@"."]) {
            continue;
        }
        NSURL* filePath=[[NSURL alloc] initFileURLWithPath: [dirPath stringByAppendingPathComponent:fileName]];
        BOOL isDir=NO;
        if ([fileManager fileExistsAtPath:filePath.path isDirectory:&isDir]) {
            if (isDir) {
                NSString * ss=[filePath.path stringByReplacingOccurrencesOfString:workSpacePath withString:@""];
                if ([IgnordDirectoryName containsObject:ss])
                    continue;
               [self sendDirectory:filePath.path];
            }
            else {
                if ([CanSendedFileExtension containsObject: filePath.pathExtension]) {
                    [self sendFile:filePath Type:kProjectFiles];
//                    NSLog(@"send file:%@",filePath);
                    fileIndex++;
                    [self.sendProjectFilesWindowController insertStringToTextView:[[NSString alloc] initWithFormat:@"%ld.%@",fileIndex,[filePath.path stringByReplacingOccurrencesOfString:workSpacePath withString:@""] ]];
                    [NSThread sleepForTimeInterval:0.05f];
                }
            }
        }
    }
    return;
}

-(void) doClickDisconnect {
    [clientSocketObject disconnect];
}



- (void) doClickHostAddrList:(NSMenuItem*) menuitem {
    NSString* ip;
    UInt16 port;
    NSArray *array=[menuitem.title componentsSeparatedByString:@":"];
    ip =[array[0] stringValue];
    port=[array[1] intValue];
    [clientSocketObject connectToHost:ip andPort:port];
}


#ifdef DEBUG
- (void)doClickClearMenuItem{
    for(NSString* host in hostarray){
        NSMenuItem* item=[[XcodeBuddyMenuItem submenu] itemWithTitle:host];
        if (item!=nil) {
            [[XcodeBuddyMenuItem submenu] removeItem:item];
            item=nil;
        }
    }
    [hostarray removeAllObjects];
    [[NSUserDefaults standardUserDefaults] setObject:hostarray forKey:kHostAddressList];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
#endif

+(void) addToHostList:(NSString*) ip port:(UInt16)port {
    if (hostarray == nil) {
        hostarray=[[NSMutableArray alloc] init];
    }
    NSString* addStr=[[NSString alloc] initWithFormat:@"%@:%d" ,ip,port ];
    NSUInteger count=[hostarray count];
    if ([hostarray containsObject:addStr]== NO){
        if (count < MaxCountOfHostArray)
            [hostarray addObject:addStr];
        else {
            [hostarray removeObjectAtIndex:0];
            [hostarray addObject:addStr];
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:hostarray forKey:kHostAddressList];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[self class] updateHostListMenuItemState:addStr state:YES];
}



- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (NSArray *)selectedSourceCodeFileNavigableItems {
    NSMutableArray *mutableArray = [NSMutableArray array];
    id currentWindowController = [[NSApp keyWindow] windowController];
    
    if ([currentWindowController isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")]) {
        IDEWorkspaceWindowController *workspaceController = currentWindowController;
        IDEWorkspaceTabController *workspaceTabController = [workspaceController activeWorkspaceTabController];
        IDENavigatorArea *navigatorArea = [workspaceTabController navigatorArea];
        id currentNavigator = [navigatorArea currentNavigator];
        
        if ([currentNavigator isKindOfClass:NSClassFromString(@"IDEStructureNavigator")]) {
            IDEStructureNavigator *structureNavigator = currentNavigator;
            for (id selectedObject in structureNavigator.selectedObjects) {
                NSArray *arrayOfFiles = [self recursivlyCollectFileNavigableItemsFrom:selectedObject];
                
                if ([arrayOfFiles count]) {
                    [mutableArray addObjectsFromArray:arrayOfFiles];
                }
            }
        }
    }
    
    if ([mutableArray count]) {
        return [NSArray arrayWithArray:mutableArray];
    }
    
    return nil;
}


- (IDENavigableItem *)contextSourceCodeFileNavigableItems {
    id currentWindowController = [[NSApp keyWindow] windowController];
    
    if ([currentWindowController isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")]) {
        IDEWorkspaceWindowController *workspaceController = currentWindowController;
        id currentNavigator = [[[workspaceController activeWorkspaceTabController] navigatorArea] currentNavigator];
        __block IDENavigableItem* item=nil;
        if ([currentNavigator isKindOfClass:NSClassFromString(@"IDEStructureNavigator")]) {
            IDEStructureNavigator *structureNavigator = currentNavigator;
            NSIndexSet *indexSet=[[structureNavigator outlineView] contextMenuSelectedRowIndexes];
            [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                item= [[structureNavigator outlineView] itemAtRow:idx];
            }];
            return item;
        }
    }
    
    
    
    return nil;
}

-(NSString*) WorkSpaceFilePath {
//    id currentWindowController = [[NSApp keyWindow] windowController];
//    if ([currentWindowController isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")])
//    {
//        IDEWorkspaceWindowController *workspaceController = currentWindowController;
//        return [[[workspaceController valueForKey:@"_workspace"] valueForKey:@"representingFilePath"] valueForKey:@"_pathString"];
//    }
//    return nil;
    for (NSDocument *document in [NSApp orderedDocuments]) {
        @try {
            //        _workspace(IDEWorkspace) -> representingFilePath(DVTFilePath) -> relativePathOnVolume(NSString)
            NSURL *workspaceDirectoryURL = [[[document valueForKeyPath:@"_workspace.representingFilePath.fileURL"] URLByDeletingLastPathComponent] filePathURL];
            
            if(workspaceDirectoryURL) {
                return workspaceDirectoryURL.path;
            }
        }
        
        @catch (NSException *exception) {
            NSLog(@"OROpenInAppCode Xcode plugin: Raised an exception while asking for the documents '_workspace.representingFilePath.relativePathOnVolume' key path: %@", exception);
        }
    }
    
    return nil;
    
}


- (NSArray *)recursivlyCollectFileNavigableItemsFrom:(IDENavigableItem *)selectedObject {
    id items = nil;
    
    if ([selectedObject isKindOfClass:NSClassFromString(@"IDEGroupNavigableItem")]) {
        NSMutableArray *mItems = [NSMutableArray array];
        IDEGroupNavigableItem *groupNavigableItem = (IDEGroupNavigableItem *)selectedObject;
        
        for (IDENavigableItem *child in groupNavigableItem.childItems) {
            NSArray *childItems = [self recursivlyCollectFileNavigableItemsFrom:child];
            
            if (childItems.count) {
                [mItems addObjectsFromArray:childItems];
            }
        }
        
        items = mItems;
    }
    else if ([selectedObject isKindOfClass:NSClassFromString(@"IDEFileNavigableItem")]) {
        IDEFileNavigableItem *fileNavigableItem = (IDEFileNavigableItem *)selectedObject;
        NSString *uti = [[fileNavigableItem documentType] identifier];
        
        if ([[NSWorkspace sharedWorkspace] type:uti conformsToType:(NSString *)kUTTypeSourceCode]) {
            items = @[fileNavigableItem];
        }
    }
    
    return items;
}


@end
