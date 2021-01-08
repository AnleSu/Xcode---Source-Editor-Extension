//
//  XcodeHelper.m
//  XcodeHelper
//
//  Created by Yoshitaka Seki on 2017/12/03.
//  Copyright © 2017年 takasek. All rights reserved.
//

#import "XcodeHelper.h"
#import "Xcode.h"
#import <AppleScriptObjC/AppleScriptObjC.h>
#import <Foundation/Foundation.h>
@interface XcodeHelper()<SBApplicationDelegate>
@end
@implementation XcodeHelper
//tccutil reset AppleEvents
- (NSURL *)xcodePath {
    XcodeApplication *app = [SBApplication applicationWithBundleIdentifier: @"com.apple.dt.Xcode"];
    app.delegate = self;
    
    SBElementArray<XcodeWindow *> * windows = app.windows;
    XcodeWindow *window = windows.firstObject;
    NSString *source = window.name;
    SBElementArray<XcodeDocument *> *documents = app.documents;
    for (XcodeDocument* doc in documents) {
        if ([doc.file.lastPathComponent isEqualToString:source]) {
            return doc.file;
        }
    }

    return nil;
}

- (id)eventDidFail:(const AppleEvent *)event withError:(NSError *)error {
    NSLog(@"event fail %d %@",event->descriptorType,error);
    return nil;
}

//// This implements the example protocol. Replace the body of this class with the implementation of this service's protocol.
//- (void)jumpToTestsWithReply:(void (^)(NSString *))reply {
//    SBApplication *app = [SBApplication applicationWithBundleIdentifier: @"com.sublimetext.3"];
//    reply([NSString stringWithFormat:@"%@ %@",app,app.className]);
//    return;
////    SBElementArray<XcodeWindow *> * windows = app.windows;
////    XcodeWindow *window = windows.firstObject;
////
////    NSString *source = window.name;
////    NSMutableArray<NSString *> *destinations = [NSMutableArray array];
////    reply([NSString stringWithFormat:@"window name %@ %@ %d %@",source,window.document.name,windows.count,app]);
////    return;
////    if([window.name containsString:@"Tests."]) {
////        [destinations addObject:[source stringByReplacingOccurrencesOfString:@"Tests." withString:@"."]];
////    } else if([window.name containsString:@"Spec."]) {
////        [destinations addObject:[source stringByReplacingOccurrencesOfString:@"Spec." withString:@"."]];
////    } else {
////        [destinations addObject:[source stringByReplacingOccurrencesOfString:@".swift" withString:@"Spec.swift"]];
////        [destinations addObject:[source stringByReplacingOccurrencesOfString:@".swift" withString:@"Tests.swift"]];
////    }
////
////    XcodeWorkspaceDocument *workspaceDocument = app.activeWorkspaceDocument;
////    NSURL *root = [workspaceDocument.file URLByDeletingLastPathComponent];
////
////    NSURL *destinationURL;
////    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager]
////                                         enumeratorAtURL:root
////                                         includingPropertiesForKeys:[NSArray arrayWithObject: NSURLIsDirectoryKey]
////                                         options:0
////                                         errorHandler:^(NSURL *url, NSError *error) {
////                                             // Handle the error.
////                                             // Return YES if the enumeration should continue after the error.
////                                             return NO;
////                                         }];
////    for (NSURL *url in enumerator) {
////        NSLog(@"found url %@",url);
////        NSError *error;
////        NSNumber *isDirectory = nil;
////        if (! [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:&error]) {
////            // handle error
////
////            reply(@"something wrong.");
////            return;
////        }
////        else if (! [isDirectory boolValue]) {
////            // No error and it’s not a directory; do something with the file
////            for (NSString *destination in destinations) {
////                if ([url.lastPathComponent isEqualToString:destination]) {
////                    destinationURL = url;
////                    break;
////                }
////            }
////        }
////    }
////
////    if (destinationURL == nil) {
////        reply(@"destination not found.");
////    } else {
////        dispatch_async(dispatch_get_main_queue(), ^{
////            [app open:destinationURL];
////        });
////        reply(nil);
////    }
//}

@end
