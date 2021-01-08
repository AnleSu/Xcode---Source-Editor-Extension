//
//  SourceEditorCommand.m
//  LocalTool
//
//  Created by Anlesu on 2021/1/6.
//

#import "SourceEditorCommand.h"
#import "XcodeHelper.h"
@implementation SourceEditorCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.
    XCSourceTextRange *selection = invocation.buffer.selections.firstObject;
    NSInteger lineNumber = selection.start.line;
//    xcode中选中的行
    NSString *text = invocation.buffer.lines[lineNumber];
    NSLog(@"选中行的内容%@",text);
    
    NSString *loacalStr = [self findLocalString:text];
    NSLog(@"多语言编码字符串：%@",loacalStr);
    
    XcodeHelper *helper = [[XcodeHelper alloc] init];
    NSURL *xcodePath = [helper xcodePath];
    NSLog(@"xcode path: %@",xcodePath);
    
    NSString *localStringPath = [self findLocalFilePath:[xcodePath.path stringByDeletingLastPathComponent]];
    
    NSString *translateString = [self translateLocalString:loacalStr fromLocalFile:localStringPath];
    
    NSString *result = [self processResult:text chinese:translateString];
    [invocation.buffer.lines replaceObjectAtIndex:lineNumber withObject:result];
    
    completionHandler(nil);
}

- (NSString *)findLocalString:(NSString *)testStr {
//    self.titleLabel.text = [OPMContext localizedString:@"OPM_COMPLETE_INSPECTION_VC_TITLE"]; 就是取出"OPM_COMPLETE_INSPECTION_VC_TITLE"
    if ([testStr containsString:@"localizedString"]) {
        //1.正则
        NSString *pattern = @"\"(\\w+)\"";
        NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:0 error:nil];
        // 2.测试字符串
        NSArray *results = [regex matchesInString:testStr options:0 range:NSMakeRange(0, testStr.length)];
        // 3.遍历结果
        for (NSTextCheckingResult *result in results) {
            NSLog(@"%@ %@", NSStringFromRange(result.range), [testStr substringWithRange:result.range]);
        }
        NSTextCheckingResult *result = results[0];
        return [testStr substringWithRange:result.range ];
        
    }
    return nil;
}

- (NSString *)findLocalFilePath:(NSString *)path {
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    NSString *fileDir = @"/Users/suanle/Desktop/Test01/Test01";
    NSArray *array = [defaultManager contentsOfDirectoryAtPath:fileDir error:nil];

    for (NSString *file in array) {
        NSString *paths = [fileDir stringByAppendingPathComponent:file];
        if ([paths containsString:@"Resource"]) {
            NSArray *resourceArray = [defaultManager contentsOfDirectoryAtPath:paths error:nil];
            for (NSString *resourcePath in resourceArray) {
                if ([resourcePath containsString:@".strings"]) {
                    return [paths stringByAppendingFormat:@"/%@",resourcePath];
                }
            }
            
           
        }
        
               
    }
    return nil;
}

- (NSString *)extractChinese:(NSString *)string {
    //1.正则
    NSString *pattern = @"[\\w\\s]+\\s*\"(\\S*)\"";
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:0 error:nil];
    // 2.测试字符串
    NSArray *results = [regex matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    // 3.遍历结果
//        for (NSTextCheckingResult *result in results) {
//            NSLog(@"%@ %@", NSStringFromRange(result.range), [testStr substringWithRange:result.range]);
//        }
    NSTextCheckingResult *result = results[0];
    return [string substringWithRange:result.range];
}

- (NSString *)translateLocalString:(NSString *)localStr fromLocalFile:(NSString *)loacalFilePath {
    NSString *text = [NSString stringWithContentsOfFile:loacalFilePath encoding:NSUTF8StringEncoding error:nil];
    NSArray *lines = [text componentsSeparatedByString:@"\n"];
    for (NSString *line in lines) {
        if ([line containsString:localStr]) {
            return [self extractChinese:line];
        }
    }
    return nil;
    
}

- (NSString *)processResult:(NSString *)line chinese:(NSString *)chinese {
    line = [line stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    chinese = [chinese stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    return [line stringByAppendingFormat:@" //%@",chinese];
}

@end
