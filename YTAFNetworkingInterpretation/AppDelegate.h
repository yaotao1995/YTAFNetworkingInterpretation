//
//  AppDelegate.h
//  YTAFNetworkingInterpretation
//
//  Created by july on 2019/3/27.
//  Copyright © 2019 july. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

