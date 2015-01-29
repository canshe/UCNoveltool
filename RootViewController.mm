#import "RootViewController.h"
#import "sqlite3.h"

static NSString *CellIdentifier = @"CellIdentifier";

@interface chapterInfo()

@property NSInteger chapterID;
@property NSInteger chapterStart;
@property NSInteger chapterEnd;
@property (nonatomic,retain) NSString* chapterName;

@end


@implementation chapterInfo

@end



@interface RootViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) UIActivityViewController *activityViewController;
@property (nonatomic, strong) NSString *TemporaryDirectory;
@property (nonatomic, strong) UIDocumentInteractionController *documentController;
@property (nonatomic, strong) NSString  *str_length;
@property (nonatomic, strong) NSString  *UCNovelPath;
@property (nonatomic, strong) NSString  *UCNovelDatabasePath;
@property (nonatomic, strong) NSString  *UCNovelDatabaseChapterPath;
@property (nonatomic, strong) NSMutableDictionary  *NovelDict_ID_NAME;
@property (nonatomic, strong) NSMutableDictionary  *NovelDict_ID_Path;
@property (nonatomic, strong) NSMutableDictionary  *NovelDict_ID_Image;

@property (nonatomic, strong) NSMutableArray  *Novel_Path;
@property (nonatomic, strong) NSMutableArray  *Novel_ID;

@property (nonatomic, strong) NSMutableArray  *Novel_name_data;
@property (nonatomic, strong) NSMutableArray  *chapterInfoArray;
@property (nonatomic) BOOL  first_alert;
@end


@implementation RootViewController

- (BOOL)              tableView:(UITableView *)tableView
shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
        return YES;
    
}

- (BOOL) tableView:(UITableView *)tableView
  canPerformAction:(SEL)action
 forRowAtIndexPath:(NSIndexPath *)indexPath
        withSender:(id)sender
{
    

    if (action == @selector(copy:))
    {
        
        return YES;
    }
    return NO;
}

- (void) tableView:(UITableView *)tableView
     performAction:(SEL)action
 forRowAtIndexPath:(NSIndexPath *)indexPath
        withSender:(id)sender
{
   
    if (action == @selector(copy:))
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSString *file_name = cell.textLabel.text;
        NSString *file_id = @"";
        for (int i = 0; i < [[self.NovelDict_ID_NAME allKeys] count]; ++i)
        {
            if([[self.NovelDict_ID_NAME objectForKey:[[self.NovelDict_ID_NAME allKeys] objectAtIndex:i]] isEqual:file_name])
            {
                file_id = [[self.NovelDict_ID_NAME allKeys] objectAtIndex:i];
                break;
            }
        }
       
       
        
        NSString *file_path_ucnovel = [self.NovelDict_ID_Path objectForKey:file_id];
        
        NSString *file_tmp_path = [self WriteNovelToTmpFile:file_path_ucnovel
                                                   novel_id:file_id];
        if (nil == file_tmp_path)
        {
            return;
        }
    
   /*    UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Password"
                                  message:self.str_length
                                  delegate:self
                                  cancelButtonTitle:@"取消Cancle"
                                  otherButtonTitles:@"Ok", nil];
        
        
        [alertView show];
     */
        
        [self openDocumentIn:file_tmp_path];
        
    
    }
    
    
}


-(void)openDocumentIn:(NSString *) file_tmp_path
{
    self.documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:file_tmp_path]];
    
    self.documentController.UTI = @"public.plain-text";
    [self.documentController presentOpenInMenuFromRect:CGRectZero
                                                inView:self.view
                                              animated:YES];
    
}

-(void)documentInteractionController:(UIDocumentInteractionController *)controller
       willBeginSendingToApplication:(NSString *)application
{
    
}

-(void)documentInteractionController:(UIDocumentInteractionController *)controller
          didEndSendingToApplication:(NSString *)application
{
    
}

-(void)documentInteractionControllerDidDismissOpenInMenu:
(UIDocumentInteractionController *)controller
{
    
}

