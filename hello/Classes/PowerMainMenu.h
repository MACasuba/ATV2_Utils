//
//  HelloWorldMainMenu.h
//  atvHelloWorld
//
//  Created by Michael Gile on 9/11/11.
//  Copyright 2011 Michael Gile. All rights reserved.
//

#import "BRMediaMenuController.h"
#import "BRController.h"
#import "BRAXTitleChangeProtocol.h"
#import <Foundation/Foundation.h>

//@interface PowerMainMenu : BRMediaMenuController {

//@interface PowerMainMenu : BRController {

@interface PowerMainMenu : BRMenuController {    
    
	NSMutableArray		*_names;
}
//list provider
- (float)heightForRow:(long)row;
- (long)itemCount;
- (id)itemForRow:(long)row;
- (BOOL)rowSelectable:(long)selectable;
- (id)titleForRow:(long)row;

-(NSString *) runForOutput;
-(NSString *) command;
-(NSString *) runThisCmd;
-(NSString *) runString;
-(NSArray *) runArgs;

@end


	
