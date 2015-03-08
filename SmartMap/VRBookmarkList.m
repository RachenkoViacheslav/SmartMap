//
//  VRBookmarkList.m
//  SmartMap
//
//  Created by Admin on 18.02.15.
//  Copyright (c) 2015 Rachenko Viacheslav. All rights reserved.
//

#import "VRBookmarkList.h"
#import "VRAppDelegate.h"
#import "VRBookmarkDetail.h"

@interface VRBookmarkList ()

@end

@implementation VRBookmarkList

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
  
NSLog(@"viewDidLoad");

}

-(void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
 //   NSLog(@"[self.bookmarksArray count] = %i", [self.bookmarksArray count]);
    // Return the number of rows in the section.
    NSLog(@"numberOfRowsInSection");
    return [self.bookmarksArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{NSLog(@"cellForRowAtIndexPath");
    static NSString *CellIdentifier = @"BookmarkCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
     NSManagedObject *cacheDate = [self.bookmarksArray objectAtIndex:indexPath.row];
    NSString *latitute = [cacheDate valueForKey:@"latitute"];
    NSString *longitude = [cacheDate valueForKey:@"longitude"];
  
    
   
   cell.textLabel.text =  [cacheDate valueForKey:@"name"];
    NSString *coordinateString = [NSString stringWithFormat:@"%@, %@",latitute ,longitude ];
    cell.detailTextLabel.text = coordinateString;
    

    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    NSManagedObject *cacheDate = [self.bookmarksArray objectAtIndex:indexPath.row];
    NSString *latitute = [cacheDate valueForKey:@"latitute"];
    NSString *longitude = [cacheDate valueForKey:@"longitude"];
    
    NSLog(@"indexPath.row = %d", indexPath.row);
    NSLog(@"indexPath.row = %@", cell.detailTextLabel.text);
    
  selectedIndexPathStr = [NSString stringWithFormat:@"%d",indexPath.row];
    [self.delegatePopop selectedBookmarkCoordinateLatitute:latitute andLongitude:longitude];
   
    if (self.enableSegue==YES) {
        [self performSegueWithIdentifier:@"showDetailBookmark" sender:selectedIndexPathStr];
    }
    
    
    
   // [self.delegate selectedIondexRow:selectIndexString];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


-(NSManagedObjectContext*)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication]delegate];
    
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSManagedObjectContext *context = [self managedObjectContext];
    
    NSManagedObject *cacheDate = [self.bookmarksArray objectAtIndex:indexPath.row];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"nil");
        
        VRAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        
        NSManagedObjectContext *context = [appDelegate managedObjectContext];
        
        [context deleteObject:cacheDate];
        [self.bookmarksArray removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView reloadData];
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Can't save %@ %@",error, [error localizedDescription]);
        }

        
      //  [context deleteObject:cacheDate];
    }
    
}



- (IBAction)chackEditModeButton:(id)sender {
}

#pragma mark - Segue

//showDetailBookmark

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
    if ([segue.identifier isEqualToString:@"showDetailBookmark"]) {
        
        
        NSManagedObject *selectBookmark = [self.bookmarksArray objectAtIndex:[selectedIndexPathStr integerValue]];
        //        VRShowDetailInfo* vc = segue.destinationViewController;
        //
        //        vc.walk = selectWalk;
        
        VRBookmarkDetail* bookmarkDetailView = segue.destinationViewController;
        
        bookmarkDetailView.bookmarkItem = selectBookmark;
        
    }
    
    
}





@end