- (NSInteger) tableView:(UITableView *)tableView
  numberOfRowsInSection:(NSInteger)section
{
    return [self.NovelDict_ID_Path count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView
          cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = nil;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                           forIndexPath:indexPath];
    [[cell textLabel] setText:[self.Novel_name_data objectAtIndex:indexPath.row]];
    
    
    NSString *file_id = @"";
    for (int i = 0; i < [[self.NovelDict_ID_NAME allKeys] count]; ++i)
    {
        if([[self.NovelDict_ID_NAME objectForKey:[[self.NovelDict_ID_NAME allKeys] objectAtIndex:i]] isEqual:[self.Novel_name_data objectAtIndex:indexPath.row]])
        {
            file_id = [[self.NovelDict_ID_NAME allKeys] objectAtIndex:i];
            break;
        }
    }
    
    
    NSString *file_path_ucnovel = [self.NovelDict_ID_Image objectForKey:file_id];
    
    UIImage *theImage = [UIImage imageWithContentsOfFile:file_path_ucnovel];
    
    
    cell.imageView.image = theImage;
    return cell;
    
}

- (void)loadView {
    self.view = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
    self.NovelDict_ID_NAME = [[NSMutableDictionary alloc] init];
    self.NovelDict_ID_Path = [[NSMutableDictionary alloc] init];
    self.NovelDict_ID_Image = [[NSMutableDictionary alloc] init];
    self.Novel_Path = [[NSMutableArray alloc] init];
    self.Novel_ID = [[NSMutableArray alloc] init];
    self.Novel_name_data = [[NSMutableArray alloc] init];
    //    self.Novel_ID_data = [[NSMutableArray alloc] init];
    //    self.Novel_image_data = [[NSMutableArray alloc] init];
    
    self.chapterInfoArray = [[NSMutableArray alloc] init];
    self.first_alert = TRUE;
    
    self.view.backgroundColor = [UIColor blueColor];
    [self viewDidLoad];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.TemporaryDirectory = NSTemporaryDirectory();
    
    NSString *UCUpPath;
    double version = [[UIDevice currentDevice].systemVersion doubleValue];//判定系统版本。
    if (version>7.9)
    {
        UCUpPath = [[NSString alloc] initWithFormat:@"/private/var/mobile/Containers/Data/Application/"];
    }
    else
    {
        UCUpPath = [[NSString alloc] initWithFormat:@"/private/var/mobile/Applications/"];
        
    }
    
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSError *error = nil;
    NSArray *applicationFiles = [fileManager
                                 contentsOfDirectoryAtPath:UCUpPath
                                 error:&error];
    
    
    NSString *tmp_string;
   
    
    NSArray *UCNovelFiles = nil;
    for (NSURL *item in applicationFiles)
    {
        //self.str_length = @"";
        tmp_string = [[UCUpPath stringByAppendingString:[[NSString alloc] initWithFormat:@"%@", item]] stringByAppendingString:@"/Library/Application Support/NovelBox/"];
        UCNovelFiles = [fileManager contentsOfDirectoryAtPath:tmp_string
                                                        error:&error];
        
        if (UCNovelFiles != nil)
        {
            self.UCNovelPath = tmp_string;
            self.UCNovelDatabasePath = [[UCUpPath stringByAppendingString:[[NSString alloc] initWithFormat:@"%@", item]] stringByAppendingString:@"/Documents/Profile/NovelBox/NBBookItemModel5.db"];
            self.UCNovelDatabaseChapterPath = [[UCUpPath stringByAppendingString:[[NSString alloc] initWithFormat:@"%@", item]] stringByAppendingString:@"/Documents/Profile/NovelBox/NBBookProviderModel3.db"];
            
            
            // self.str_length = self.UCNovelPath;
            break;
        }
        
    }
    
    
    
    //self.UCNovelPath = nil;
    if (self.UCNovelPath != nil)
    {
        //self.str_length = [[NSString alloc] initWithFormat:@"%@", self.UCNovelPath];
    }
    else
    {
       
            
        
            self.str_length = @"未找到UC下载的小说";
        
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"Alert"
                                      message:self.str_length
                                      delegate:nil
                                      cancelButtonTitle:@"Cancel"
                                      otherButtonTitles:@"Ok", nil];
        
            [alertView show];
        
        
            return;
    
    }
    
    
    for (NSURL *item in UCNovelFiles)
    {
        NSString *id_num = [[NSString alloc] initWithFormat:@"%@", item];
        NSString *file = [[self.UCNovelPath stringByAppendingString:id_num ] stringByAppendingString:@"/OfflineFile.ucnovel"];
        NSString *image_file = [[self.UCNovelPath stringByAppendingString:id_num ] stringByAppendingString:@"/CoverImage.png"];
        [self.NovelDict_ID_Path setObject:file
                                   forKey:id_num];
        
//        [self.Novel_Path addObject:file];
//        [self.Novel_image_data addObject:image_file];
//        [self.Novel_ID addObject:id_num];
        [self.NovelDict_ID_Image setObject:image_file
                                    forKey:id_num];
       
    }
    
    
    
    

    
    
    [self ReadNovelDatabase ];
    
    
    
    
    self.myTableView = [[UITableView alloc]
                        initWithFrame:self.view.bounds
                        style:UITableViewStylePlain];
    
    [self.myTableView registerClass:[UITableViewCell class]
             forCellReuseIdentifier:CellIdentifier];
    
    self.myTableView.autoresizingMask =
    UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleHeight;
    
    self.myTableView.dataSource = self;
    self.myTableView.delegate = self;
    
    [self.view addSubview:self.myTableView];
    
    if (self.first_alert == TRUE)
    {
        
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Alert"
                                  message:@"在使用本APP打开某本小说前，请先前往UC浏览器打开该本小说，并确保已经离线缓存，而不是在线查看状态。如果APP闪退，可能是因为您未进行上面的操作。长按所要打开的小说名，然后按Copy后选择所要的APP打开。"
                                  delegate:nil
                                  cancelButtonTitle:@"Cancel"
                                  otherButtonTitles:@"Ok", nil];
        
        [alertView show];
        self.first_alert = FALSE;
    }
    
}
-(void ) ReadNovelDatabase
{
    //self.str_length = self.UCNovelDatabasePath;
    sqlite3 *database;
    
    if (sqlite3_open ([self.UCNovelDatabasePath UTF8String], &database) !=SQLITE_OK)
    {
        //self.str_length = [[NSString alloc] initWithFormat:@"11111"];
        sqlite3_close(database);
    }
    
    NSString *query = [[NSString alloc] initWithFormat:@"SELECT bid, bookName FROM NBBookItemTable"];
    //self.str_length = [[NSString alloc] initWithFormat:@"%@", query];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        
        //依次读取数据库表格FIELDS中每行的内容，并显示在对应的TextField
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            //self.str_length = @"SDASD";
            //获得数据
            char *bid     = (char *)sqlite3_column_text(statement, 0);
            char *rowData = (char *)sqlite3_column_text(statement, 1);
            NSString *bid_str = [[NSString alloc] initWithUTF8String:bid] ;
            NSString *name_str = [[NSString alloc] initWithUTF8String:rowData];
            //[self.Novel_ID_data addObject:bid_str];
            [self.Novel_name_data addObject:name_str];
            [self.NovelDict_ID_NAME setObject:name_str
                                       forKey:bid_str];
        }
        sqlite3_finalize(statement);
    }
    else
    {
        self.str_length = [self.UCNovelDatabasePath stringByAppendingString:@"CCCCC"];
    }
    //关闭数据库
    sqlite3_close(database);
}

