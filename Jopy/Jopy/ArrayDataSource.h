//
//  ArrayDataSource.h
//  Jopy
//
//  Created by Edson Teco on 18/11/14.
//  Copyright (c) 2014 gwaya. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^TableViewCellConfigureBlock)(id cell, id item);

@interface ArrayDataSource : NSObject <UITableViewDataSource>

@property (nonatomic, strong) NSArray *items;

- (id)initWithItems:(NSArray *)anItems cellIdentifier:(NSString *)aCellIdentifier configureCellBlock:(TableViewCellConfigureBlock)aConfigureCellBlock;
- (id)itemAtIndexPath:(NSIndexPath *)indexPath;

@end
