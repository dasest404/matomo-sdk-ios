//
//  PiwikAFNetworking2Dispatcher.m
//  PiwikTracker
//
//  Created by Mattias Levin on 02/09/14.
//  Copyright (c) 2014 Mattias Levin. All rights reserved.
//

#import "PiwikAFNetworking2Dispatcher.h"
#import "AFNetworking.h"


@interface PiwikAFNetworking2Dispatcher ()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@end


@implementation PiwikAFNetworking2Dispatcher


- (void)sendSingleEventToPath:(NSString*)path
                parameters:(NSDictionary*)parameters
                   success:(void (^)())successBlock
                   failure:(void (^)(BOOL shouldContinue))failureBlock {
  
  if (!self.sessionManager) {
    self.sessionManager = [AFHTTPSessionManager manager];
  }
  
  self.sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
  
  [self.sessionManager GET:path parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
    
    NSLog(@"Successfully sent stats to Piwik server");
    successBlock();
    
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    
    NSLog(@"Failed to send stats to Piwik server with reason : %@", error);
    failureBlock([self shouldAbortdispatchForNetworkError:error]);
    
  }];
  
}


- (void)sendBatchEventsToPath:(NSString*)path
                   parameters:(NSDictionary*)parameters
                      success:(void (^)())successBlock
                      failure:(void (^)(BOOL shouldContinue))failureBlock {
  
  if (!self.sessionManager) {
    self.sessionManager = [AFHTTPSessionManager manager];
  }
  
  self.sessionManager.requestSerializer = [AFJSONRequestSerializer serializerWithWritingOptions:0];
  
  [self.sessionManager POST:path parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
    
    NSLog(@"Successfully sent stats to Piwik server");
    successBlock();
    
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    
    NSLog(@"Failed to send stats to Piwik server with reason : %@", error);
    failureBlock([self shouldAbortdispatchForNetworkError:error]);
    
  }];
  
}


// Should the dispatch be aborted and pending events rescheduled
- (BOOL)shouldAbortdispatchForNetworkError:(NSError*)error {
  
  if (error.code == NSURLErrorBadURL ||
      error.code == NSURLErrorUnsupportedURL ||
      error.code == NSURLErrorCannotFindHost ||
      error.code == NSURLErrorCannotConnectToHost ||
      error.code == NSURLErrorDNSLookupFailed) {
    return YES;
  } else {
    return NO;
  }
  
}



@end