-(void ) ReadNovelChapterDatabase:(NSString *)novelID
{
    self.chapterInfoArray = [[NSMutableArray alloc] init];
    
    NSString *tableName = [[NSString alloc] initWithFormat:@"NBChapterItemsTable%@", novelID];
    //self.str_length = self.UCNovelDatabasePath;
    sqlite3 *database;
    
    if (sqlite3_open ([self.UCNovelDatabaseChapterPath UTF8String], &database) !=SQLITE_OK)
    {
        //self.str_length = [[NSString alloc] initWithFormat:@"11111"];
        sqlite3_close(database);
    }
    
    NSString *query = [[NSString alloc] initWithFormat:@"SELECT chapterIndex, chapterName, indexStart, indexEnd FROM %@ ORDER BY chapterIndex", tableName];
    //self.str_length = query;
    
    
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        
        //依次读取数据库表格FIELDS中每行的内容，并显示在对应的TextField
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            //  self.str_length = @"SDASD";
            //获得数据
            
            chapterInfo *ci = [[chapterInfo alloc] init];
            ci.chapterID = sqlite3_column_int(statement, 0);
            ci.chapterStart = sqlite3_column_int(statement, 2);
            ci.chapterEnd = sqlite3_column_int(statement, 3);
            
            
            char *rowData = (char *)sqlite3_column_text(statement, 1);
            ci.chapterName = [[NSString alloc] initWithUTF8String:rowData];
            
            [self.chapterInfoArray addObject:ci ];
            
            //self.str_length = [[NSString alloc] initWithFormat:@"%d %d %@   %d", ci.chapterID, ci.chapterStart, ci.chapterName, [self.chapterInfoArray count]];
        }
        
        // self.str_length = [[NSString alloc] initWithFormat:@"%@", chapterInfoArray];
        
        sqlite3_finalize(statement);
    }
    else
    {
        self.str_length = [self.UCNovelDatabasePath stringByAppendingString:@"CCCCC"];
    }
    //关闭数据库
    sqlite3_close(database);
}
- (NSString *) WriteNovelToTmpFile:(NSString *)txtPath
                          novel_id:(NSString *) novelID

{
    
    
    [self ReadNovelChapterDatabase:novelID];
    NSData * data =[NSData dataWithContentsOfFile:txtPath];
    if (nil == data)
    {
        
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Alert"
                                  message:@"未找到该本小说。"
                                  delegate:nil
                                  cancelButtonTitle:@"Cancel"
                                  otherButtonTitles:@"Ok", nil];
        
        [alertView show];
        return nil;
        
    }

    
    NSMutableData *md = [NSMutableData dataWithData:data];
    
    //去掉正文前的无用内容
    
    
    
    
    
   // self.str_length = [[NSString alloc] initWithFormat:@"%d     %d",[md length], [data length]];
   
    //增加章节名称
    
    int end_byte_count = 0;
    for(int i =0; i<[self.chapterInfoArray count]; ++i)
    {
   
        const char *chapter_name = [[[[[NSString alloc] initWithFormat:@"\n\n"] stringByAppendingString:[[self.chapterInfoArray objectAtIndex:i] chapterName]] stringByAppendingString:@"\n\n"] UTF8String];
        NSInteger chapter_start = [[self.chapterInfoArray objectAtIndex:i] chapterStart] + end_byte_count;
        //NSInteger chapter_end = [[self.chapterInfoArray objectAtIndex:i] chapterEnd]+ end_byte_count;
              char ll[] = {'1','2','3',' ',' ',' '};
        [md getBytes:(void *)(ll+1)
               range:NSMakeRange(chapter_start  , 1)];
        
        [md replaceBytesInRange:NSMakeRange(chapter_start  , 1)
                      withBytes:ll
                         length:2];
        
        
        
        [md replaceBytesInRange:NSMakeRange(chapter_start  , 1)
                      withBytes:chapter_name
                         length:strlen(chapter_name)];
 
            end_byte_count += strlen(chapter_name);
    }
    
    
    char aa[] = {' ',' ',' ',' ',' ',' '};
    int loc = 0;
    int cpppp = 0;
    while(loc < [md length])
    {
        
        char buffer;
        [md getBytes:&buffer range:NSMakeRange(loc, 1)];
        //printf("%d", buffer&0x80);
        if((buffer & 0x80) == 0)
        {
            loc++;
            continue;
        }
        else if((buffer & 0xE0) == 0xC0)
        {
            loc++;
            [md getBytes:&buffer range:NSMakeRange(loc, 1)];
            if((buffer & 0xC0) == 0x80)
            {
                loc++;
                continue;
            }
            loc--;
            //非法字符，将这1个字符替换为AA
            
            [md replaceBytesInRange:NSMakeRange(loc  , 1) withBytes:aa length:1];
            loc++;
            cpppp = loc;
            continue;
            
        }
        else if((buffer & 0xF0) == 0xE0)
        {
            loc++;
            [md getBytes:&buffer range:NSMakeRange(loc, 1)];
            if((buffer & 0xC0) == 0x80)
            {
                loc++;
                [md getBytes:&buffer range:NSMakeRange(loc, 1)];
                if((buffer & 0xC0) == 0x80)
                {
                    loc++;
                    continue;
                }
                loc--;
            }
            loc--;
            //非法字符，将这个字符替换为A
            
            [md replaceBytesInRange:NSMakeRange(loc , 1) withBytes:aa length:1];
            loc++;
            cpppp = loc;
            continue;
            
        }
        else
        {
            [md replaceBytesInRange:NSMakeRange(loc, 1) withBytes:aa length:1];
            loc++;
            continue;
        }
    }
  
    [md replaceBytesInRange:NSMakeRange(0, cpppp) withBytes:aa length:1];
    /*
     if (cpppp >0)
    {
        [md replaceBytesInRange:NSMakeRange(0, cpppp) withBytes:aa length:1];
    }

    
    
     NSInteger novel_start = [[self.chapterInfoArray objectAtIndex:0] chapterStart];
     [md replaceBytesInRange:NSMakeRange(0  , novel_start)
     withBytes:aa
     length:1];
    */
    
    
    
    //  self.str_length =@"3";
    NSString *str = [[NSString alloc] initWithData:md encoding:NSUTF8StringEncoding];

    
    int chinese_start = 0;
    for(int i=0; i< [str length];i++)
    {
        int a = [str characterAtIndex:i];
        if( a > 0x4e00 && a < 0x9fff)
        {
            
            chinese_start = i;
            break;
        }
        
    }
  
    NSString *str_last = [str substringFromIndex:chinese_start];
  
  
  //  NSString *str_last = [[NSString alloc] initWithData:md encoding:NSUTF8StringEncoding];
    NSString *tmpFileID_TXT =[[NSString alloc] initWithFormat:@"%@.txt", [self.NovelDict_ID_NAME objectForKey:novelID ]];
    NSString *path1 =[NSTemporaryDirectory() stringByAppendingPathComponent:tmpFileID_TXT];
    


    
    NSError *error11 = nil;
    
    BOOL succeeded = [str_last writeToFile:path1
                                atomically:YES
                                  encoding:NSUTF8StringEncoding
                                     error:&error11];
    if (succeeded) {
        NSLog(@"Successfully stored the file at: %@", path1);
        //self.str_length =@"4";
    } else {
         NSLog(@"Failed to store the file. Error = %@", error11);
        
        NSString *sssss =[[NSString alloc] initWithFormat:@"%d  %d   %d", (int)[str length], (int)[str_last length] , (int)[md length]];

        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:sssss
                                  message:@"写入临时文件出错。"
                                  delegate:nil
                                  cancelButtonTitle:@"Cancel"
                                  otherButtonTitles:@"Ok", nil];
        
        [alertView show];
                // self.str_length =[path1 stringByAppendingString:[[NSString alloc] initWithFormat:@" %@ %d     %d %d", txtPath, cpppp,    [md length], [str length]]];
    }
    
    return path1;
    
}
@end
